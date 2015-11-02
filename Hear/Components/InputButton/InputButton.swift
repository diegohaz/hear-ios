//
//  InputButton.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class InputButton: UIButton {
    var controller: InputButtonController!
    
    @IBInspectable var pulsing: Bool = false {
        didSet {
            if pulsing {
                startPulsing()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        controller = InputButtonController(view: self)
    }
    
    func startPulsing() {
        UIView.animateWithDuration(0.2, delay: 1, options: [.AllowUserInteraction, .CurveEaseInOut], animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }, completion: { (finished) -> Void in
                UIView.animateWithDuration(0.1, delay: 0, options: [.AllowUserInteraction, .CurveEaseInOut], animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                    
                    if self.pulsing {
                        self.startPulsing()
                    }
                    }, completion: nil)
        })
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
