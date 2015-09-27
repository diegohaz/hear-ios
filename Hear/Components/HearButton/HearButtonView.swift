//
//  HearButtonView.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class HearButtonView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let controller = HearButtonController()
        controller.view = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        UIView.animateWithDuration(0.1, delay: 0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.15, 1.15)
        }, completion: nil)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        UIView.animateWithDuration(0.1, delay: 0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    override func drawRect(rect: CGRect) {
        let disk = UIBezierPath(ovalInRect: rect)
        UIColor(red: 212/256, green: 20/256, blue: 90/256, alpha: 1).setFill()
        disk.fill()
        
        let stroke = UIBezierPath(arcCenter: CGPoint(x: rect.width/2, y: rect.height/2), radius: rect.width/(2.67*2), startAngle: 0, endAngle: 500, clockwise: true)
        UIColor(white: 1, alpha: 1).setStroke()
        stroke.lineWidth = rect.width / 64
        stroke.stroke()
        
        let point = UIBezierPath(arcCenter: CGPoint(x: rect.width/2, y: rect.height/2), radius: rect.width/(4.57*2), startAngle: 0, endAngle: 500, clockwise: true)
        UIColor(white: 1, alpha: 1).setFill()
        point.fill()
    }
}
