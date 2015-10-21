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
            var songs = [Song]()
            
            for result in task.result as! [PFObject] {
                let song = Song.create(
                    id: result["id"] as! String,
                    title: result["title"] as! String,
                    artist: result["artist"] as! String,
                    cover: result["cover"] as! String,
                    preview: result["preview"] as! String
                )
                
                songs.append(song)
            }
            
            return songs
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
            var songs = [Song]()
            let results = task.result as! NSDictionary
            
            for result in results["songs"] as! [NSDictionary] {
                let song = Song.create(
                    id: result["id"] as! String,
                    title: result["title"] as! String,
                    artist: result["artist"] as! String,
                    cover: result["cover"] as! String,
                    preview: result["preview"] as! String
                )
                
                songs.append(song)
            }
            
            return [
                "nextPage": results["nextPage"] as! Int,
                "minDistance": results["minDistance"] as! CGFloat,
                "maxDistance": results["maxDistance"] as! CGFloat,
                "songs": songs
            ]
        }
    }
    
}
