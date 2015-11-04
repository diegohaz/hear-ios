//
//  SearchSongTextField.swift
//  Hear
//
//  Created by Diego Haz on 10/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

@IBDesignable class SearchSongTextField: UITextField {
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
        borderStyle = .None
        returnKeyType = .Search
        clearButtonMode = .Always
    }
}
