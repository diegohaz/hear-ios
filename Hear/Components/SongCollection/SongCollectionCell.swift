//
//  RadarCell.swift
//  Hear
//
//  Created by Diego Haz on 9/30/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class SongCollectionCell: UICollectionViewCell {
    @IBOutlet weak var songButton: SongButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    
    override func prepareForReuse() {
        transform = CGAffineTransformMakeScale(1, 1)
        hidden = false

        songButton.songImageView.image = nil
        songButton.timePercent = 0
    }
    
    func fade(view: UIScrollView) {
        let maxY = frame.maxY
        let minY = frame.minY
        let limitTop = view.contentOffset.y + 64
        let limitBottom = view.contentOffset.y + view.bounds.height - 64
        
        if maxY > limitBottom {
            let scale = 1 - (maxY - limitBottom)/bounds.height
            contentView.alpha = pow(scale, 6)
            transform = CGAffineTransformMakeScale(scale, scale)
        } else if minY < limitTop {
            let scale = 1 - (limitTop - minY)/bounds.height
            contentView.alpha = pow(scale, 6)
            transform = CGAffineTransformMakeScale(scale, scale)
        } else if contentView.alpha < 1 {
            contentView.alpha = 1
            transform = CGAffineTransformMakeScale(1, 1)
        }
    }
}
