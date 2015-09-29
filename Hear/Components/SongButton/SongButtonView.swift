//
//  SongButtonView.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class SongButtonView: UIButton {
    
    var controller: SongButtonController!
    @IBOutlet weak var newStoriesIndicator: UIView!
    @IBOutlet weak var songRound: SongRound!

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
        
        controller = SongButtonController(view: self)
    }
}
