//
//  UIComponentController.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class UIComponentController<T: UIView>: NSObject {
    var view: T!
    
    required init(view: T) {
        super.init()
        
        self.view = view
    }
}