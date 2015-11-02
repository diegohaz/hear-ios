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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.login()
        
        view = UINib(nibName: "HomeScreenView", bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as? UIView
        
        inputButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "inputButtonDidTouch"))
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }

    func inputButtonDidTouch() {
        presentViewController(SearchSongScreenController.sharedInstance, animated: true, completion: nil)
    }
}

