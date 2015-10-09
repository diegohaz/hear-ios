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
    var songPreview: NSURL! {
        didSet {
            loadSong(nil)
        }
    }
    
    var data: NSData?
    
    init(view: SongButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
    }
    
    func viewDidTouch() {
        view.bounce()
        
        if data != nil {
            self.audioPlayer.load(data!)
            self.audioPlayer.play()
            
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTime", userInfo: [], repeats: true)
        } else {
            view.loadingView.hidden = false
            
            loadSong({ () -> Void in
                self.audioPlayer.load(self.data!)
                self.audioPlayer.play()
                self.view.loadingView.hidden = true
            })
        }
    }
    
    func loadSong(callback: (() -> Void)?) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = 1
        configuration.requestCachePolicy = .ReturnCacheDataElseLoad
        let session = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(NSURLRequest(URL: songPreview)) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try! AVAudioSession.sharedInstance().setActive(true)
                self.data = data
                callback?()
                print(self.view.songTitleLabel.text)
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
