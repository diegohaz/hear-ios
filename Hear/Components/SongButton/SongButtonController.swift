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
    var audioPlayer = AudioManager.sharedInstance
    var alertSound: NSURL!
    var data: NSData?
    
    init(view: SongButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
    }
    
    func viewDidTouch() {
        view.bounce()
        view.loadingView.hidden = false
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: alertSound)) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try! AVAudioSession.sharedInstance().setActive(true)
                self.data = data
                self.audioPlayer.load(data!)
                self.audioPlayer.play()
                
                NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTime", userInfo: [], repeats: true)
                self.view.loadingView.hidden = true
            })
        }
        
        task.resume()
    }

    func updateTime() {
        if audioPlayer.player.data == self.data {
            view.timePercent = CGFloat(audioPlayer.player.currentTime / audioPlayer.player.duration)
        } else {
            view.timePercent = 0
        }
    }
}
