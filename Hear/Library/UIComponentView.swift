//
//  UIComponentView.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class UIComponentView: UIView {
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let nib = UINib(nibName: String(self.dynamicType), bundle: NSBundle(forClass: self.dynamicType))
        
        view = nib.instantiateWithOwner(self, options: nil)[0] as? UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addSubview(view)
    }

}
