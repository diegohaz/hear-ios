//
//  ServiceButtonView.swift
//  Hear
//
//  Created by Diego Haz on 10/22/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class ServiceButtonView: UIButton {
    var controller: ServiceButtonController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        controller = ServiceButtonController(view: self)
        hidden = true
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let hitTestEdgeInsets = UIEdgeInsetsMake(-24, -24, -24, -24)
        let hitFrame = UIEdgeInsetsInsetRect(bounds, hitTestEdgeInsets)
        return CGRectContainsPoint(hitFrame, point)
    }

}