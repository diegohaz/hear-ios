//
//  Story.swift
//  Hear
//
//  Created by Juliana Zilberberg on 9/28/15.
//  Copyright (c) 2015 Hear. All rights reserved.
//

import UIKit
import CoreLocation

class Story: Song, User {
    
<<<<<<< Updated upstream:Hear/Model/Story.swift
    //var object: PFObject!
    var text: String = ""
=======
    var object: PFObject
    var text: String!
>>>>>>> Stashed changes:Hear/Models/Story.swift
    var author: User
    var song: Song
    var location: CLLocation
    var anonymous: Bool
<<<<<<< Updated upstream:Hear/Model/Story.swift
    var likes: Int = 0
=======
    var likes: Int!
    
>>>>>>> Stashed changes:Hear/Models/Story.swift
}

