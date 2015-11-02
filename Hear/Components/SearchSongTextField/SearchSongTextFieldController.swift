//
//  SearchSongTextFieldController.swift
//  Hear
//
//  Created by Diego Haz on 10/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

let SearchSongTextFieldNotification = "SearchSongTextFieldNotification"

class SearchSongTextFieldController: NSObject, UITextFieldDelegate {
    weak var view: SearchSongTextField!
    
    init(view: SearchSongTextField) {
        super.init()
        
        self.view = view
        self.view.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text where text.characters.count > 1 {
            NSNotificationCenter.defaultCenter().postNotificationName(SearchSongTextFieldNotification, object: text)
            textField.resignFirstResponder()
        
            return true
        } else {
            return false
        }
    }
}
