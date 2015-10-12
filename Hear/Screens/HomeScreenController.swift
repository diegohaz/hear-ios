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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view = UINib(nibName: "HomeScreenView", bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as? UIView
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }


}

