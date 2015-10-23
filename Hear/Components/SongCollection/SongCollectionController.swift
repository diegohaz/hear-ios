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
    
    init(view: SongCollectionView) {
        super.init()
        
        self.view = view
        self.view.alwaysBounceVertical = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged:", name: LocationManagerNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentSongChanged:", name: AudioManagerPlayNotification, object: nil)
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
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoadingNotification, object: true)
    
        ParseAPI.listSongs(location).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            self.songs = task.result["songs"] as! [Song]
            self.nextPage = task.result["nextPage"] as! Int
            self.setup()
            self.view.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName(LoadingNotification, object: false)
            
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
        var meters: CGFloat = 0
        
        if scrollView.contentOffset.y < 0 {
            meters = self.songs[0].distance!
        } else {
            var songs = self.songs
            
            // Remove songs from right column
            for var i = 2; i < songs.count; i += 2 {
                songs.removeAtIndex(i)
            }
            
            let layout = view.collectionViewLayout as! SongCollectionLayout
            let scrollY = scrollView.contentOffset.y + layout.sectionInset.top
            var currentItem = 0
            var nextItem = 0
            
            for i in 0 ..< songs.count {
                nextItem += i > 0 && (i + 1) % 2 == 0 ? 2 : 1
                
                if nextItem >= self.songs.count {
                    meters = songs[i].distance!
                    break
                }
                
                let currentDistance = songs[i].distance!
                let currentFrame = view.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: currentItem, inSection: 0))!.frame
                let currentFrameY = currentFrame.origin.y
                
                let nextDistance = i + 1 < songs.count ? songs[i + 1].distance! : currentDistance
                let nextFrame = view.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: nextItem, inSection: 0))?.frame
                let nextFrameY = nextFrame?.origin.y ?? currentFrameY + 100
                
                if scrollY >= currentFrameY && scrollY < nextFrameY {
                    let distanceDiff = nextDistance - currentDistance
                    let scrollPercent = (scrollY - currentFrameY) / (nextFrameY - currentFrameY)
                    print(scrollPercent)
                    
                    meters = currentDistance + distanceDiff * scrollPercent
                    
                    break
                }
                
                currentItem = nextItem
            }
        }
        
        //let distance = "\(Int(meters))m"
        let distance = meters > 1000 ? "\(Int(meters/1000))km" : "\(Int(meters))m"
        
        NSNotificationCenter.defaultCenter().postNotificationName(TitleNotification, object: distance)
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
