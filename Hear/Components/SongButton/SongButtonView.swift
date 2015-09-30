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
    @IBOutlet weak var songRoundView: SongRoundView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        loadNib()
        controller = SongButtonController(view: self)
    }
    
    private func loadNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
    }
}
