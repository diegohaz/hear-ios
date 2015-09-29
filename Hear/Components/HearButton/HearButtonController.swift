//
//  HearButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class HearButtonController: UIComponentController<HearButtonView> {
    
    required init(view: HearButtonView) {
        super.init(view: view)
        
        view.addTarget(self, action: "viewDidTouch:", forControlEvents: .TouchUpInside)
    }
    
    func viewDidTouch(sender: HearButtonView) {
        print("HearButton has been pressed")
    }
}
