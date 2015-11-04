//
//  HomeScreenController.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class HomeScreenController: UIViewController {
    
    static let sharedInstance = HomeScreenController()
    @IBOutlet weak var inputButton: InputButton!
    @IBOutlet weak var titleButton: TitleButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.login()
        
        view = UINib(nibName: "HomeScreenView", bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as? UIView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionBeginLoadingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionEndLoadingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionPullNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionPlaceDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTitle:", name: SongCollectionDistanceDidChangeNotification, object: nil)
        
        inputButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "inputButtonDidTouch"))
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }

    func inputButtonDidTouch() {
        inputButton.bounce { (finished) -> Void in
            self.presentViewController(SearchSongScreenController.sharedInstance, animated: true, completion: nil)
        }
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

