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
    
    func fade(view: UIScrollView) {
        let maxY = frame.maxY
        let minY = frame.minY
        let limitTop = view.contentOffset.y + 64
        let limitBottom = view.contentOffset.y + view.bounds.height - 64
        
        if maxY > limitBottom {
            contentView.alpha = 0.5 - (maxY - limitBottom)/bounds.height
            songButtonView.songRoundView.transform = CGAffineTransformMakeScale(contentView.alpha + 0.5, contentView.alpha + 0.5)
        } else if minY < limitTop {
            contentView.alpha = 0.5 - (limitTop - minY)/bounds.height
            songButtonView.songRoundView.transform = CGAffineTransformMakeScale(contentView.alpha + 0.5, contentView.alpha + 0.5)
        } else {
            contentView.alpha = 1
            songButtonView.songRoundView.transform = CGAffineTransformMakeScale(1, 1)
        }
    }
}
