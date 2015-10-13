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

class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = AudioManager()
    
    var player: AVAudioPlayer?
    var songs = [Song]()
    
    private var currentSong: Song?
    private var currentIndex = 0
    
    private override init() {
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        } catch let e {
            print(e)
        }
    }
    
    func play(song: Song) -> BFTask {
        var index = 0
        
        for i in 0..<songs.count {
            if songs[i].id == song.id {
                index = i
                break
            } else if i == songs.count - 1 {
                index = songs.count
                songs.append(song)
            }
        }
        
        return play(index)
    }
    
    func play(index: Int) -> BFTask {
        guard songs.indices.contains(index) else {
            print("There's no song at index \(index)")
            return BFTask(error: NSError(domain: BFTaskErrorDomain, code: 0, userInfo: nil))
        }
        
        let song = songs[index]
        
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            song.loadCover().continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                guard let image = UIImage(data: task.result as! NSData) else {
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
        
        return song.loadPreview(true).continueWithSuccessBlock({ (task) -> AnyObject! in
            self.player = try? AVAudioPlayer(data: task.result as! NSData)
            self.player?.delegate = self
            self.currentIndex = index
            self.currentSong = song
            self.play()
            
            let reachability = Reachability.reachabilityForInternetConnection()
            
            if reachability?.isReachableViaWWAN() == true && self.currentIndex < self.songs.count - 1 {
                self.songs[self.currentIndex + 1].loadPreview()
            }
            
            return task
        })
    }
    
    func current(song: Song) -> Bool {
        if let currentSong = currentSong {
            return currentSong.id == song.id
        } else {
            return false
        }
    }
    
    func play() {
        player?.play()
        
        NSNotificationCenter.defaultCenter().postNotificationName("play", object: currentIndex)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let e {
            print(e)
        }
    }
    
    func pause() {
        player?.pause()
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let e {
            print(e)
        }
    }
    
    func stop() {
        player?.stop()
        
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
    
    func playNext() {
        if currentIndex < songs.count - 1 {
            play(++currentIndex)
        }
    }
    
    func playPrevious() {
        if (currentIndex > 0) {
            play(--currentIndex)
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playNext()
    }
}
