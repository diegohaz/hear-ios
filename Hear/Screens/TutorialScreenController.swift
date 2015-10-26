//
//  TutorialScreenController.swift
//  Hear
//
//  Created by Diego Haz on 10/26/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class TutorialScreenController: UIViewController {
    @IBOutlet weak var inputButton: InputButtonView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: GenericButton!
    @IBOutlet weak var songView: UIView!
    
    var songButton: SongCollectionCell?
    var song: Song?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = UINib(nibName: "TutorialScreenView", bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as? UIView
        songButton = UINib(nibName: "SongCollectionCell", bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as? SongCollectionCell
        
        songView.addSubview(songButton!)
        
        inputButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "inputButtonDidTouch"))
        locationButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "locationButtonDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songWasPosted:", name: LazyPostSongNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged", name: LocationManagerNotification, object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if song == nil {
            welcomeLabel.rise()
            inputButton.pulsing = true
        } else {
            welcomeLabel.hidden = true
            inputButton.pulsing = false
            
            songView.appear(completion: { (finished) -> Void in
                self.songLabel.rise(completion: { (finished) -> Void in
                    self.songLabel.disappear(3, completion: { (finished) -> Void in
                        self.locationLabel.rise(completion: { (finished) -> Void in
                            self.locationButton.appear()
                        })
                    })
                })
            })
        }
    }
    
    func inputButtonDidTouch() {
        presentViewController(SearchSongScreenController.sharedInstance, animated: true, completion: nil)
    }
    
    func songWasPosted(notification: NSNotification) {
        song = notification.object as? Song
        songButton?.songButtonView.controller.song = song
        songButton?.songTitleLabel.text = song!.title
        songButton?.songArtistLabel.text = song!.artist
        
        songButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "songButtonDidTouch"))
    }
    
    func songButtonDidTouch() {
        songButton?.bounce()
        songButton?.songButtonView.controller.toggle()
    }
    
    func locationButtonDidTouch() {
        LocationManager.sharedInstance.request()
    }
    
    func locationChanged() {
        dismissViewControllerAnimated(false, completion: nil)
    }

}