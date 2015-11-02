//
//  InputButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class InputButtonController: NSObject {
    weak var view: InputButton!
    
    init(view: InputButton) {
        super.init()
        
        self.view = view
    }
}
