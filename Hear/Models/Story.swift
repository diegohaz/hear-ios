//
//  Story.swift
//  Hear
//
//  Created by Juliana Zilberberg on 9/28/15.
//  Copyright (c) 2015 Hear. All rights reserved.
//

import UIKit

class Story: NSObject {
    
    var object: PFObject!
    var text: String = ""
    var author: User
    var song: Song
    var location: CLLocation!
    var anonymous: Bool
    var likes: Int!
}
