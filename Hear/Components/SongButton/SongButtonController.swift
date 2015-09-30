//
//  SongButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class SongButtonController: NSObject {
    var view: SongButtonView!
    
    init(view: SongButtonView) {
        super.init()
        
        self.view = view
    }
}
