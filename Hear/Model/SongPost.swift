//
//  SongPost.swift
//  Hear
//
//  Created by Diego Haz on 10/24/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class SongPost {
    var song: Song
    var distance: CGFloat
    
    init(song: Song, distance: CGFloat) {
        self.song = song
        self.distance = distance
    }
}
