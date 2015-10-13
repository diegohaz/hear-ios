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
    var index = 0
    var audio = AudioManager.sharedInstance
    var song: Song? {
        didSet {
            view.songTitleLabel?.text = song?.title
            view.songArtistLabel.text = song?.artist
            
            song?.loadCover().continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                self.view.songImageView.image = UIImage(data: task.result as! NSData)
                
                return task
            })
            
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTime", userInfo: [], repeats: true)
        }
    }
    
    init(view: SongButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
    }
    
    func viewDidTouch() {
        view.bounce()
        toggle()
    }
    
    func toggle() {
        if audio.current(song!) == true && audio.player?.playing == true {
            audio.pause()
        } else if audio.current(song!) {
            audio.play()
        } else {
            if song?.previewData == nil {
                view.loadingView.hidden = false
            }
            
            BFTask(delay: 0).continueWithBlock({ (task) -> AnyObject! in
                return self.audio.play(self.song!)
            }).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                self.view.loadingView.hidden = true
                
                return task
            })
        }
    }
    
    func updateTime() {
        if audio.current(song!) && audio.player != nil {
            view.timePercent = CGFloat(audio.player!.currentTime / audio.player!.duration)
        } else if view.timePercent != 0 {
            view.timePercent = 0
        }
    }
}
