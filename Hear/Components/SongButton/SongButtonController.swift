//
//  SongButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import AVFoundation
import Bolts

class SongButtonController: NSObject {
    weak var view: SongButtonView!
    var audio = AudioManager.sharedInstance
    var songPost: SongPost? {
        didSet {
            song = songPost?.song
        }
    }
    var song: Song? {
        didSet {
            let song = self.song
            
            song?.loadCover().continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                guard song?.id == self.song?.id else {
                    return task
                }
                
                self.view.songImageView.image = song?.coverImageRounded
                
                return task
            })
            
            audioDidToggle()
        }
    }
    
    init(view: SongButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidToggle", name: AudioManagerPlayNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidToggle", name: AudioManagerPauseNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidFinish:", name: AudioManagerFinishNotification, object: nil)
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTime", userInfo: [], repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func viewDidTouch() {
        view.bounce()
        toggle()
    }
    
    func audioDidToggle() {
        if let songPost = songPost {
            if songPost.isEqual(audio.currentSongPost) && audio.player?.playing == true {
                view.play()
            } else if songPost.isEqual(audio.currentSongPost) {
                view.pause()
            } else if view?.pauseView.transform.a > 0.1 || view?.springIndicator.transform.a > 0.1 {
                view.pause()
            }
        } else if let song = song {
            if song.isEqual(audio.currentSong) == true && audio.player?.playing == true {
                view.play()
            } else if song.isEqual(audio.currentSong) {
                view.pause()
            } else if view?.pauseView.transform.a > 0.1 || view?.springIndicator.transform.a > 0.1 {
                view.pause()
            }
        }
    }
    
    func audioDidFinish(notification: NSNotification) {
        let index = notification.object as! Int
        
        if songPost != nil && songPost?.isEqual(audio.songPosts[index]) == true {
            view.pause()
        } else if songPost == nil && song != nil && song!.isEqual(audio.currentSong) {
            view.pause()
        }
    }
    
    func toggle() {
        if songPost != nil && songPost!.isEqual(audio.currentSongPost) {
            audio.toggle()
        } else if songPost == nil && song != nil && song!.isEqual(audio.currentSong) {
            audio.toggle()
        } else {
            if song?.previewData == nil {
                view.load()
            }
            
            BFTask(delay: 0).continueWithBlock({ (task) -> AnyObject! in
                return self.audio.play(self.songPost!)
            })
        }
    }
    
    func updateTime() {
        if (songPost != nil && songPost!.isEqual(audio.currentSongPost) && audio.player != nil)
            || (songPost == nil && song != nil && song!.isEqual(audio.currentSong) && audio.player != nil) {
            view?.timePercent = CGFloat(audio.player!.currentTime / audio.player!.duration)
        } else if view?.timePercent != 0 {
            view?.timePercent = 0
        }
    }
}
