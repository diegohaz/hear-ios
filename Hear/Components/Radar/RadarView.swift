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
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func drawRect(rect: CGRect) {
        
        
        let button = UIButton()
        
        button.frame = CGRectMake(100, 100, 80, 80)
        button.backgroundColor = UIColor.hearPrimaryColor()
    }
    
    private func setup() {
        controller = RadarController(view: self)
        backgroundColor = UIColor.whiteColor()
    }
}
