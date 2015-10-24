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
            
            let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTime", userInfo: [], repeats: true)
            
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    init(view: SongButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidToggle", name: AudioManagerPlayNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidToggle", name: AudioManagerPauseNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidFinish:", name: AudioManagerFinishNotification, object: nil)
    }
    
    func viewDidTouch() {
        view.bounce()
        toggle()
    }
    
    func audioDidToggle() {
        if song != nil && audio.current(song!) == true && audio.player?.playing == true {
            view.play()
        } else if song != nil && audio.current(song!) == true {
            view.pause()
        } else if view.pauseView.transform.a > 0.1 {
            view.pause()
        }
    }
    
    func audioDidFinish(notification: NSNotification) {
        let index = notification.object as! Int
        
        if song != nil && audio.songs[index].id == song!.id {
            view.pause()
        }
    }
    
    func toggle() {
        if audio.current(song!) == true && audio.player?.playing == true {
            audio.pause()
        } else if audio.current(song!) {
            audio.play()
        } else {
            if song?.previewData == nil {
                view.load()
            }
            
            BFTask(delay: 0).continueWithBlock({ (task) -> AnyObject! in
                return self.audio.play(self.song!)
            }).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                //self.view.loadingView.hidden = true
                
                return task
            })
        }
    }
    
    func updateTime() {
        if audio.current(song!) && audio.player != nil {
            view?.timePercent = CGFloat(audio.player!.currentTime / audio.player!.duration)
        } else if view?.timePercent != 0 {
            view?.timePercent = 0
        }
    }
}
