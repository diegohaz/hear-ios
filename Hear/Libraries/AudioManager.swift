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

public let AudioManagerDidPlayNotification = "AudioManagerDidPlayNotification"
public let AudioManagerDidPauseNotification = "AudioManagerDidPauseNotification"
public let AudioManagerDidFinishNotification = "AudioManagerDidFinishNotification"

class AudioManager: NSObject {
    static let sharedInstance = AudioManager()
    
    private var player: AVPlayer?
    
    private(set) var songs = [Song]()
    private(set) var currentSong: Song?
    private(set) var currentIndex: Int?
    
    private override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songDidFinish", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songDidStalled", name: AVPlayerItemPlaybackStalledNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "lambda:", name: AVPlayerItemFailedToPlayToEndTimeNotification, object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        } catch let e {
            print(e)
        }
    }
    
    func reload(songs: [Song]) {
        self.songs = [Song]()
        self.currentIndex = nil
        self.append(songs)
        
        if let player = player as? AVQueuePlayer {
            let items = player.items()
            
            for item in items {
                if item.currentTime().seconds == 0 {
                    player.removeItem(item)
                } else {
                    currentIndex = -1
                }
            }
            
            for song in songs {
                player.insertItem(AVPlayerItem(URL: song.previewUrl), afterItem: nil)
            }
        }
    }
    
    func append(songs: [Song]) {
        self.songs += songs
    }
    
    func current(song: Song) -> Bool {
        return currentSong?.id == song.id
    }
    
    func playing() -> Bool {
        guard let player = player where player.error == nil else {
            return false
        }
        
        return player.rate != 0
    }
    
    func playing(song: Song) -> Bool {
        return current(song) && playing()
    }
    
    func currentTime() -> Double {
        guard let player = player else { return 0 }
        guard let item = player.currentItem else { return 0 }
        
        if currentSong?.previewUrl != (item.asset as? AVURLAsset)?.URL {
            return 0
        }
        
        return item.currentTime().seconds
    }
    
    func duration() -> Double {
        guard let player = player else { return 0 }
        guard let item = player.currentItem else { return 0 }
        
        return item.asset.duration.seconds
    }
    
    func pause() {
        player?.pause()
        
        NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidPauseNotification, object: currentSong)
    }
    
    func play(song: Song? = nil) {
        guard let song = song ?? currentSong else {
            return
        }
        
        do  { try AVAudioSession.sharedInstance().setActive(true) }
        catch let e { print(e) }
        
        let isCurrentSong = song == currentSong
        var useQueue = false
        var item: AVPlayerItem?
        
        if let index = songs.indexOf(song) {
            currentIndex = index
            useQueue = true
        }
        
        if !isCurrentSong {
            NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidFinishNotification, object: currentSong)
        }
        
        currentSong = song
        NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidPlayNotification, object: song)

        BFExecutor.backgroundExecutor().execute({ () -> Void in
            if !isCurrentSong {
                if useQueue {
                    self.player = AVQueuePlayer(items: self.songs[self.currentIndex! ..< self.songs.count].map({ AVPlayerItem(URL: $0.previewUrl) }))
                    item = self.player!.currentItem
                } else {
                    item = AVPlayerItem(URL: song.previewUrl)
                    self.player = AVPlayer(playerItem: item!)
                }
            }
            
            self.player?.play()
            
            if let item = item {
                self.setSongInfo(song, item: item)
            }
        })
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
            songDidFinish()
        }
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
        
        song.image.load(.Big).continueWithBlock { (task) -> AnyObject! in
            songInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: task.result as! UIImage)
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
            
            return nil
        }
    }
    
    func songDidFinish() {
        guard let song = currentSong else { return }
        
        BFExecutor.mainThreadExecutor().execute { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidFinishNotification, object: song)
        }
        
        if songs.indexOf(song) == nil { return }
        guard var index = currentIndex else { return }
        
        if songs.count > ++index {
            currentIndex = index
            currentSong = songs[index]
            
            BFExecutor.mainThreadExecutor().execute({ () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidPlayNotification, object: self.currentSong)
            })
            
            setSongInfo(currentSong!, item: player!.currentItem!)
        }
    }
    
    func songDidStalled() {
        pause()
        
        BFTask(delay: 3000).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            self.play()
            
            return nil
        })
    }
}
