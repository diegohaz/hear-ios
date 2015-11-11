//
//  LocationManager.swift
//  Hear
//
//  Created by Diego Haz on 10/12/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import CoreLocation

public let LocationManagerNotification = "LocationManagerNotifcation"

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = LocationManager()
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var originalLocation: CLLocation?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
    func request() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        let state = UIApplication.sharedApplication().applicationState
        
        if state == .Active {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .NotDetermined || status == .Restricted || status == .Denied  {
            HomeScreenController.sharedInstance.presentViewController(TutorialScreenController(), animated: false, completion: nil)
        } else if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            if !NotificationManager.sharedInstance.requested() {
                HomeScreenController.sharedInstance.presentViewController(NotificationScreenController(), animated: false, completion: nil)
            }
            
            startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        print("Location has changed! \(location!.speed)")
        
        if originalLocation == nil || location?.distanceFromLocation(originalLocation!) > 1000 {
            originalLocation = location
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManagerNotification, object: location)
        }
    }
}
