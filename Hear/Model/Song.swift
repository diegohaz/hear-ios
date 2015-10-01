//
//  Song.swift
//  Hear
//
//  Created by Juliana Zilberberg on 9/28/15.
//  Copyright (c) 2015 Hear. All rights reserved.
//

import UIKit
import CoreLocation

class Song: NSObject {
    
    //var object : PFObject
    var title: String
    var artist: String
    var coverImageUrl: NSURL
    var lenght: Int
    var location: CLLocation
    var stories: [Story]
    var genres: [Genre]
    var url: NSURL
    
}