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
    
    override func prepareForReuse() {
        songButton.songImageView.image = nil
        songButton.timePercent = 0
    }

}
