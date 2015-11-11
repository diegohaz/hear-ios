//
//  NotificationManager.swift
//  Hear
//
//  Created by Diego Haz on 11/9/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class NotificationManager: NSObject {
    static let sharedInstance = NotificationManager()
    
    var openedBySystem  = false
    let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
    
    func requested() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let requested = defaults.valueForKey("LocalNotificationsRequested") as? Bool {
            return requested
        } else {
            return false
        }
    }
    
    func request() {
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        defaults.setBool(true, forKey: "LocalNotificationsRequested")
    }
    
    func send(message: String) {
        if !openedBySystem { return }
        
        let notification = UILocalNotification()
        
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 1
        notification.fireDate = NSDate().dateByAddingTimeInterval(1)
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
