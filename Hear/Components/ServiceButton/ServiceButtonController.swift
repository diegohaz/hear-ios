//
//  ServiceButtonController.swift
//  Hear
//
//  Created by Diego Haz on 10/22/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class ServiceButtonController: NSObject {
    weak var view: ServiceButtonView!

    private var url: NSURL?
    
    init(view: ServiceButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentSongChanged", name: AudioManagerPlayNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidFinish", name: AudioManagerPauseNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDidFinish", name: AudioManagerFinishNotification, object: nil)
    }
    
    func viewDidTouch() {
        view.bounce()
        
        if let url = url {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func audioDidFinish() {
        view.hidden = true
    }
    
    func currentSongChanged() {
        self.view.appear()
        self.url = AudioManager.sharedInstance.currentSong?.url
    }
}
