//
//  SongButtonView.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class SongButtonView: UIButton {
    
    var controller: SongButtonController!
    @IBOutlet weak var newStoriesIndicator: UIView!
    @IBOutlet weak var songRoundView: UIView!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var playbackGuide: UIView!
    @IBOutlet weak var loadingView: UIView!
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
    }
    
    override func drawRect(rect: CGRect) {
        loadingView.layer.cornerRadius = loadingView.bounds.width/2
        songImageView.layer.cornerRadius = songImageView.frame.size.width/2
        songImageView.clipsToBounds = true
        
        var circleFrame = playbackGuide.frame
        circleFrame.origin.y += 1
        
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
        playback.lineWidth = 2
        playback.stroke()
    }
}
