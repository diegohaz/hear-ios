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

class ParseAPI : APIProtocol {
    
    /// Login
    static func login() -> BFTask {
        if let user = PFUser.currentUser() {
            print("User is already logged in")
            return BFTask(result: user)
        }
        
        print("Signing up...")
        let task = PFAnonymousUtils.logInInBackground().continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Trying again...")
                return BFTask(delay: 2000).continueWithBlock({ (task) -> AnyObject! in
                    return login()
                })
            }
            
            let user = PFUser.currentUser()!
            
            print("Signed up!")
            print("Saving country and locale...")
            user["country"] = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
            user["locale"] = NSLocale.preferredLanguages().first
            
            return user.saveInBackground()
        }.continueWithSuccessBlock { (task) -> AnyObject! in
            print("Saved!")
            return task
        }
        
        return task
    }
    
    /// Logout
    static func logout() -> BFTask {
        return PFUser.logOutInBackground()
    }
    
    /// Fetch place
    static func fetchPlace(location: CLLocation) -> BFTask {
        let parameters: [NSObject: AnyObject] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        
        print("Fetching place...")
        let task = PFCloud.callFunctionInBackground("fetchPlace", withParameters: parameters)
        
        return task.continueWithSuccessBlock({ (task) -> AnyObject! in
            print("Fetched!")
            return translate(place: task.result)
        })
    }
    
    /// Search songs
    static func searchSong(string: String, limit: Int? = nil) -> BFTask {
        let parameters: [NSObject: AnyObject] = [
            "string": string,
            "limit": limit ?? NSNull()
        ]
        
        print("Searching song for string \"\(string)\"...")
        let task = PFCloud.callFunctionInBackground("searchSong", withParameters: parameters)
        
        return task.continueWithBlock({ (task) -> AnyObject! in
            if task.error != nil {
                print("Trying again...")
                return BFTask(delay: 2000).continueWithBlock({ (task) -> AnyObject! in
                    return searchSong(string, limit: limit)
                })
            }
            
            print("Searched!")
            return translate(songs: task.result)
        })
    }
    
    /// List placed songs
    static func listPlacedSongs(location: CLLocation, limit: Int? = nil, offset: Int? = nil, excludeIds: [String]? = nil) -> BFTask {
        let parameters: [NSObject: AnyObject] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "limit": limit ?? NSNull(),
            "offset": offset ?? NSNull(),
            "excludeIds": excludeIds ?? NSNull()
        ]
        
        print("Listing placed songs...")
        let task = PFCloud.callFunctionInBackground("listPlacedSongs", withParameters: parameters)
        
        return task.continueWithBlock({ (task) -> AnyObject! in
            if task.error != nil {
                print("Trying again...")
                return BFTask(delay: 2000).continueWithBlock({ (task) -> AnyObject! in
                    return listPlacedSongs(location, limit: limit, offset: offset, excludeIds: excludeIds)
                })
            }
            
            print("Listed!")
            let results = task.result as! NSDictionary
            let songs = translate(songs: results["songs"]!)
            
            return [
                "offset": results["offset"] as! Int,
                "songs": songs
            ]
        })
    }
    
    /// Place song
    static func placeSong(song: Song, location: CLLocation) -> BFTask {
        let parameters: [NSObject: AnyObject] = [
            "serviceId": song.id,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        
        print("Placing song...")
        let task = PFCloud.callFunctionInBackground("placeSong", withParameters: parameters)
        
        return task.continueWithBlock({ (task) -> AnyObject! in
            if task.error != nil {
                print("Trying again...")
                return BFTask(delay: 2000).continueWithBlock({ (task) -> AnyObject! in
                    return placeSong(song, location: location)
                })
            }
            
            print("Placed!")
            return translate(song: task.result)
        })
    }
    
    /// Remove song
    static func removeSong(song: Song) -> BFTask {
        guard let user = PFUser.currentUser() else {
            return BFTask(error: NSError(domain: BFTaskErrorDomain, code: 0, userInfo: nil))
        }
        
        print("Removing song \"\(song.title)\"...")
        user.addUniqueObject(song.id, forKey: "removedSongs")
        
        return user.saveInBackground().continueWithSuccessBlock({ (task) -> AnyObject! in
            print("Removed!")
            return task
        })
    }
    
    /// Remove artist
    static func removeArtist(artist: Artist) -> BFTask {
        guard let user = PFUser.currentUser() else {
            return BFTask(error: NSError(domain: BFTaskErrorDomain, code: 0, userInfo: nil))
        }
        
        print("Removing artist \"\(artist.name)\"...")
        user.addUniqueObject(artist.id, forKey: "removedArtists")
        
        return user.saveInBackground().continueWithSuccessBlock({ (task) -> AnyObject! in
            print("Removed!")
            return task
        })
    }
    
    // MARK: Translation
    /// Translate place
    private static func translate(place object: AnyObject) -> Place {
        let object = object as! NSDictionary
        
        return Place(
            name: object["name"] as! String,
            radius: object["radius"] as! CGFloat,
            parent: object["parent"] != nil ? translate(place: object["parent"]!) : nil
        )
    }
    
    
    /// Translate song
    private static func translate(song object: AnyObject) -> Song {
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
    
    /// Translate songs
    private static func translate(songs objects: AnyObject) -> [Song] {
        return each(objects) { self.translate(song: $0) }
    }
    
    
    /// Each
    private static func each<T>(objects: AnyObject, fn: (AnyObject) -> T) -> [T] {
        var objectsToReturn = [T]()
        
        for object in objects as! [AnyObject] {
            objectsToReturn.append(fn(object))
        }
        
        return objectsToReturn
    }
}