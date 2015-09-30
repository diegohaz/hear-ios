//
//  CurrentSongButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class CurrentSongButtonController: NSObject {
    var view: CurrentSongButtonView!
    
    init(view: CurrentSongButtonView) {
        super.init()
        
        self.view = view
        self.view.addTarget(self, action: "viewDidTouch", forControlEvents: .TouchUpInside)
    }
    
    func viewDidTouch() {
        print("HearButton has been pressed")
    }
}
