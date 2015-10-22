//
//  InputButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class InputButtonController: NSObject {
    weak var view: InputButtonView!
    
    init(view: InputButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
    }
    
    func viewDidTouch() {
        view.bounce()
        
HomeScreenController.sharedInstance.presentViewController(SearchSongController(), animated: true, completion: nil)
    }
}
