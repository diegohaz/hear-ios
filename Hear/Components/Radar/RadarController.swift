//
//  RadarController.swift
//  Hear
//
//  Created by Diego Haz on 9/30/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class RadarController: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var view: RadarView!
    
    init(view: RadarView) {
        super.init()
        
        self.view = view
        setup()
    }
    
    private func setup() {
        view.registerClass(RadarCell.self, forCellWithReuseIdentifier: "Cell")
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
        return 25
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! RadarCell
        cell.songButtonView.songTitleLabel.text = "Another Brick In The Wall \(indexPath.item + 1)"
        cell.songButtonView.songArtistLabel.text = "Pink Floyd"
        
        cell.fade(collectionView)
        
        return cell
    }
}
