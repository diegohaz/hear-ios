//
//  User.swift
//  Hear
//
//  Created by Diego Haz on 10/22/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

class User {
    private static var users = [String: User]()
    
    var id: String
    var name: String?
    var identified: Bool = false
    
    private var pictureUrl: NSURL?
    private var pictureData: NSData?
    private var pictureTask: BFTask?
    
    private init(id: String, name: String?, picture: String?, identified: Bool = false) {
        self.id = id
        self.name = name
        self.identified = identified
        
        if let picture = picture {
            self.pictureUrl = NSURL(string: picture)
        }
    }
    
    static func create(id id: String, name: String?, picture: String?, identified: Bool = false) -> User {
        if users.indexForKey(id) != nil {
            return users[id]!
        }
        
        users[id] = User(id: id, name: name, picture: picture)
        
        return users[id]!
    }
    
    func loadPicture() -> BFTask? {
        if pictureData != nil {
            return BFTask(result: pictureData)
        } else if pictureTask != nil {
            return pictureTask
        } else if pictureUrl != nil {
            print("Loading picture for \(name)")
            pictureTask = BFTask(delay: 0).continueWithExecutor(BFExecutor.defaultExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                self.pictureData = NSData(contentsOfURL: self.pictureUrl!)
                print("Retrieving picture for \(self.name)")
                
                return self.pictureData
            })
        }
        
        return pictureTask
    }
}
