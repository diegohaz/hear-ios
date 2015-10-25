//
//  SearchSongCollectionView.swift
//  Hear
//
//  Created by Diego Haz on 10/24/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class SearchSongCollectionView: UICollectionView {
    var controller: SearchSongCollectionController!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        controller = SearchSongCollectionController(view: self)
        
        backgroundColor = UIColor.whiteColor()
    }
    
    override func drawRect(rect: CGRect) {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: bounds.width, height: 64)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
    }

}
