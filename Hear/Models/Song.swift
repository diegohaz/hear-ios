//
//  Song.swift
//  Hear
//
//  Created by Juliana Zilberberg on 9/28/15.
//  Copyright (c) 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

class Song: NSObject {
    static private var songs = [String: Song]()
    
    var id: String
    var songId: String
    var serviceId: String
    
    var title: String
    var artist: Artist
    var image: Image
    var previewUrl: NSURL
    var serviceUrl: NSURL
    
    var user: User?
    var distance: CGFloat?
    
    private init(id: String, songId: String, serviceId: String, title: String, artist: Artist, image: Image, previewUrl: NSURL, serviceUrl: NSURL, user: User?, distance: CGFloat?) {
        self.id = id
        self.songId = songId
        self.serviceId = serviceId
        self.title = title
        self.artist = artist
        self.image = image
        self.previewUrl = previewUrl
        self.serviceUrl = serviceUrl
        self.user = user
        self.distance = distance
    }
    
    static func create(id: String, songId: String, serviceId: String, title: String, artist: Artist, image: Image, previewUrl: NSURL, serviceUrl: NSURL, user: User?, distance: CGFloat?) -> Song {
        if songs.indexForKey(id) != nil && songs[id]?.serviceId == serviceId {
            songs[id]?.distance = distance
            
            return songs[id]!
        }
        
        songs[id] = Song(id: id, songId: songId, serviceId: serviceId, title: title, artist: artist, image: image, previewUrl: previewUrl, serviceUrl: serviceUrl, user: user, distance: distance)
        
        return songs[id]!
    }
}