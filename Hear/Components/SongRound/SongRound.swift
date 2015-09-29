//
//  SongRound.swift
//  Hear
//
//  Created by Diego Haz on 9/28/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class SongRound: UIView {
    @IBOutlet weak var playbackGuide: UIView!
    @IBOutlet weak var songImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let view = UIComponentUtils.loadXib(self)
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addSubview(view)
        
        userInteractionEnabled = false
        
        let url = NSURL(string: "http://lorempixel.com/\(Int(songImageView.frame.size.width * 3))/\(Int(songImageView.frame.size.height * 3))")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.songImageView.image = UIImage(data: data!)
                })
            }
        }
        
        task.resume()
    }

    override func drawRect(rect: CGRect) {
        songImageView.layer.cornerRadius = songImageView.frame.size.width/2
        songImageView.clipsToBounds = true
        
        let circle = UIBezierPath(ovalInRect: playbackGuide.frame)
        UIColor(white: 0, alpha: 0.1).setStroke()
        circle.lineWidth = 2
        circle.stroke()
        
        let arcCenter = CGPoint(x: playbackGuide.frame.origin.x + playbackGuide.bounds.width/2, y: playbackGuide.frame.origin.y + playbackGuide.bounds.height/2)
        let playback = UIBezierPath(arcCenter: arcCenter, radius: playbackGuide.bounds.width/2, startAngle: -90 * CGFloat(M_PI)/180, endAngle: 45 * CGFloat(M_PI)/180, clockwise: true)
        UIColor.hearSecondaryColor().setStroke()
        playback.lineCapStyle = CGLineCap.Round
        playback.lineWidth = 2
        playback.stroke()
    }

}
