//
//  SearchSongCollectionController.swift
//  Hear
//
//  Created by Diego Haz on 10/24/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

let SearchSongCollectionDidPrepareToPlaceSongNotification = "SearchSongCollectionDidPrepareToPlaceSongNotification"
let SearchSongCollectionDidPlaceSongNotification = "SearchSongCollectionDidPlaceSongNotification"

class SearchSongCollectionController: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var view: SearchSongCollectionView!
    var songs = [Song]()
    var songWaitingForLocation: Song?
    
    init(view: SearchSongCollectionView) {
        super.init()
        
        self.view = view
        self.view.alwaysBounceVertical = true
        self.view.registerNib(UINib(nibName: "SearchSongCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
        self.view.delegate = self
        self.view.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged", name: LocationManagerNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "searchSongTextFieldDidReturn:", name: SearchSongTextFieldNotification, object: nil)
    }
    
    func searchSongTextFieldDidReturn(notification: NSNotification) {
        if let string = notification.object as? String {
            songs = [Song]()
            view.reloadData()
            search(string)
        }
    }
    
    func search(string: String) {
        ParseAPI.searchSong(string).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            guard let songs = task.result as? [Song] else {
                return task
            }
            
            self.songs = songs
            self.view.reloadData()
            
            if songs.count == 0 {
                self.view.noResultsLabel.text = "Sorry, we could not find any song for \"\(string)\"."
                self.view.noResultsLabel.hidden = false
            } else {
                self.view.noResultsLabel.hidden = true
            }
            
            return task
        })
    }
    
    func locationChanged() {
        if let song = songWaitingForLocation {
            placeSong(song)
            songWaitingForLocation = nil
        }
    }
    
    func placeButtonDidTouch() {
        guard let index = view.indexPathsForSelectedItems()?[0] else {
            return
        }
        
        guard let cell = view.cellForItemAtIndexPath(index) as? SearchSongCollectionCell else {
            return
        }
        
        guard let song = cell.songButton.controller.song else {
            return
        }
        
        cell.placeButton.bounce { (finished) -> Void in
            self.placeSong(song)
        }
    }
    
    func placeSong(song: Song) {
        NSNotificationCenter.defaultCenter().postNotificationName(SearchSongCollectionDidPrepareToPlaceSongNotification, object: song)
        
        guard let location = LocationManager.sharedInstance.location else {
            self.songWaitingForLocation = song
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(SongCollectionBeginLoadingNotification, object: nil)
        
        API.placeSong(song, location: location).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            guard let song = task.result as? Song else {
                return task
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(SongCollectionEndLoadingNotification, object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(SearchSongCollectionDidPlaceSongNotification, object: song)
            
            return task
        })
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SearchSongCollectionCell
        
        cell?.select()
        cell?.songButton.controller.toggle()
        cell?.placeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "placeButtonDidTouch"))
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SearchSongCollectionCell
    
        let song = songs[indexPath.item]
        
        cell.songButton.controller.song = song
        cell.songTitleLabel.text = song.title
        cell.songArtistLabel.text = song.artist.name
        
        return cell
    }
}
