//
//  SearchSongScreenController.swift
//  Hear
//
//  Created by Diego Haz on 10/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

let PostSongNotification = "PostSongNotification"

class SearchSongScreenController: UIViewController {
    
    static let sharedInstance = SearchSongScreenController()
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var searchSongTextField: SearchSongTextFieldView!
    
    var selectedSong: Song? {
        didSet {
            if selectedSong != nil {
                postButton.enabled = true
            } else {
                postButton.enabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CoverVertical
        
        view = UINib(nibName: "SearchSongScreenView", bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as? UIView
        
        searchSongTextField.becomeFirstResponder()
        cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "cancelButtonDidTouch"))
        postButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "postButtonDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songDidSelect:", name: SearchSongCollectionDidSelectNotification, object: nil)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
    func cancelButtonDidTouch() {
        AudioManager.sharedInstance.stop()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postButtonDidTouch() {
        guard let song = selectedSong else {
            return
        }
        
        selectedSong = nil
        cancelButtonDidTouch()
        NSNotificationCenter.defaultCenter().postNotificationName(LoadingNotification, object: true)
        
        ParseAPI.postSong(song, location: LocationManager.sharedInstance.location!).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            guard let song = task.result as? SongPost else {
                return task
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(LoadingNotification, object: false)
            NSNotificationCenter.defaultCenter().postNotificationName(PostSongNotification, object: song)
            
            return task
        })
    }
    
    func songDidSelect(notification: NSNotification) {
        if let song = notification.object as? Song {
            selectedSong = song
        } else {
            selectedSong = nil
        }
    }

}
