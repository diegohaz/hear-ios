//
//  RadarController.swift
//  Hear
//
//  Created by Diego Haz on 9/30/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import CoreLocation

class RadarController: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var view: RadarView!
    var songs = [Song]()
    
    init(view: RadarView) {
        super.init()
        
        self.view = view
        self.view.alwaysBounceVertical = true
        
        let location = CLLocation(latitude: -43, longitude: -22)
        
        API.listSongs(location) { (songs, error) -> Void in
            self.songs = songs
            self.setup()
            self.view.reloadData()
        }
    }
    
    private func setup() {
        for i in 0 ... songs.count - 1 {
            view.registerClass(RadarCell.self, forCellWithReuseIdentifier: "Cell\(i)")
        }
        view.delegate = self
        view.dataSource = self
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let paths = view.indexPathsForVisibleItems()
        
        for path in paths {
            if let cell = view.cellForItemAtIndexPath(path) as? RadarCell {
                cell.fade(view)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell\(indexPath.item)", forIndexPath: indexPath) as! RadarCell
        let song = songs[indexPath.item]
        
        cell.songButtonView.songTitleLabel.text = song.title
        cell.songButtonView.songArtistLabel.text = song.artist
        cell.songButtonView.songImageView.image = UIImage(data: NSData(contentsOfURL: song.cover)!)
        cell.songButtonView.controller.songPreview = song.preview
        
        cell.fade(collectionView)
        
        return cell
    }
}
