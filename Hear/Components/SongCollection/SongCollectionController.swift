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
    var songPosts = [SongPost]()
    var nextPage = 0
    var loading = false
    
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
        reload()
    }
    
    private func setup() {
        var songs = [Song]()
        
        for songPost in songPosts {
            songs.append(songPost.song)
        }
        
        AudioManager.sharedInstance.songs = songs
        
        view.registerNib(UINib(nibName: "SongCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
        view.delegate = self
        view.dataSource = self
        
        setDistance(view)
    }
    
    func reload() {
        guard let location = LocationManager.sharedInstance.location else {
            return
        }

        loading = true
        NSNotificationCenter.defaultCenter().postNotificationName(LoadingNotification, object: true)
        
        ParseAPI.listSongs(location).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            self.songPosts = task.result["songs"] as! [SongPost]
            self.nextPage = task.result["nextPage"] as! Int
            self.setup()
            self.view.reloadData()
            self.loading = false
            NSNotificationCenter.defaultCenter().postNotificationName(LoadingNotification, object: false)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                for songPost in self.songPosts {
                    songPost.song.load()
                }
            })
            
            return task
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let paths = view.indexPathsForVisibleItems()
        
        for path in paths {
            if let cell = view.cellForItemAtIndexPath(path) as? SongCollectionCell {
                cell.fade(view)
            }
        }
        
        if scrollView.contentOffset.y < -110 && !loading {
            reload()
        } else if scrollView.contentOffset.y < -50 && !loading {
            NSNotificationCenter.defaultCenter().postNotificationName(TitleNotification, object: "pull to refresh")
        } else {
            setDistance(scrollView)
        }
    }
    
    func setDistance(scrollView: UIScrollView) {
        var meters: CGFloat = 0
        
        if scrollView.contentOffset.y < 0 {
            meters = self.songPosts[0].distance
        } else {
            var songs = self.songPosts
            
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
                
                if nextItem >= self.songPosts.count {
                    meters = songs[i].distance
                    break
                }
                
                let currentDistance = songs[i].distance
                let currentFrame = view.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: currentItem, inSection: 0))!.frame
                let currentFrameY = currentFrame.origin.y
                
                let nextDistance = i + 1 < songs.count ? songs[i + 1].distance : currentDistance
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
        return songPosts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SongCollectionCell
        let song = songPosts[indexPath.item].song
        
        cell.songButtonView.controller.song = song
        cell.songTitleLabel.text = song.title
        cell.songArtistLabel.text = song.artist
        cell.fade(collectionView)
        
        return cell
    }
}
