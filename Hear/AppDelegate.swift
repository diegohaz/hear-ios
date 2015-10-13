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
    var locationManager = LocationManager.sharedInstance


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Initialize Parse.
        Parse.setApplicationId("YoKGeRRzGizxpkXM6V11kfaV6iX3KXt7QSJeNeXR",
            clientKey: "YO570TcN3GNXNtKbpk6cesIJ53S7V1l3Tdd11pFz")
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = HomeScreenController.sharedInstance;
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event?.type == UIEventType.RemoteControl {
            if event!.subtype == UIEventSubtype.RemoteControlPlay {
                print("received remote play")
                AudioManager.sharedInstance.play()
            } else if event?.subtype == UIEventSubtype.RemoteControlPause {
                print("received remote pause")
                AudioManager.sharedInstance.pause()
            } else if event?.subtype == UIEventSubtype.RemoteControlTogglePlayPause {
                print("received toggle")
                AudioManager.sharedInstance.toggle()
            } else if event?.subtype == UIEventSubtype.RemoteControlNextTrack {
                AudioManager.sharedInstance.playNext()
            } else if event?.subtype == UIEventSubtype.RemoteControlPreviousTrack {
                AudioManager.sharedInstance.playPrevious()
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

