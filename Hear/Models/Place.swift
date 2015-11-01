//
//  Place.swift
//  Hear
//
//  Created by Diego Haz on 11/1/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class Place {
    var name: String
    var radius: CGFloat
    var parent: Place?
    
    init(name: String, radius: CGFloat, parent: Place? = nil) {
        self.name = name
        self.radius = radius
        self.parent = parent
    }
}
