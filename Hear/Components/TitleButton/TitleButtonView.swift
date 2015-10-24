//
//  TitleButtonView.swift
//  Hear
//
//  Created by Diego Haz on 10/9/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

public let LoadingNotification = "LocadingNotification"
public let TitleNotification = "TitleNotification"

@IBDesignable class TitleButtonView: UIButton {
    var springIndicator: SpringIndicator!
    var loading: Bool = false {
        didSet {
            if loading {
                setTitle("", forState: .Normal)
                springIndicator.startAnimation()
            } else {
                setTitle(title, forState: .Normal)
                springIndicator.stopAnimation(false)
            }
        }
    }
    
    var title: String = "" {
        didSet {
            if !loading {
                setTitle(title, forState: .Normal)
            }
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
    
    func setup() {
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        backgroundColor = UIColor.hearPrimaryColor()
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleLabel?.lineBreakMode = NSLineBreakMode.ByClipping
        layer.cornerRadius = bounds.height/2
        
        springIndicator = SpringIndicator(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        springIndicator.frame.origin.x = bounds.width/2 - springIndicator.bounds.width/2
        springIndicator.frame.origin.y = bounds.height/2 - springIndicator.bounds.height/2
        springIndicator.lineCap = true
        springIndicator.lineColor = UIColor.whiteColor()
        springIndicator.lineWidth = 2
        
        addSubview(springIndicator)
        
        loading = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "titleChanged:", name: TitleNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadingStatusChanged:", name: LoadingNotification, object: nil)
        
    }
    
    func titleChanged(notification: NSNotification) {
        title = notification.object as! String
    }
    
    func loadingStatusChanged(notification: NSNotification) {
        loading = notification.object as! Bool
    }
}
