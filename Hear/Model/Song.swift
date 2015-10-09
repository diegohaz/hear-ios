//
//  Song.swift
//  Hear
//
//  Created by Juliana Zilberberg on 9/28/15.
//  Copyright (c) 2015 Hear. All rights reserved.
//

import UIKit

class Song {
    var id: Int
    var title: String
    var artist: String
    var cover: NSURL
    var preview: NSURL
    var distance: Float?
    
    init(id: Int, title: String, artist: String, cover: NSURL, preview: NSURL, distance: Float?) {
        self.id = id
        self.title = title
        self.artist = artist
        self.cover = cover
        self.preview = preview
        self.distance = distance
    }
}