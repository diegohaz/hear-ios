//
//  RadarView.swift
//  Hear
//
//  Created by Diego Haz on 9/30/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class RadarView: UICollectionView {
    var controller: RadarController!
    var activityIndicatorView: UIActivityIndicatorView!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        controller = RadarController(view: self)
        
        backgroundColor = UIColor.whiteColor()
        
//        let view = UIView()
//        view.frame = CGRectMake(bounds.width/2, 0, 5, 5)
//        view.backgroundColor = UIColor.hearPrimaryColor()
//        view.layer.cornerRadius = 2.5
//        
//        UIView.animateWithDuration(2, delay: 0.5, options: .Repeat, animations: { () -> Void in
//            view.transform = CGAffineTransformMakeScale(100, 100)
//            view.alpha = 0
//        }) { (finished) -> Void in
//            print("aa")
//        }
//        
//        addSubview(view)
    }
}
