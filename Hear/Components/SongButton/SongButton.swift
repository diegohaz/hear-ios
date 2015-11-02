//
//  SongButton.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

@IBDesignable class SongButton: UIButton {
    
    var controller: SongButtonController!
    @IBOutlet weak var newStoriesIndicator: UIView!
    @IBOutlet weak var songRoundView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var playbackGuide: UIView!
    @IBOutlet weak var pauseView: UIImageView!
    @IBOutlet weak var springIndicator: SpringIndicator!
    
    private weak var currentCover: UIView!
    
    @IBInspectable var timePercent: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
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
        loadNib()
        controller = SongButtonController(view: self)
        
        currentCover = songImageView
        pauseView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
        springIndicator.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
    }
    
    func load() {
        if self.currentCover == self.springIndicator {
            return
        }
        
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.songImageView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
            self.pauseView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
            }) { (finished) -> Void in
                self.springIndicator.startAnimation()
                self.currentCover = self.springIndicator
                
                UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.springIndicator.transform = CGAffineTransformMakeScale(1, 1)
                    self.songImageView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                    self.pauseView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                    }, completion: nil)
        }
    }
    
    func play() {
        if self.currentCover == self.pauseView {
            return
        }
        
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.springIndicator.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
            self.songImageView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
            }) { (b) -> Void in
                self.springIndicator.stopAnimation(false)
                self.currentCover = self.pauseView
                
                UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.pauseView.transform = CGAffineTransformMakeScale(1, 1)
                    self.springIndicator.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                    self.songImageView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                    }, completion: nil)
        }
    }
    
    func pause() {
        if self.currentCover == self.songImageView {
            return
        }
        
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.springIndicator.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
            self.pauseView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
            }) { (b) -> Void in
                self.springIndicator.stopAnimation(false)
                self.currentCover = self.songImageView
                
                UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.songImageView.transform = CGAffineTransformMakeScale(1, 1)
                    self.springIndicator.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                    self.pauseView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                    }, completion: nil)
        }
    }
    
    override func drawRect(rect: CGRect) {
        songImageView.layer.cornerRadius = songImageView.bounds.width/2
        backgroundView.layer.cornerRadius = backgroundView.bounds.width/2
        
        let circleFrame = playbackGuide.frame
        let circle = UIBezierPath(ovalInRect: circleFrame)
        UIColor(white: 0, alpha: 0.1).setStroke()
        circle.lineWidth = 2
        circle.stroke()
        
        let centerX = circleFrame.origin.x + playbackGuide.bounds.width/2
        let centerY = circleFrame.origin.y + playbackGuide.bounds.height/2
        let playback = UIBezierPath(
            arcCenter: CGPoint(x: centerX, y: centerY),
            radius: playbackGuide.bounds.width/2,
            startAngle: -90 * CGFloat(M_PI)/180,
            endAngle: ((timePercent * 360) - 90) * CGFloat(M_PI)/180,
            clockwise: true
        )
        UIColor.hearSecondaryColor().setStroke()
        playback.lineCapStyle = CGLineCap.Round
        playback.lineWidth = circle.lineWidth
        playback.stroke()
        
        springIndicator.lineWidth = circle.lineWidth
    }
}
