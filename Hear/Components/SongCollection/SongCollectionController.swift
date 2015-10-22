//
//  RadarController.swift
//  Hear
//
//  Created by Diego Haz on 9/30/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import CoreLocation
import Bolts

class SongCollectionController: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var view: SongCollectionView!
    var songs = [Song]()
    var nextPage = 0
    var minDistance: CGFloat = 0
    var maxDistance: CGFloat = 0
    
    init(view: SongCollectionView) {
        super.init()
        
        self.view = view
        self.view.alwaysBounceVertical = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged:", name: "location", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentSongChanged:", name: "play", object: nil)
    }
    
    func currentSongChanged(notification: NSNotification) {
        let index = notification.object as! Int
        let layout = view.collectionViewLayout as! SongCollectionLayout
        var frame = view.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))!.frame
        
        frame.origin.y -= layout.sectionInset.top
        frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
        
        view.scrollRectToVisible(frame, animated: true)
    }
    
    func locationChanged(notification: NSNotification) {
        let location = notification.object as! CLLocation
        
        NSNotificationCenter.defaultCenter().postNotificationName("startLoading", object: nil)
        ParseAPI.listSongs(location).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            self.songs = task.result["songs"] as! [Song]
            self.nextPage = task.result["nextPage"] as! Int
            self.minDistance = task.result["minDistance"] as! CGFloat
            self.maxDistance = task.result["maxDistance"] as! CGFloat
            self.setup()
            self.view.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName("stopLoading", object: nil)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                for song in self.songs {
                    song.load()
                }
            })
            
            return task
        })
    }
    
    private func setup() {
        view.registerClass(SongCollectionCell.self, forCellWithReuseIdentifier: "Cell")
        
        AudioManager.sharedInstance.songs = songs
        
        view.delegate = self
        view.dataSource = self
        
        setDistance(view)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let paths = view.indexPathsForVisibleItems()
        
        for path in paths {
            if let cell = view.cellForItemAtIndexPath(path) as? SongCollectionCell {
                cell.fade(view)
            }
        }
        
        setDistance(scrollView)
    }
    
    func setDistance(scrollView: UIScrollView) {
        let distanceDiff = maxDistance - minDistance
        let scrollPercent = scrollView.contentOffset.y / (scrollView.contentSize.height - scrollView.bounds.height)
        var meters = minDistance + distanceDiff * scrollPercent
        
        meters = meters < minDistance ? minDistance : (meters > maxDistance ? maxDistance : meters)
        
        let distance = meters > 1000 ? "\(Int(meters/1000))km" : "\(Int(meters))m"
        
        NSNotificationCenter.defaultCenter().postNotificationName("changeDistance", object: distance)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SongCollectionCell
        
        cell.songButtonView.controller.song = songs[indexPath.item]
        cell.fade(collectionView)
        cell.songButtonView.controller.updateTime()
        
        return cell
    }
}
