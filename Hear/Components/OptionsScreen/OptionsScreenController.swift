//
//  OptionsScreenController.swift
//  Hear
//
//  Created by Diego Haz on 11/7/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

class OptionsScreenController: UIViewController {
    
    static let sharedInstance = OptionsScreenController(nibName: "OptionsScreen", bundle: nil)
    
    let audio = AudioManager.sharedInstance
    var song: Song?
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var actionSheet: UIView!
    @IBOutlet weak var songView: UIView!
    @IBOutlet weak var songButton: SongButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var removeArtistButton: UIButton!
    @IBOutlet weak var removeSongButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        modalPresentationStyle = .Custom
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss"))
        backgroundView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "dismiss"))
        cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss"))
        removeArtistButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removeArtistButtonDidTouch"))
        removeSongButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removeSongButtonDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songChanged", name: AudioManagerWillLoadNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songChanged", name: AudioManagerDidPlayNotification, object: nil)
        
        songChanged()
    }
    
    func songChanged() {
        guard let song = audio.currentSong where audio.queued() else {
            return
        }
        
        self.song = song
        
        songButton.controller.song = song
        songTitleLabel.text = song.title
        songArtistLabel.text = song.artist.name
        
        API.login().continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            guard let user = task.result as? User else { return nil }
            
            if song.user?.id == user.id {
                self.removeSongButton.setTitle("Delete Post", forState: .Normal)
            } else {
                self.removeSongButton.setTitle("Remove Song", forState: .Normal)
            }
            
            return nil
        })
    }
    
    func removeArtistButtonDidTouch() {
        guard let song = song else { return }
        
        HomeScreenController.sharedInstance.songCollectionView.controller.removeSong(song, removeArtist: true)
        dismiss()
    }
    
    func removeSongButtonDidTouch() {
        guard let song = song else { return }
        
        HomeScreenController.sharedInstance.songCollectionView.controller.removeSong(song)
        dismiss()
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
