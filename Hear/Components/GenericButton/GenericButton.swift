//
//  GenericButton.swift
//  Hear
//
//  Created by Diego Haz on 10/26/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class GenericButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.hearPrimaryColor()
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        clipsToBounds = true
    }
    
    override func drawRect(rect: CGRect) {
        layer.cornerRadius = bounds.height/2
    }
}
