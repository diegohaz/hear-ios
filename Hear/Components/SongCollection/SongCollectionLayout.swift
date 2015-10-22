//
//  RadarLayout.swift
//  Hear
//
//  Created by Diego Haz on 9/30/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class SongCollectionLayout: UICollectionViewFlowLayout {

    let itemSpacing: CGFloat = 8
    var layoutInfo: [NSIndexPath:UICollectionViewLayoutAttributes] = [NSIndexPath:UICollectionViewLayoutAttributes]()
    var maxXPos: CGFloat = 0
    var itemWidth: CGFloat = 80
    var itemHeight: CGFloat = 80
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        itemWidth = (UIScreen.mainScreen().bounds.width - 4 * 8)/3
        itemHeight = itemWidth * 1.375
        
        self.itemSize = CGSizeMake(itemWidth, itemHeight)
        self.minimumInteritemSpacing = itemSpacing
        self.minimumLineSpacing = itemSpacing
        self.scrollDirection = UICollectionViewScrollDirection.Vertical
    }
    
    override func prepareLayout() {
        layoutInfo = [NSIndexPath:UICollectionViewLayoutAttributes]()
        
        for var i = 0; i < collectionView?.numberOfItemsInSection(0); i++ {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            itemAttributes.frame = frameForItemAtIndexPath(indexPath)
            
            if itemAttributes.frame.origin.x > maxXPos {
                maxXPos = itemAttributes.frame.origin.x
            }
            
            layoutInfo[indexPath] = itemAttributes
        }
    }
    
    func frameForItemAtIndexPath(indexPath: NSIndexPath) -> CGRect {
        let currentItemInRow = floor(CGFloat(indexPath.item % 3))
        let currentColumn = floor(CGFloat(indexPath.item % 3)) + 1
        let numRows = floor(CGFloat(indexPath.item/3))
        let yBase = sectionInset.top + (itemHeight + itemSpacing) * numRows
        let y: CGFloat = currentColumn == 1 ? yBase : yBase + itemHeight/2
        var x = sectionInset.left + (itemWidth + itemSpacing) * currentItemInRow
        
        if currentColumn == 1 {
            x += itemWidth + itemSpacing
        } else if currentColumn == 2 {
            x -= itemWidth + itemSpacing
        }
        
        let rect = CGRectMake(x, y, itemWidth, itemHeight)
        
        return rect
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutInfo[indexPath]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        
        for (_, attributes) in layoutInfo {
            if CGRectIntersectsRect(rect, attributes.frame) {
                allAttributes.append(attributes)
            }
        }
        
        return allAttributes
    }
    
}
