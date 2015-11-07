//
//  SongButtonController.swift
//  Hear
//
//  Created by Diego Haz on 9/27/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import AVFoundation
import Bolts

class SongButtonController: NSObject {
    weak var view: SongButton!
    var timer: NSTimer?
    var audio = AudioManager.sharedInstance
    var song: Song? {
        didSet {
            let song = self.song
            let size: ImageSize = view.bounds.width < 50 ? .Small : .Medium
            let task = song?.image.load(size, rounded: true)
            
            task?.continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                if song?.id == self.song?.id {
                    self.view.songImageView.image = task.result as? UIImage
                }
                
                return nil
            })
            
            statusChanged()
        }
    }
    
    init(view: SongButton) {
        super.init()
        
        self.view = view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewDidTouch"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusChanged", name: AudioManagerWillLoadNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusChanged", name: AudioManagerDidPlayNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusChanged", name: AudioManagerDidPauseNotification, object: nil)
        
        audio.addObserver(self, forKeyPath: "time", options: .New, context: nil)
    }
    
    func viewDidTouch() {
        view.bounce()
        toggle()
    }
    
    func statusChanged() {
        guard let song = song where audio.current(song: song) else {
            view?.timePercent = 0
            view?.pause()
            return
        }
        
        switch audio.status {
        case .Loading:
            view?.load()
            break
        case .Paused:
            view?.pause()
            break
        case .Playing:
            view?.play()
            break
        case .Idle:
            view?.timePercent = 0
            view?.pause()
        }
    }
    
    func toggle() {
        guard let song = song else { return }
        
        if audio.playing(song: song) {
            audio.pause()
        } else if audio.current(song: song) {
            audio.play()
        } else {
            audio.play(song)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "time" {
            updateTime()
        }
    }
    
    private func updateTime() {
        if song != nil && audio.current(song: song!) {
            view?.timePercent = CGFloat(audio.time/audio.duration)
        } else if view?.timePercent != 0 {
            view?.timePercent = 0
        }
    }
}
