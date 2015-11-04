//
//  SearchSongCollectionCell.swift
//  Hear
//
//  Created by Diego Haz on 10/24/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class SearchSongCollectionCell: UICollectionViewCell {
    @IBOutlet weak var songButton: SongButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var placeButton: GenericButton!
    @IBOutlet weak var placeButtonMask: UIImageView!
    
    override var selected: Bool {
        didSet {
            if selected {
                backgroundColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
                placeButtonMask.tintColor = backgroundColor
                placeButtonMask.hidden = false
                placeButton.hidden = false
                placeButton.userInteractionEnabled = true
            } else {
                backgroundColor = UIColor.whiteColor()
                placeButtonMask.hidden = true
                placeButton.hidden = true
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        songButton.songImageView.image = nil
        songButton.timePercent = 0
    }
    
    func select() {
        placeButton.appear()
        songButton.bounce()
    }
}
