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
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let hitTestEdgeInsets = UIEdgeInsetsMake(-32, -32, -32, -32)
        let hitFrame = UIEdgeInsetsInsetRect(bounds, hitTestEdgeInsets)
        return CGRectContainsPoint(hitFrame, point)
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
}
