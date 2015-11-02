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
            let size: ImageSize = view.bounds.width < 50 ? .Small : .Medium
            let task = song?.image.load(size, rounded: true)
            
            task?.continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                if song?.id == self.song?.id {
                    self.view.songImageView.image = task.result as? UIImage
                }
                
                return nil
            })
            
            view.pause()
        }
    }
    
    init(view: SongButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidPlay", name: AudioManagerDidPlayNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidPause", name: AudioManagerDidPauseNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidPause", name: AudioManagerDidFinishNotification, object: nil)
        
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTime", userInfo: [], repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func viewDidTouch() {
        view.bounce()
        toggle()
    }
    
    func audioDidPlay() {
        if song != nil && audio.current(song!) {
            view.load()
        }
    }
    
    func audioDidPause() {
        if song != nil && audio.current(song!) {
            view.pause()
        }
    }
    
    func toggle() {
        guard let song = song else {
            return
        }
        
        if audio.playing(song) {
            audio.pause()
        } else if audio.current(song) {
            audio.play()
        } else {
            audio.play(song)
        }
    }
    
    func updateTime() {
        if song != nil && audio.playing(song!) && audio.currentTime() > 0 {
            view?.timePercent = CGFloat(audio.currentTime() / audio.duration())
            view?.play()
        } else if view?.timePercent != 0 {
            view?.timePercent = 0
        }
    }
}
