//
//  HearButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class HearButtonController: NSObject {
    weak var view: HearButtonView!
    
    init(view: HearButtonView) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
    }
    
    func viewDidTouch() {
        view.bounce()
    }
}
