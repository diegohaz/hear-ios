//
//  SearchSongCollectionController.swift
//  Hear
//
//  Created by Diego Haz on 10/24/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

let SearchSongCollectionDidSelectNotification = "SearchSongCollectionDidSelectNotification"

class SearchSongCollectionController: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var view: SearchSongCollectionView!
    var songs = [Song]()
    var selected: Song? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(SearchSongCollectionDidSelectNotification, object: selected)
        }
    }
    
    init(view: SearchSongCollectionView) {
        super.init()
        
        self.view = view
        self.view.alwaysBounceVertical = true
        self.view.registerNib(UINib(nibName: "SearchSongCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
        self.view.delegate = self
        self.view.dataSource = self
        
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
        selected = nil
        AudioManager.sharedInstance.stop()
        
        ParseAPI.searchSong(string).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            guard let songs = task.result as? [Song] else {
                return task
            }
            
            self.songs = songs
            self.view.reloadData()
            
            return task
        })
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SearchSongCollectionCell
        
        cell?.backgroundColor = UIColor.whiteColor()
        
        if AudioManager.sharedInstance.currentSong?.isEqual(selected) == true {
            AudioManager.sharedInstance.stop()
        }
        
        selected = nil
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SearchSongCollectionCell
        
        cell?.backgroundColor = UIColor.hearGrayColor()
        cell?.songButtonView.bounce()
        cell?.songButtonView.controller.toggle()
        selected = cell?.songButtonView.controller.song
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SearchSongCollectionCell
    
        let song = songs[indexPath.item]
        
        cell.songButtonView.controller.song = song
        cell.songTitleLabel.text = song.title
        cell.songArtistLabel.text = song.artist
        
        if selected?.isEqual(song) == true {
            cell.backgroundColor = UIColor.hearGrayColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
    }
}
