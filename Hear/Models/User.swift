//
//  User.swift
//  Hear
//
//  Created by Juliana Zilberberg on 9/28/15.
//  Copyright (c) 2015 Hear. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var object: PFObject
    var name: String!
    var pictureUrl: NSURL
    var service: StreamingServiceProtocol
}
