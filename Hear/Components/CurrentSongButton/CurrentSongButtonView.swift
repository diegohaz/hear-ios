//
//  CurrentSongButtonView.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class CurrentSongButtonView: UIButton {
    
    var controller: CurrentSongButtonController!
    var songRoundView: SongRoundView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        controller = CurrentSongButtonController(view: self)
        songRoundView = SongRoundView(frame: bounds)
        songRoundView.backgroundColor = UIColor.clearColor()
        addSubview(songRoundView)
        transform = CGAffineTransformMakeScale(0, 0)
    }
    
    override func awakeFromNib() {
        bounce(0.3)
    }
    
    func bounce(duration: Double = 0.15) {
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                })
        }
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let hitTestEdgeInsets = UIEdgeInsetsMake(-32, -32, -32, -32)
        let hitFrame = UIEdgeInsetsInsetRect(bounds, hitTestEdgeInsets)
        return CGRectContainsPoint(hitFrame, point)
    }
}
