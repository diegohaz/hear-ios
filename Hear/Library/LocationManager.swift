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
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        print("\(location?.coordinate.latitude),\(location?.coordinate.longitude)")
        
        if originalLocation == nil || location?.distanceFromLocation(originalLocation!) > 500 {
            originalLocation = location
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManagerNotification, object: location)
        }
    }
}
