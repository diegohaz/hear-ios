//
//  ServiceButtonController.swift
//  Hear
//
//  Created by Diego Haz on 10/22/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class ServiceButtonController: NSObject {
    weak var view: ServiceButton!

    private var url: NSURL?
    
    init(view: ServiceButton) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songChanged", name: AudioManagerWillLoadNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songChanged", name: AudioManagerDidPlayNotification, object: nil)
        
        songChanged()
    }
    
    func viewDidTouch() {
        view.bounce()
        
        if let url = url {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func songChanged() {
        self.url = AudioManager.sharedInstance.currentSong?.serviceUrl
    }
}
