//
//  SongButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import AVFoundation

class SongButtonController: NSObject {
    var view: SongButtonView!
    var audioPlayer = AVPlayer()
    
    init(view: SongButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
    }
    
    func viewDidTouch() {
        view.bounce()
        let alertSound = NSURL(string: "http://a1326.phobos.apple.com/us/r1000/042/Music4/v4/81/3c/58/813c58c0-8692-8587-0bd9-e966e917e9be/mzaf_3230721061449444105.plus.aac.p.m4a")!
        view.songRoundView.loadingView.hidden = false
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: alertSound)) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try! AVAudioSession.sharedInstance().setActive(true)
                self.audioPlayer = AVPlayer(URL: alertSound)
                self.audioPlayer.play()
            })
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "dada", userInfo: [], repeats: true)
        
        task.resume()
    }

    func dada() {
        if let currentItem = audioPlayer.currentItem {
            if audioPlayer.currentTime().seconds > 0 {
                view.songRoundView.timePercent = CGFloat(audioPlayer.currentTime().seconds / currentItem.duration.seconds)
                self.view.songRoundView.loadingView.hidden = true
            }
        }
    }
}
