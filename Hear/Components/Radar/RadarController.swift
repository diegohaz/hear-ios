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
            hideCell(view.cellForItemAtIndexPath(path) as! RadarCell)
        }
    }
    
    func hideCell(cell: RadarCell) {
        let cellMaxY = cell.frame.maxY
        let cellMinY = cell.frame.minY
        let limitTop = view.contentOffset.y + 64
        let limitBottom = view.contentOffset.y + view.bounds.height - 64
        
        if cellMaxY > limitBottom {
            cell.contentView.alpha = 0.5 - (cellMaxY - limitBottom)/cell.bounds.height
            cell.songButtonView.songRoundView.transform = CGAffineTransformMakeScale(cell.contentView.alpha + 0.5, cell.contentView.alpha + 0.5)
        } else if cellMinY < limitTop {
            cell.contentView.alpha = 0.5 - (limitTop - cellMinY)/cell.bounds.height
            cell.songButtonView.songRoundView.transform = CGAffineTransformMakeScale(cell.contentView.alpha + 0.5, cell.contentView.alpha + 0.5)
        } else {
            cell.contentView.alpha = 1
            cell.songButtonView.songRoundView.transform = CGAffineTransformMakeScale(1, 1)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! RadarCell
        cell.songButtonView.songTitleLabel.text = "Música legal \(indexPath.item)"
        
        hideCell(cell)
        
        return cell
    }
}
