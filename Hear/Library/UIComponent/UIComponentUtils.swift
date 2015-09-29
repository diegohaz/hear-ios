//
//  UIComponentUtils.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class UIComponentUtils {
    
    static func loadXib<T: UIView>(view: UIView) -> T {
        return self.loadXib(view, nibName: String(view.dynamicType), bundle: NSBundle(forClass: view.dynamicType))
    }
    
    static func loadXib<T: UIView>(view: UIView, nibName: String, bundle: NSBundle?) -> T {
        let nib = UINib(nibName: nibName, bundle: bundle)
        let nibView = nib.instantiateWithOwner(view, options: nil)[0] as! T
        
        return nibView
    }

}
