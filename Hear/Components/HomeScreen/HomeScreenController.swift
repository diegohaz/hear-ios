//
//  HomeScreenController.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class HomeScreenController: UIViewController {
    
    static let sharedInstance = HomeScreenController(nibName: "HomeScreen", bundle: nil)
    
    let audio = AudioManager.sharedInstance
    
    @IBOutlet weak var songCollectionView: SongCollectionView!
    @IBOutlet weak var inputButton: InputButton!
    @IBOutlet weak var titleButton: TitleButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.login()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionBeginLoadingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionEndLoadingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionPullNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionPlaceDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionDistanceDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songChanged", name: AudioManagerDidPlayNotification, object: nil)
        
        inputButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "inputButtonDidTouch"))
        optionsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "optionsButtonDidTouch"))
        
        optionsButton.hidden = true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }

    func inputButtonDidTouch() {
        inputButton.bounce { (finished) -> Void in
            self.presentViewController(SearchSongScreenController.sharedInstance, animated: true, completion: nil)
        }
    }
    
    func optionsButtonDidTouch() {
        presentViewController(OptionsScreenController.sharedInstance, animated: true, completion: nil)
    }
    
    func songChanged() {
        if audio.currentSong == nil || !audio.queued() {
            optionsButton.hidden = true
            return
        }
        
        optionsButton.expand()
    }
    
    func changeTitle(notification: NSNotification) {
        titleButton.hidden = false
        
        switch notification.name {
        case SongCollectionBeginLoadingNotification:
            titleButton.loading = true
            break
        case SongCollectionEndLoadingNotification:
            titleButton.loading = false
            break
        case SongCollectionPullNotification:
            titleButton.title = "Pull to refresh"
            break
        case SongCollectionPlaceDidChangeNotification:
            titleButton.place = notification.object as? String
            break
        case SongCollectionDistanceDidChangeNotification:
            titleButton.distance = notification.object as? String
            break
        default: break
        }
    }
}

