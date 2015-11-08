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
    var noResultsLabel: UILabel!
    
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
        
        noResultsLabel = UILabel(frame: CGRect(x: 16, y: 16, width: UIScreen.mainScreen().bounds.width - 32, height: 48))
        noResultsLabel.font = UIFont.systemFontOfSize(14)
        noResultsLabel.numberOfLines = 0
        noResultsLabel.textAlignment = .Center
        noResultsLabel.hidden = true
        addSubview(noResultsLabel)
    }
    
    override func drawRect(rect: CGRect) {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: bounds.width, height: 64)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
    }

}
