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
        let alertSound = NSURL(string: "http://a1945.phobos.apple.com/us/r1000/110/Music/61/c9/28/mzm.cjqyuuye.aac.p.m4a")!
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: alertSound)) { (data, response, error) -> Void in
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try! AVAudioSession.sharedInstance().setActive(true)
            self.audioPlayer = AVPlayer(URL: alertSound)
            self.audioPlayer.play()
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "dada", userInfo: [], repeats: true)
        
        task.resume()
    }

    func dada() {
        if let currentItem = audioPlayer.currentItem {
            view.songRoundView.timePercent = CGFloat(audioPlayer.currentTime().seconds / currentItem.duration.seconds)
        }
    }
}
