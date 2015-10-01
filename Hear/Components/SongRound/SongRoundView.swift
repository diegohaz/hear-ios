//
//  SongRoundView.swift
//  Hear
//
//  Created by Diego Haz on 9/28/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class SongRoundView: UIView {
    @IBOutlet weak var playbackGuide: UIView!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBInspectable var timePercent: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var controller: SongRoundController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        userInteractionEnabled = false
        loadNib()
        controller = SongRoundController(view: self)
        loadingView.layer.cornerRadius = loadingView.bounds.width/2
    }
    
    private func loadNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
    }

    override func drawRect(rect: CGRect) {
        songImageView.layer.cornerRadius = songImageView.frame.size.width/2
        songImageView.clipsToBounds = true
        
        let circle = UIBezierPath(ovalInRect: playbackGuide.frame)
        UIColor(white: 0, alpha: 0.1).setStroke()
        circle.lineWidth = 2
        circle.stroke()
        
        let centerX = playbackGuide.frame.origin.x + playbackGuide.bounds.width/2
        let centerY = playbackGuide.frame.origin.y + playbackGuide.bounds.height/2
        let playback = UIBezierPath(
            arcCenter: CGPoint(x: centerX, y: centerY),
            radius: playbackGuide.bounds.width/2,
            startAngle: -90 * CGFloat(M_PI)/180,
            endAngle: ((timePercent * 360) - 90) * CGFloat(M_PI)/180,
            clockwise: true
        )
        UIColor.hearSecondaryColor().setStroke()
        playback.lineCapStyle = CGLineCap.Round
        playback.lineWidth = 2
        playback.stroke()
    }

}
