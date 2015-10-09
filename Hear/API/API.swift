//
//  API.swift
//  Hear
//
//  Created by Diego Haz on 10/8/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import CoreLocation

class API {
    static let APP_ID = "YoKGeRRzGizxpkXM6V11kfaV6iX3KXt7QSJeNeXR"
    static let API_KEY = "6L4vdeKgev4i2iE2qeI5vpmT8rSGxbsaZmWnDFnt"
    static let URL = "https://\(APP_ID):javascript-key=\(API_KEY)@api.parse.com/1/"
    
    static func searchSong(string: String, then callback: ((songs: [Song], error: NSError?) -> Void)?) {
        let url = "\(URL)functions/searchSong?string=\(string)"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "POST"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            var songs = [Song]()
            let jsonResult: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            let results = jsonResult["result"] as! NSArray
            
            for result in results {
                let song = Song(
                    id: result["id"] as! Int,
                    title: result["title"] as! String,
                    artist: result["artist"] as! String,
                    cover: NSURL(string: result["cover"] as! String)!,
                    preview: NSURL(string: result["preview"] as! String)!,
                    distance: nil
                )
                
                songs.append(song)
            }
            
            dump(songs)
        }
        task.resume()
    }
    
    static func listSongs(location: CLLocation, then callback: (songs: [Song], error: NSError?) -> Void) {
        let url = "\(URL)functions/listSongs"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "POST"
        
        let bodyData = "lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var songs = [Song]()
                let jsonResult: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                let results = jsonResult["result"] as! NSDictionary
                
                for result in results["songs"] as! NSArray {
                    let song = Song(
                        id: Int(result["id"] as! String)!,
                        title: result["title"] as! String,
                        artist: result["artist"] as! String,
                        cover: NSURL(string: result["cover"] as! String)!,
                        preview: NSURL(string: result["preview"] as! String)!,
                        distance: result["distance"] as? Float
                    )
                    
                    songs.append(song)
                }
                
                callback(songs: songs, error: nil)
            })
        }
        task.resume()
    }
}
