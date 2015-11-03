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
        if PFUser.currentUser() != nil {
            print("User is already logged in")
            return saveLocale()
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
            user["locale"] = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String
            
            return user.saveInBackground()
        }.continueWithSuccessBlock { (task) -> AnyObject! in
            print("Saved!")
            return task
        }
        
        return task
    }
    
    /// Save locale
    private static func saveLocale() -> BFTask {
        guard let user = PFUser.currentUser() else {
            return BFTask(error: NSError(domain: BFTaskErrorDomain, code: 0, userInfo: nil))
        }
        
        print("Verifying locale...")
        let userCountry = user["country"] as? String
        let userLocale = user["locale"] as? String
        
        let currentCountry = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        let currentLocale = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String
        
        if userCountry != currentCountry || userLocale != currentLocale {
            print("Locale is different, updating...")
            user["country"] = currentCountry
            user["locale"] = currentLocale

            return user.saveInBackground().continueWithSuccessBlock({ (task) -> AnyObject! in
                print("Locale has been saved!")
                return task
            })
        } else {
            print("Locale is same")
            return BFTask(result: user)
        }
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
            "string": string
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
        user.addUniqueObject(song.songId, forKey: "removedSongs")
        
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
    /// Translate image
    private static func translate(image object: AnyObject) -> Image {
        let object = object as! NSDictionary
        
        return Image.create(
            NSURL(string: object["small"] as! String)!,
            mediumUrl: NSURL(string: object["medium"] as! String),
            bigUrl: NSURL(string: object["big"] as! String)
        )
    }
    
    /// Translate artist
    private static func translate(artist object: AnyObject) -> Artist {
        if let object = object as? NSDictionary {
            return Artist(
                id: object["id"] as! String,
                name: object["name"] as! String
            )
        } else {
            return Artist(id: "null", name: object as! String)
        }
    }
    
    /// Translate place
    private static func translate(place object: AnyObject) -> Place {
        let object = object as! NSDictionary
        let parent = object["parent"]
        
        return Place(
            name: object["name"] as! String,
            radius: object["radius"] as! CGFloat,
            parent: parent != nil ? translate(place: parent!) : nil
        )
    }
    
    
    /// Translate song
    private static func translate(song object: AnyObject) -> Song {
        let object = object as! NSDictionary
        let serviceId = object["serviceId"] as! String
        let songId = object["songId"] as? String ?? serviceId
        let id = object["id"] as? String ?? songId
        let user = object["user"] as? NSDictionary
        
        return Song.create(
            id,
            songId: songId,
            serviceId: serviceId,
            title: object["title"] as! String,
            artist: translate(artist: object["artist"]!),
            image: translate(image: object["images"]!),
            previewUrl: NSURL(string: object["previewUrl"] as! String)!,
            serviceUrl: NSURL(string: object["serviceUrl"] as! String)!,
            user: user != nil ? User(id: user!["id"] as! String) : nil,
            distance: object["distance"] as? CGFloat
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