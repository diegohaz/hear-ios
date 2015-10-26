//
//  Extensions.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func hearPrimaryColor() -> UIColor {
        return UIColor(red: 212/255, green: 20/255, blue: 90/255, alpha: 1)
    }
    
    static func hearSecondaryColor() -> UIColor {
        return UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
    }
    
    static func hearGrayColor() -> UIColor {
        return UIColor(white: 0, alpha: 0.1)
    }
    
}

extension UIView {
    func loadNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
    }
    
    func bounce(scale: CGFloat = 1.2, completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(scale, scale)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: completion)
        }
    }
    
    func appear(peak: CGFloat = 1.1, completion: ((Bool) -> Void)? = nil) {
        hidden = false
        alpha = 0
        transform = CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.alpha = 1
            self.transform = CGAffineTransformMakeScale(peak, peak)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.05, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: completion)
        }
    }
    
    func disappear(delay: Double = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(0.2, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
            self.alpha = 0
            }) { (finished) -> Void in
                self.hidden = true
                completion?(finished)
        }
    }
    
    func rise(from: CGFloat = 100, completion: ((Bool) -> Void)? = nil) {
        hidden = false
        alpha = 0
        transform = CGAffineTransformMakeTranslation(0, 100)
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.alpha = 1
            self.transform = CGAffineTransformMakeTranslation(0, 0)
            }, completion: completion)
    }
}
