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

public let SongCollectionPullNotification = "SongCollectionPullNotification"
public let SongCollectionBeginLoadingNotification = "SongCollectionBeginLoadingNotification"
public let SongCollectionEndLoadingNotification = "SongCollectionEndLoadingNotification"
public let SongCollectionDistanceDidChangeNotification = "SongCollectionDistanceDidChangeNotification"
public let SongCollectionPlaceDidChangeNotification = "SongCollectionPlaceDidChangeNotification"

class SongCollectionController: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var view: SongCollectionView!
    var place: Place?
    var songs = [Song]()
    var offset = 0
    var hasOtherPage = true
    var loading = false
    var scrolling = false
    var longPressedCell: SongCollectionCell?
    
    init(view: SongCollectionView) {
        super.init()
        
        self.view = view
        self.view.alwaysBounceVertical = true
        
        let hold = UILongPressGestureRecognizer(target: self, action: "viewDidLongPress:")
        hold.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(hold)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: LocationManagerNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentSongChanged:", name: AudioManagerDidPlayNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPlaceSong:", name: SearchSongCollectionDidPlaceSongNotification, object: nil)
    }
    
    func currentSongChanged(notification: NSNotification) {
        guard let song = notification.object as? Song else { return }
        guard let index = songs.indexOf(song) else { return }
        if scrolling || songs.count == 0 { return }
        
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        let layout = view.collectionViewLayout as! SongCollectionLayout
        var frame = view.layoutAttributesForItemAtIndexPath(indexPath)?.frame
        
        frame?.origin.y -= layout.sectionInset.top
        frame?.size.height += layout.sectionInset.top + layout.sectionInset.bottom
        
        view.scrollRectToVisible(frame ?? CGRect(x: 0, y: view.contentOffset.y, width: 10, height: 10), animated: true)
    }
    
    func viewDidLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let point = gestureRecognizer.locationInView(view)
        
        guard let index = view.indexPathForItemAtPoint(point) else {
            longPressedCell?.stopTrembling()
            longPressedCell = nil
            return
        }
        
        guard let cell = view.cellForItemAtIndexPath(index) as? SongCollectionCell else {
            longPressedCell?.stopTrembling()
            longPressedCell = nil
            return
        }
        
        if longPressedCell != nil && cell != longPressedCell {
            longPressedCell?.stopTrembling()
            longPressedCell = nil
            return
        }
        
        if gestureRecognizer.state == .Began {
            longPressedCell = cell
            longPressedCell?.startTrembling()
        } else if gestureRecognizer.state == .Ended {
            longPressedCell?.hide(completion: { (finished) -> Void in
                self.longPressedCell?.stopTrembling()
                
                if let song = self.longPressedCell?.songButton.controller.song {
                    if let songIndex = self.songs.indexOf(song) {
                        self.songs.removeAtIndex(songIndex)
                        self.view.reloadData()
                    }
                    
                    API.removeSong(song)
                    
                    if AudioManager.sharedInstance.playing(song) {
                        AudioManager.sharedInstance.playNext()
                    }
                }
                
                self.longPressedCell = nil
            })
        }
    }
    
    func didPlaceSong(notification: NSNotification) {
        reload().continueWithBlock { (task) -> AnyObject! in
            if let song = notification.object as? Song {
                AudioManager.sharedInstance.play(song)
            }
            
            return nil
        }
    }
    
    private func setup() {
        AudioManager.sharedInstance.reload(songs)
        
        self.view.registerNib(UINib(nibName: "SongCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
        
        self.view.delegate = self
        self.view.dataSource = self
        
        setDistance(view)
    }
    
    func reload() -> BFTask {
        guard let location = LocationManager.sharedInstance.location else {
            return BFTask(error: NSError(domain: BFTaskErrorDomain, code: 0, userInfo: nil))
        }

        loading = true
        LocationManager.sharedInstance.originalLocation = location
        NSNotificationCenter.defaultCenter().postNotificationName(SongCollectionBeginLoadingNotification, object: nil)
        
        API.fetchPlace(location).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            self.place = task.result as? Place
            
            NSNotificationCenter.defaultCenter().postNotificationName(SongCollectionPlaceDidChangeNotification, object: self.place?.name)
            
            return nil
        })
        
        return API.listPlacedSongs(location).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            self.songs = task.result["songs"] as! [Song]
            self.offset = task.result["offset"] as! Int
            self.hasOtherPage = true
            self.setup()
            self.view.reloadData()
            self.loading = false
            NSNotificationCenter.defaultCenter().postNotificationName(SongCollectionEndLoadingNotification, object: nil)
            
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
        
        let ids = songs.map({ $0.songId })
        loading = true

        API.listPlacedSongs(location, limit: 90, offset: offset, excludeIds: ids).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
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
            NSNotificationCenter.defaultCenter().postNotificationName(SongCollectionPullNotification, object: nil)
        } else {
            let frameHeight = scrollView.bounds.height
            let contentHeight = scrollView.contentSize.height
            setDistance(scrollView)
    
            if contentHeight > frameHeight && y + frameHeight > contentHeight - 700 {
                loadNextPage()
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrolling = false
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
                let currentIndexPath = NSIndexPath(forItem: currentItem, inSection: 0)
                let currentFrame = view.layoutAttributesForItemAtIndexPath(currentIndexPath)!.frame
                let currentFrameY = currentFrame.origin.y
                
                let nextDistance = i + 1 < songs.count ? songs[i + 1].distance! : currentDistance
                let nextIndexPath = NSIndexPath(forItem: nextItem, inSection: 0)
                let nextFrame = view.layoutAttributesForItemAtIndexPath(nextIndexPath)?.frame
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
        
        var place = self.place
        
        while place != nil && meters > place!.radius {
            place = place!.parent
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(SongCollectionPlaceDidChangeNotification, object: place?.name ?? "World")
        
        let distance = meters > 1000 ? "\(Int(meters/1000))km" : "\(Int(meters))m"
        
        NSNotificationCenter.defaultCenter().postNotificationName(SongCollectionDistanceDidChangeNotification, object: distance)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SongCollectionCell
        
        cell?.bounce()
        cell?.songButton.controller.toggle()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SongCollectionCell
        let song = songs[indexPath.item]
        
        cell.songButton.controller.song = songs[indexPath.item]
        cell.songTitleLabel.text = song.title
        cell.songArtistLabel.text = song.artist.name
        cell.fade(view)
        
        return cell
    }
}
