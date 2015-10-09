//
//  AudioManager.swift
//  Hear
//
//  Created by Diego Haz on 10/9/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import AVFoundation

class AudioManager {
    static let sharedInstance = AudioManager()
    
    var player = AVAudioPlayer()
    
    func load(data: NSData) {
        player = try! AVAudioPlayer(data: data)
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
}
