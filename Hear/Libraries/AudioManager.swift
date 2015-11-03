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
    private var reloaded = false
    
    private(set) var songs = [Song]()
    private(set) var currentSong: Song?
    
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
        if self.songs.count > 0 {
            reloaded = true
        }
        
        self.songs = [Song]()
        
        if let player = player as? AVQueuePlayer {
            BFExecutor.backgroundExecutor().execute({ () -> Void in
                let items = player.items()
                
                for item in items {
                    if item.currentTime().seconds == 0 {
                        player.removeItem(item)
                    }
                }
                
                if self.reloaded {
                    player.insertItem(AVPlayerItem(URL: self.songs.first!.previewUrl), afterItem: nil)
                }
            })
        }
        
        self.append(songs)
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
        
        // There's a bug when place a song
        let isCurrentSong = song.id == currentSong?.id
        let currentIndex = currentSong != nil ? songs.indexOf(currentSong!) : nil
        let useQueue = songs.indexOf(song) != nil
        var item: AVPlayerItem?
        
        if !isCurrentSong {
            NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidFinishNotification, object: currentSong)
        }
        
        reloaded = false
        currentSong = song
        NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidPlayNotification, object: song)

        BFExecutor.backgroundExecutor().execute({ () -> Void in
            if !isCurrentSong {
                if useQueue {
                    let index = self.songs.indexOf(song)!
                    
                    if currentIndex != nil && currentIndex! + 1 == self.songs.indexOf(song)! {
                        let player = self.player as? AVQueuePlayer
                        player?.advanceToNextItem()
                        
                        if index + 1 < self.songs.count {
                            player?.insertItem(AVPlayerItem(URL: self.songs[index + 1].previewUrl), afterItem: nil)
                        }
                    } else {
                        let limit = index + 1 > self.songs.count ? index : index + 1
                        let songs = self.songs[index ... limit]
                        self.player?.pause()
                        self.player = AVQueuePlayer(items: songs.map({ AVPlayerItem(URL: $0.previewUrl) }))
                        self.player?.play()
                    }
                    
                    item = self.player!.currentItem
                } else {
                    item = AVPlayerItem(URL: song.previewUrl)
                    self.player = AVPlayer(playerItem: item!)
                    self.player?.play()
                }
            } else {
                self.player?.play()
            }
            
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
        
        guard let player = self.player as? AVQueuePlayer else {
            currentSong = nil
            return
        }
        
        var index = songs.indexOf(song) ?? -1
        
        if reloaded {
            index = -1
            reloaded = false
        }
        
        if songs.count > ++index {
            let item = player.currentItem!
            currentSong = songs[index]
            
            if index + 1 < songs.count {
                player.insertItem(AVPlayerItem(URL: songs[index + 1].previewUrl), afterItem: nil)
            }
            
            BFExecutor.mainThreadExecutor().execute({ () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerDidPlayNotification, object: self.currentSong)
            })
            
            setSongInfo(currentSong!, item: item)
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
