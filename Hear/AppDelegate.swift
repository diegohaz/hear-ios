//
//  AppDelegate.swift
//  Hear
//
//  Created by Diego Haz on 9/25/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let location = LocationManager.sharedInstance
    let audio = AudioManager.sharedInstance


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Initialize Parse.
        Parse.setApplicationId("aQTf0BbHW5o643oIjuBVht36Q5IPzKbsu62rmT7Q",
            clientKey: "FTm3d5cmxLM40vhYR8w9k3LCHRggyhCJAo2ZafkR")
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = HomeScreenController.sharedInstance;
        self.window?.makeKeyAndVisible()
        
        application.setMinimumBackgroundFetchInterval(60 * 60)
        
        if launchOptions?[UIApplicationLaunchOptionsLocationKey] != nil {
            let notification = NotificationManager.sharedInstance
            
            notification.openedBySystem = true
        }
        
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event?.type == UIEventType.RemoteControl {
            if event!.subtype == .RemoteControlPlay {
                audio.play()
            } else if event?.subtype == .RemoteControlPause {
                audio.pause()
            } else if event?.subtype == .RemoteControlTogglePlayPause {
                audio.toggle()
            } else if event?.subtype == .RemoteControlNextTrack {
                audio.playNext()
            } else if event?.subtype == .RemoteControlPreviousTrack {
                audio.playPrevious()
            }
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        location.startUpdatingLocation()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        location.startUpdatingLocation()
    }

    func applicationWillTerminate(application: UIApplication) {
        location.startUpdatingLocation()
    }

}

