//
//  ServiceButtonView.swift
//  Hear
//
//  Created by Diego Haz on 10/22/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class ServiceButtonView: UIButton {
    var controller: ServiceButtonController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        controller = ServiceButtonController(view: self)
        hidden = true
    }

}