//
//  SearchSongTextFieldView.swift
//  Hear
//
//  Created by Diego Haz on 10/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class SearchSongTextFieldView: UITextField {
    var controller: SearchSongTextFieldController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        controller = SearchSongTextFieldController(view: self)
        
        placeholder = "Search for songs or artists"
        backgroundColor = UIColor.hearGrayColor()
        borderStyle = .RoundedRect
        returnKeyType = .Search
        clearButtonMode = .Always
    }
}
