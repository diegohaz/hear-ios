//
//  TitleButtonView.swift
//  Hear
//
//  Created by Diego Haz on 10/9/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class TitleButtonView: UIButton {
    var activityIndicatorView: UIActivityIndicatorView!
    var loading: Bool = false {
        didSet {
            if loading {
                setTitle("   ", forState: .Normal)
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    var title: String = "" {
        didSet {
            setTitle(title, forState: .Normal)
            sizeToFit()
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
        title = "   "
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicatorView.frame.origin.x = bounds.width/2 - activityIndicatorView.bounds.width/2
        activityIndicatorView.frame.origin.y = bounds.height/2 - activityIndicatorView.bounds.height/2 + 1
        
        addSubview(activityIndicatorView)
        
        loading = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeDistance:", name: "changeDistance", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startLoading:", name: "startLoading", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopLoading:", name: "stopLoading", object: nil)
        
    }
    
    func changeDistance(notification: NSNotification) {
        title = notification.object as! String
    }
    
    func startLoading(notification: NSNotification) {
        loading = true
        title = ""
    }
    
    func stopLoading(notification: NSNotification) {
        loading = false
        title = title + ""
    }
}
