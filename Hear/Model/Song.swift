//
//  Song.swift
//  Hear
//
//  Created by Juliana Zilberberg on 9/28/15.
//  Copyright (c) 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

class Song: NSObject {
    static private var songs = [String: Song]()
    static private var lastSongAdded: Song?
    
    var id: String
    var title: String
    var artist: String
    var url: NSURL
    var coverImage: UIImage?
    var coverImageRounded: UIImage?
    
    private var coverUrl: NSURL?
    private var coverTask: BFTask?
    
    var previewUrl: NSURL
    var previewData: NSData?
    var previewTask: BFTask?
    
    private init(id: String, title: String, artist: String, cover: String, preview: String, url: String) {
        self.id = id
        self.title = title
        self.artist = artist
        self.previewUrl = NSURL(string: preview)!
        self.url = NSURL(string: url)!
        
        let largeSize = Int(UIScreen.mainScreen().bounds.width)
        let reachability = Reachability.reachabilityForInternetConnection()
        
        if reachability?.isReachableViaWiFi() == true {
            coverUrl = NSURL(string: cover.stringByReplacingOccurrencesOfString("100x100", withString: "\(largeSize)x\(largeSize)"))!
        } else {
            coverUrl = NSURL(string: cover)!
        }
    }
    
    static func create(id id: String, title: String, artist: String, cover: String, preview: String, url: String) -> Song {
        if songs.indexForKey(id) != nil {
            return songs[id]!
        }
        
        songs[id] = Song(id: id, title: title, artist: artist, cover: cover, preview: preview, url: url)
        
        return songs[id]!
    }
    
    func load() {
        let reachability = Reachability.reachabilityForInternetConnection()
        
        if reachability?.isReachableViaWiFi() == true {
            loadCover()
            
            if let lastSongAdded = Song.lastSongAdded {
                loadPreview(after: lastSongAdded.previewTask ?? BFTask(delay: 0))
            } else {
                loadPreview()
            }
        } else {
            loadCover()
        }
        
        Song.lastSongAdded = self
    }
    
    func loadCover() -> BFTask {
        if coverImage != nil {
            return BFTask(result: coverImage)
        } else if coverTask != nil {
            return coverTask!
        } else {
            print("Loading cover for \(title)")
            coverTask = BFTask(delay: 0).continueWithExecutor(BFExecutor.defaultExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                print("Retrieving cover for \(self.title)")
                guard let data = NSData(contentsOfURL: self.coverUrl!) else {
                    return BFTask(error: NSError(domain: BFTaskErrorDomain, code: 0, userInfo: nil))
                }
                
                self.coverImage = UIImage(data: data)!
                let rect = CGRectMake(0, 0, self.coverImage!.size.width, self.coverImage!.size.height)
                
                UIGraphicsBeginImageContextWithOptions(self.coverImage!.size, false, self.coverImage!.scale)
                UIBezierPath(roundedRect: rect, cornerRadius: self.coverImage!.size.width/2).addClip()
                self.coverImage!.drawInRect(rect)
                self.coverImageRounded = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                return self.coverImage
            })
            
            return coverTask!
        }
    }
    
    func loadPreview(ignoreTask: Bool = false, after task: BFTask = BFTask(delay: 0)) -> BFTask {
        if previewData != nil {
            return BFTask(result: previewData)
        } else if previewTask != nil && !ignoreTask {
            return previewTask!
        } else {
            print("Loading preview for \(title)")
            previewTask = task.continueWithExecutor(BFExecutor.defaultExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                self.previewData = NSData(contentsOfURL: self.previewUrl)
                print("Retrieving preview for \(self.title)")
                
                return self.previewData
            })
            
            return previewTask!
        }
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Song {
            return object.id == self.id
        } else {
            return false
        }
    }
}