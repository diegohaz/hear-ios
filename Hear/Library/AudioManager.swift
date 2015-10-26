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

public let AudioManagerPlayNotification = "AudioManagerPlayNotification"
public let AudioManagerPauseNotification = "AudioManagerPauseNotification"
public let AudioManagerFinishNotification = "AudioManagerFinishNotification"

class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = AudioManager()
    
    var player: AVAudioPlayer?
    var songPosts = [SongPost]()
    
    private(set) var currentSongPost: SongPost?
    private(set) var currentSong: Song?
    private(set) var currentIndex = 0
    
    private override init() {
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        } catch let e {
            print(e)
        }
    }
    
    func reset() {
        self.currentIndex = -1
    }
    
    func play(song song: Song) -> BFTask {
        return play(currentIndex > 0 ? currentIndex : 0, song: song)
    }
    
    func play(songPost songPost: SongPost) -> BFTask {
        var index = 0
        
        for i in 0..<songPosts.count {
            if songPosts[i].isEqual(songPost) {
                index = i
                break
            } else if i == songPosts.count - 1 {
                index = songPosts.count
                songPosts.append(songPost)
            }
        }
        
        return play(index)
    }
    
    func play(index: Int, song: Song? = nil) -> BFTask {
        let reachability = Reachability.reachabilityForInternetConnection()
        let songPost: SongPost? = songPosts.indices.contains(index) ? songPosts[index] : nil
        let song = song ?? songPost!.song
        
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            song.loadCover().continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                guard let image = song.coverImage else {
                    print("Image not found for \(song.title)")
                    return task
                }
                
                let songInfo: [String: AnyObject] = [
                    MPMediaItemPropertyTitle: song.title,
                    MPMediaItemPropertyArtist: song.artist,
                    MPMediaItemPropertyPlaybackDuration: 30,
                    MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: image)
                ]
                
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
                
                return task
            })
        }
        
        return BFTask(delay: 0).continueWithExecutor(BFExecutor.defaultExecutor(), withBlock: { (task) -> AnyObject! in
            return song.loadPreview(reachability?.isReachableViaWiFi() == true ? true : false)
        }).continueWithSuccessBlock { (task) -> AnyObject! in
            guard let result = task.result as? NSData else {
                return BFTask(error: NSError(domain: BFTaskErrorDomain, code: 0, userInfo: nil))
            }
            
            self.player = try? AVAudioPlayer(data: result)
            self.player?.delegate = self
            self.currentIndex = index
            self.currentSong = song
            self.currentSongPost = songPost
            self.play()

            if self.currentIndex < self.songPosts.count - 1 {
                self.songPosts[self.currentIndex + 1].song.loadPreview()
            }
            
            return task
        }
    }
    
    func play() {
        
        player?.play()
        
        BFExecutor.mainThreadExecutor().execute { () -> Void in
            self.currentIndex = self.currentIndex > 0 ? self.currentIndex : 0
            NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerPlayNotification, object: self.currentIndex)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let e {
            print(e)
        }
    }
    
    func pause() {
        player?.pause()
        
        BFExecutor.mainThreadExecutor().execute { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerPauseNotification, object: self.currentIndex)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let e {
            print(e)
        }
    }
    
    func toggle() {
        if player?.playing == true {
            pause()
        } else {
            play()
        }
    }
    
    func stop() {
        pause()
        player = nil
        currentSongPost = nil
        currentSong = nil
    }
    
    func playNext() {
        if currentIndex < songPosts.count - 1 {
            play(++currentIndex)
        }
    }
    
    func playPrevious() {
        if currentIndex > 0 {
            play(--currentIndex)
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName(AudioManagerFinishNotification, object: currentIndex > 0 ? currentIndex : 0)
        
        if currentSongPost?.song.isEqual(currentSong) == true {
            playNext()
        }
    }
}
