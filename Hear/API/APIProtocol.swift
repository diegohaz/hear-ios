//
//  APIProtocol.swift
//  Hear
//
//  Created by Diego Haz on 11/1/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import CoreLocation
import Bolts

protocol APIProtocol {
    static func login() -> BFTask
    
    static func signUp() -> BFTask
    
    static func logOut() -> BFTask
    
    static func fetchPlace(location: CLLocation) -> BFTask
    
    static func searchSong(string: String, limit: Int?) -> BFTask
    
    static func placeSong(song: Song, location: CLLocation) -> BFTask
    
    static func listPlacedSongs(location: CLLocation, limit: Int?, offset: Int?, excludeIds: [String]?) -> BFTask
    
    static func removeSong(song: Song) -> BFTask
    
    static func removeArtist(song: Song) -> BFTask
}