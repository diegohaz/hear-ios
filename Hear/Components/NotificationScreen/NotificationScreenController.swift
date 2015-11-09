//
//  NotificationScreenController.swift
//  Hear
//
//  Created by Diego Haz on 11/9/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class NotificationScreenController: UIViewController {
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationButton: GenericButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = UINib(nibName: "NotificationScreen", bundle: nil).instantiateWithOwner(self, options: nil)[0] as? UIView
        
        notificationButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "notificationButtonDidTouch"))
    }
    
    override func viewDidAppear(animated: Bool) {
        notificationLabel.rise { (f) -> Void in
            self.notificationButton.expand()
        }
    }
    
    func notificationButtonDidTouch() {
        NotificationManager.sharedInstance.request()
        dismissViewControllerAnimated(false, completion: nil)
    }
}
