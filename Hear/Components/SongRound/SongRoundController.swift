//
//  SongRoundController.swift
//  Hear
//
//  Created by Diego Haz on 9/30/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class SongRoundController: NSObject {
    var view: SongRoundView!
    
    init(view: SongRoundView) {
        super.init()
        
        self.view = view
        self.loadImage()
    }
    
    func loadImage() {
        let width = Int(view.songImageView.bounds.width * 3)
        let height = Int(view.songImageView.bounds.height * 3)
        let url = NSURL(string: "http://lorempixel.com/\(width)/\(height)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.view.songImageView.image = UIImage(data: data!)
                })
            }
        }
        
        task.resume()
    }
}
