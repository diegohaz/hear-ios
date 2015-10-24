//
//  ParseAPI.swift
//  Hear
//
//  Created by Diego Haz on 10/8/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import Bolts

class ParseAPI {
    
    static func searchSong(string: String) -> BFTask {
        let task = PFCloud.callFunctionInBackground("searchSong", withParameters: ["string": string])
        
        return task.continueWithSuccessBlock { (task) -> AnyObject! in
            return translate(songs: task.result)
        }
    }
    
    static func listSongs(location: CLLocation, limit: Int = 30, skip: Int = 0) -> BFTask {
        let parameters: [NSObject: AnyObject] = [
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
            "limit": limit,
            "skip": skip
        ]
        
        let task = PFCloud.callFunctionInBackground("listSongs", withParameters: parameters)
        
        return task.continueWithSuccessBlock { (task) -> AnyObject! in
            let results = task.result as! NSDictionary
            let songs = translate(songPosts: results["songs"]!)
            
            return [
                "nextPage": results["nextPage"] as! Int,
                "songs": songs
            ]
        }
    }
    
    private static func translate(object: AnyObject) -> Song {
        let object = object as! NSDictionary
        
        return Song.create(
            id: object["id"] as! String,
            title: object["title"] as! String,
            artist: object["artist"] as! String,
            cover: object["cover"] as! String,
            preview: object["preview"] as! String,
            url: object["serviceUrl"] as! String
        )
    }
    
    private static func translate(songs objects: AnyObject) -> [Song] {
        return each(objects) { self.translate($0) }
    }
    
    private static func translate(object: AnyObject) -> SongPost {
        let object = object as! NSDictionary
        
        return SongPost(song: translate(object), distance: object["distance"] as! CGFloat)
    }
    
    private static func translate(songPosts objects: AnyObject) -> [SongPost] {
        return each(objects) { self.translate($0) }
    }
    
    private static func each<T>(objects: AnyObject, fn: (AnyObject) -> T) -> [T] {
        var objectsToReturn = [T]()
        
        for object in objects as! [AnyObject] {
            objectsToReturn.append(fn(object))
        }
        
        return objectsToReturn
    }
    
}
