//
//  HearButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class HearButtonController: NSObject {
    var view: HearButtonView!
    
    init(view: HearButtonView) {
        super.init()
        
        self.view = view
        self.view.addTarget(self, action: "viewDidTouch", forControlEvents: .TouchUpInside)
    }
    
    func viewDidTouch() {
        print("HearButton has been pressed")
    }
}
