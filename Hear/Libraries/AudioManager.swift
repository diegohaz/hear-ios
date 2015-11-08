//
//  AudioManager.swift
//  Hear
//
//  Created by Diego Haz on 10/9/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Bolts

let AudioManagerWillLoadNotification = "AudioManagerWillLoadNotification"
let AudioManagerDidPlayNotification = "AudioManagerDidPlayNotification"
let AudioManagerDidPauseNotification = "AudioManagerDidPauseNotification"
let AudioManagerDidFinishNotification = "AudioManagerDidFinishNotification"
let AudioManagerTimerNotification = "AudioManagerTimerNotification"

enum AudioManagerStatus: Int {
    case Loading
    case Playing
    case Paused
    case Idle
}

class AudioManager: NSObject {
    static let sharedInstance = AudioManager()
    
    private var player: AVPlayer?
    private var items = [String : AVPlayerItem]()
    private var timeObserver: AnyObject!
    
    private(set) var songs = [Song]()
    private(set) var currentSong: Song?
    private(set) var status = AudioManagerStatus.Idle
    private(set) var time: Double = 0
    
    var duration: Double {
        get {
            return player?.currentItem?.asset.duration.seconds ?? 0
        }
    }
    
    private override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songDidStagnate", name: AVPlayerItemPlaybackStalledNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songDidFinish", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        } catch let e {
            print(e)
        }
    }
    
    func queued() -> Bool { return player as? AVQueuePlayer != nil }
    
    func current(song song: Song) -> Bool { return currentSong?.id == song.id }
    private func current(item item: AVPlayerItem) -> Bool { return player?.currentItem == item }
    
    func playing() -> Bool { return player?.rate != 0 && time > 0 }
    func playing(song song: Song) -> Bool { return current(song: song) && playing() }
    private func playing(item item: AVPlayerItem) -> Bool { return current(item: item) && playing() }
    
    func loading() -> Bool { return player?.currentItem != nil && time == 0 }
    func loading(song song: Song) -> Bool { return current(song: song) && loading() }
    private func loading(item item: AVPlayerItem) -> Bool { return current(item: item) && loading() }
    
    func queue(songs: [Song]) {
        if let player = player as? AVQueuePlayer {
            BFExecutor.backgroundExecutor().execute({ () -> Void in
                let items = player.items()
                
                items.forEach({
                    if !self.playing(item: $0) {
                        player.removeItem($0)
                    }
                })
                
                if let firstSong = songs.first {
                    self.loadItem(firstSong, { (item) -> Void in
                        player.insertItem(item, afterItem: player.currentItem)
                    })
                }
            })
        }
        
        self.songs = songs
    }
    
    func insert(songs: [Song]) {
        self.songs += songs
    }
    
    func remove(song: Song) {
        if let index = songs.indexOf(song) {
            songs.removeAtIndex(index)
            
            if let player = player as? AVQueuePlayer {
                let items = player.items()
                
                items.forEach({
                    if self.getSongByItem($0)?.id == song.id {
                        player.removeItem($0)
                        
                        if index < self.songs.count {
                            self.loadItem(self.songs[index], { player.insertItem($0, afterItem: nil) })
                        }
                    }
                })
            }
        }
    }
    
    private func loadItem(song: Song, _ completion: ((item: AVPlayerItem) -> Void)? = nil) {
        let asset = AVURLAsset(URL: song.previewUrl)
        let keys = ["playable"]
        
        asset.loadValuesAsynchronouslyForKeys(keys) { () -> Void in
            if asset.statusOfValueForKey("playable", error: nil) == .Loaded {
                let item = AVPlayerItem(asset: asset)
                self.items[song.id] = item
                completion?(item: item)
            }
        }
    }
    
    func play(song: Song) {
        let lastSong = currentSong
        
        player?.pause()
        currentSong = song
        status = .Loading
        
        NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerWillLoadNotification, object: song)
        
        if let index = songs.indexOf(song) {
            if index - 1 > 0 && lastSong == songs[index - 1] {
                (player as? AVQueuePlayer)?.advanceToNextItem()
                player?.play()
            } else {
                removeObservers()
                player = AVQueuePlayer()
                addObservers()
                
                loadItem(song, { (item) -> Void in
                    (self.player as? AVQueuePlayer)?.insertItem(item, afterItem: nil)
                    
                    BFExecutor.mainThreadExecutor().execute({ () -> Void in
                        self.player?.play()
                    })
                })
            }
        } else {
            removeObservers()
            player = player?.dynamicType == AVPlayer.self ? player : AVPlayer()
            addObservers()
            
            loadItem(song, { (item) -> Void in
                self.player?.replaceCurrentItemWithPlayerItem(item)
                
                BFExecutor.mainThreadExecutor().execute({ () -> Void in
                    self.addObservers()
                    self.player?.play()
                })
            })
        }
    }
    
    private func removeObservers() {
        if let player = player {
            player.removeObserver(self, forKeyPath: "currentItem")
            player.removeTimeObserver(timeObserver)
        }
    }
    
    private func addObservers() {
        player?.addObserver(self, forKeyPath: "currentItem", options: .Initial, context: nil)
        timeObserver = player?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.1, 600), queue: nil, usingBlock: { (time) -> Void in
            self.time = time.seconds
            
            NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerTimerNotification, object: self.time)
            
            if let currentSong = self.currentSong where self.status != .Playing && self.playing() {
                self.status = .Playing
                NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidPlayNotification, object: currentSong)
            }
        })
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "currentItem" {
            currentItemChanged()
        }
    }
    
    private func currentItemChanged() {
        guard let item = player?.currentItem else {
            status = .Idle
            currentSong = nil
            return
        }
        
        if let song = getSongByItem(item) {
            status = .Loading
            currentSong = song
            
            if let player = player as? AVQueuePlayer {
                if let index = songs.indexOf(song) where index + 1 < songs.count {
                    loadItem(songs[index + 1], { (item) -> Void in
                        player.insertItem(item, afterItem: player.currentItem)
                    })
                }
            }
            
            setSongInfo(song, item: item)
        } else {
            status = .Idle
            currentSong = nil
        }
    }
    
    func pause() {
        status = .Paused
        player?.pause()
        
        NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidPauseNotification, object: currentSong)
    }
    
    func play() {
        status = .Loading
        player?.play()
    }
    
    func toggle() {
        if playing() {
            pause()
        } else {
            play()
        }
    }
    
    func playPrevious() {
        guard let currentSong = currentSong else { return }
        
        if var index = songs.indexOf(currentSong) where index > 0 {
            play(songs[--index])
        }
    }
    
    func playNext() {
        if let player = player as? AVQueuePlayer {
            player.advanceToNextItem()
        }
    }
    
    private func getSongByItem(item: AVPlayerItem) -> Song? {
        guard let index = items.indexOf({ item == $1 }) else { return nil }
        
        let id = items.keys[index]
        
        return Song.get(id)
    }
    
    private func setSongInfo(song: Song, item: AVPlayerItem) {
        var songInfo: [String: AnyObject] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist.name,
            MPMediaItemPropertyPlaybackDuration: item.asset.duration.seconds
        ]
        
        if let image = song.image.getLargestAvailable() {
            songInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
        }
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
        
        song.image.load(.Big).continueWithSuccessBlock { (task) -> AnyObject! in
            songInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: task.result as! UIImage)
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
            
            return nil
        }
    }
    
    func songDidFinish() {
        if let song = currentSong {
            status = .Idle
            NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidFinishNotification, object: song)
            currentSong = nil
        }
    }
    
    func songDidStagnate() {
        pause()
        player?.seekToTime(CMTimeMakeWithSeconds(time - 1, 600))
        
        BFTask(delay: 3000).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            self.play()
            
            return nil
        })
    }
}
