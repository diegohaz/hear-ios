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
    @IBOutlet weak var inputButtonView: InputButtonView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = UINib(nibName: "HomeScreenView", bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as? UIView
        
        inputButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "inputButtonViewDidTouch"))
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }

    func inputButtonViewDidTouch() {
        AudioManager.sharedInstance.stop()
        presentViewController(SearchSongScreenController.sharedInstance, animated: true, completion: nil)
    }
}

