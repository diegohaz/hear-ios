//
//  SearchSongScreenController.swift
//  Hear
//
//  Created by Diego Haz on 10/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

class SearchSongScreenController: UIViewController {
    
    static let sharedInstance = SearchSongScreenController()
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchSongTextField: SearchSongTextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CoverVertical
        
        view = UINib(nibName: "SearchSongScreenView", bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as? UIView
        
        searchSongTextField.becomeFirstResponder()
        cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "cancelButtonDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cancelButtonDidTouch", name: SearchSongCollectionDidPlaceSongNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cancelButtonDidTouch", name: SearchSongCollectionDidPrepareToPlaceSongNotification, object: nil)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
    func cancelButtonDidTouch() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
