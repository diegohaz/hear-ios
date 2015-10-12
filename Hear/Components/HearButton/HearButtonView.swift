//
//  HearButtonView.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class HearButtonView: UIButton {
    var controller: HearButtonController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        controller = HearButtonController(view: self)
    }
    
    override func drawRect(rect: CGRect) {
        let disk = UIBezierPath(ovalInRect: rect)
        UIColor.hearPrimaryColor().setFill()
        disk.fill()
        
        let stroke = UIBezierPath(arcCenter: CGPoint(x: rect.width/2, y: rect.height/2), radius: rect.width/(2.67*2), startAngle: 0, endAngle: 500, clockwise: true)
        UIColor.whiteColor().setStroke()
        stroke.lineWidth = rect.width / 64
        stroke.stroke()
        
        let point = UIBezierPath(arcCenter: CGPoint(x: rect.width/2, y: rect.height/2), radius: rect.width/(4.57*2), startAngle: 0, endAngle: 500, clockwise: true)
        UIColor.whiteColor().setFill()
        point.fill()
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let hitTestEdgeInsets = UIEdgeInsetsMake(-24, -24, -24, -24)
        let hitFrame = UIEdgeInsetsInsetRect(bounds, hitTestEdgeInsets)
        return CGRectContainsPoint(hitFrame, point)
    }
}
