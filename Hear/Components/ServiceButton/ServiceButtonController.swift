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
    
    var url: NSURL?
    
    init(view: ServiceButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentSongChanged", name: "play", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioFinished", name: "audioFinished", object: nil)
    }
    
    func viewDidTouch() {
        view.bounce()
        
        if let url = url {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func audioFinished() {
        view.hidden = true
        url = nil
    }
    
    func currentSongChanged() {
        view.hidden = false
        view.appear()
        
        url = AudioManager.sharedInstance.getCurrentSong()?.url
    }
}
