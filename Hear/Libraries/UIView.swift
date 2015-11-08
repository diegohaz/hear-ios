//
//  UIView.swift
//  Hear
//
//  Created by Diego Haz on 11/1/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

extension UIView {
    func loadNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
    }
    
    func bounce(peak: CGFloat = 1.2, duration: Double = 0.15, delay: Double = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(peak, peak)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: completion)
        }
    }
    
    func expand(peak: CGFloat = 1.1, duration: Double = 0.2, delay: Double = 0, completion: ((Bool) -> Void)? = nil) {
        hidden = false
        alpha = 0
        transform = CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
            self.alpha = 1
            self.transform = CGAffineTransformMakeScale(peak, peak)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.05, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: completion)
        }
    }
    
    func pinch(duration: Double = 0.2, delay: Double = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.001, 0.001)
            }) { (finished) -> Void in
                self.hidden = true
                completion?(finished)
        }
    }
    
    func appear(duration: Double = 0.2, delay: Double = 0, completion: ((Bool) -> Void)? = nil) {
        hidden = true
        alpha = 0
        
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
            self.alpha = 1
            }) { (finished) -> Void in
                self.hidden = false
                completion?(finished)
        }
    }
    
    func hide(duration: Double = 0.2, delay: Double = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
            self.alpha = 0
            }) { (finished) -> Void in
                self.hidden = true
                completion?(finished)
        }
    }
    
    func rise(from: CGFloat = 100, duration: Double = 0.4, delay: Double = 0, completion: ((Bool) -> Void)? = nil) {
        hidden = false
        alpha = 0
        transform = CGAffineTransformMakeTranslation(0, from)
        
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
            self.alpha = 1
            self.transform = CGAffineTransformMakeTranslation(0, 0)
            }, completion: completion)
    }
    
    func startTrembling() {
        UIView.animateWithDuration(0.1) { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.1, 1.1)
        }
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.duration = 0.1
        animation.repeatCount = 2000
        animation.autoreverses = true
        animation.fromValue = -0.05
        animation.toValue = 0.05
        
        layer.addAnimation(animation, forKey: "trembling")
    }
    
    func stopTrembling() {
        transform = CGAffineTransformMakeScale(1, 1)
        layer.removeAnimationForKey("trembling")
    }
}
