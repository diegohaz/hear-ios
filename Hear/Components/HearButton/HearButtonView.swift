//
//  HearButtonView.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class HearButtonView: UIComponentView {
    override func setup() {
        super.setup()
        
        let controller = HearButtonController()
        controller.view = self
    }
}
