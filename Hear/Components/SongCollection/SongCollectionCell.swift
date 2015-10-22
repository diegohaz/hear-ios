//
//  RadarCell.swift
//  Hear
//
//  Created by Diego Haz on 9/30/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class SongCollectionCell: UICollectionViewCell {
    var songButtonView: SongButtonView!
    var reloadCount = 0
    
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
    
    override func prepareForReuse() {
        songButtonView.songImageView.image = nil
        songButtonView.loadingView.hidden = true
        songButtonView.timePercent = 0
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
