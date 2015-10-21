//
//  Song.swift
//  Hear
//
//  Created by Juliana Zilberberg on 9/28/15.
//  Copyright (c) 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

class Song {
    static private var songs = [String: Song]()
    static private var lastSongAdded: Song?
    
    var id: String
    var title: String
    var artist: String
    
    private var coverUrl: NSURL?
    private var coverData: NSData?
    private var coverTask: BFTask?
    
    var previewUrl: NSURL
    var previewData: NSData?
    var previewTask: BFTask?
    
    private init(id: String, title: String, artist: String, cover: String, preview: String) {
        self.id = id
        self.title = title
        self.artist = artist
        self.previewUrl = NSURL(string: preview)!
        
        let largeSize = Int(UIScreen.mainScreen().bounds.width)
        let reachability = Reachability.reachabilityForInternetConnection()
        
        if reachability?.isReachableViaWiFi() == true {
            coverUrl = NSURL(string: cover.stringByReplacingOccurrencesOfString("100x100", withString: "\(largeSize)x\(largeSize)"))!
        } else {
            coverUrl = NSURL(string: cover)!
        }
    }
    
    static func create(id id: String, title: String, artist: String, cover: String, preview: String) -> Song {
        if songs.indexForKey(id) != nil {
            return songs[id]!
        }
        
        songs[id] = Song(id: id, title: title, artist: artist, cover: cover, preview: preview)
        
        return songs[id]!
    }
    
    func load() {
        let reachability = Reachability.reachabilityForInternetConnection()
        
        if reachability?.isReachableViaWiFi() == true {
            loadCover()
            
            if let lastSongAdded = Song.lastSongAdded {
                loadPreview(after: lastSongAdded.previewTask!)
            } else {
                loadPreview()
            }
        } else {
            loadCover()
        }
        
        Song.lastSongAdded = self
    }
    
    func loadCover() -> BFTask {
        if coverData != nil {
            return BFTask(result: coverData)
        } else if coverTask != nil {
            return coverTask!
        } else {
            print("Loading cover for \(title)")
            coverTask = BFTask(delay: 0).continueWithExecutor(BFExecutor.defaultExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                self.coverData = NSData(contentsOfURL: self.coverUrl!)
                print("Retrieving cover for \(self.title)")
                
                return self.coverData
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
}