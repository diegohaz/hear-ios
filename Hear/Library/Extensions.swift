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
    
    func bounce() {
        UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                })
        }
    }
    
    func appear() {
        hidden = false
        self.transform = CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.1, 1.1)
        }) { (finished) -> Void in
            UIView.animateWithDuration(0.05, animations: { () -> Void in
                self.transform = CGAffineTransformMakeScale(1, 1)
            })
        }
    }
}
