//
//  RadarCell.swift
//  Hear
//
//  Created by Diego Haz on 9/30/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class RadarCell: UICollectionViewCell {
    var songButtonView: SongButtonView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        songButtonView = SongButtonView(frame: self.bounds)
        contentView.addSubview(songButtonView)
    }
}
