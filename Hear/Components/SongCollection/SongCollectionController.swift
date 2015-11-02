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
    var offset = 0
    var hasOtherPage = true
    var loading = false
    var scrolling = false
    
    init(view: SongCollectionView) {
        super.init()
        
        self.view = view
        self.view.alwaysBounceVertical = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged:", name: LocationManagerNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentSongChanged:", name: AudioManagerPlayNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged:", name: PostSongNotification, object: nil)
    }
    
    func currentSongChanged(notification: NSNotification) {
//        if scrolling || songs.count == 0 {
//            return
//        }
//        
//        let index = notification.object as! Int
//        let indexPath = NSIndexPath(forItem: index, inSection: 0)
//        let layout = view.collectionViewLayout as! SongCollectionLayout
//        var frame = view.layoutAttributesForItemAtIndexPath(indexPath)?.frame
//        
//        frame?.origin.y -= layout.sectionInset.top
//        frame?.size.height += layout.sectionInset.top + layout.sectionInset.bottom
//        
//        view.scrollRectToVisible(frame ?? CGRect(x: 0, y: view.contentOffset.y, width: 10, height: 10), animated: true)
    }
    
    func locationChanged(notification: NSNotification) {
        reload()
    }
    
    private func setup() {
        AudioManager.sharedInstance.reload(songs)
        
        self.view.registerNib(UINib(nibName: "SongCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
        
        self.view.delegate = self
        self.view.dataSource = self
        
        setDistance(view)
    }
    
    func reload() {
        guard let location = LocationManager.sharedInstance.location else {
            return
        }

        loading = true
        LocationManager.sharedInstance.originalLocation = location
        NSNotificationCenter.defaultCenter().postNotificationName(LoadingNotification, object: true)
        
        API.listPlacedSongs(location).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            self.songs = task.result["songs"] as! [Song]
            self.offset = task.result["offset"] as! Int
            self.hasOtherPage = true
            self.setup()
            self.view.reloadData()
            self.loading = false
            NSNotificationCenter.defaultCenter().postNotificationName(LoadingNotification, object: false)
            
            return task
        })
    }
    
    func loadNextPage() {
        if !hasOtherPage || loading {
            return
        }
    
        guard let location = LocationManager.sharedInstance.originalLocation else {
            return
        }
        
        loading = true

        API.listPlacedSongs(location, limit: 30, offset: offset).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            self.loading = false
            guard let songs = task.result["songs"] as? [Song] else {
                return task
            }
            
            if songs.count == 0 {
                self.hasOtherPage = false
                return task
            }
            
            self.songs += songs
            self.offset = task.result["offset"] as! Int
            AudioManager.sharedInstance.append(songs)
            self.view.reloadData()
            
            return task
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrolling = true
        
        let paths = view.indexPathsForVisibleItems()
        let y = scrollView.contentOffset.y
        
        for path in paths {
            if let cell = view.cellForItemAtIndexPath(path) as? SongCollectionCell {
                cell.fade(view)
            }
        }
        
        if y < -100 && !loading {
            reload()
        } else if y < -50 && !loading {
            NSNotificationCenter.defaultCenter().postNotificationName(TitleNotification, object: "pull to refresh")
        } else {
            let frameHeight = scrollView.bounds.height
            let contentHeight = scrollView.contentSize.height
            setDistance(scrollView)
    
            if contentHeight > frameHeight && y + frameHeight > contentHeight - 700 {
                loadNextPage()
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrolling = false
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrolling = false
    }
    
    func setDistance(scrollView: UIScrollView) {
        var meters: CGFloat = 0
        
        if scrollView.contentOffset.y < 0 {
            meters = songs.count > 0 ? songs[0].distance! : 0
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SongCollectionCell
        
        cell?.bounce()
        cell?.songButtonView.controller.toggle()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SongCollectionCell
        let song = songs[indexPath.item]
        
        cell.songButtonView.controller.song = songs[indexPath.item]
        cell.songTitleLabel.text = song.title
        cell.songArtistLabel.text = song.artist.name
        cell.fade(view)
        
        return cell
    }
}
