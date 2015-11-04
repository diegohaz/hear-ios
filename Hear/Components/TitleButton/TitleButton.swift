//
//  TitleButton.swift
//  Hear
//
//  Created by Diego Haz on 10/9/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit

class TitleButton: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var springIndicator: SpringIndicator!
    
    var loading: Bool = false {
        didSet {
            if loading {
                hideAll(but: springIndicator)
                springIndicator.startAnimation()
            } else {
                restore()
                springIndicator.stopAnimation(false)
            }
        }
    }
    
    var title: String? {
        didSet {
            if title != nil && title != "" {
                if !loading {
                    hideAll(but: titleLabel)
                }
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var place: String? {
        didSet {
            if place != nil && place != "" {
                if !loading && distance != nil && distance != "" {
                    title = nil
                    hideAll(but: placeLabel, distanceLabel)
                } else if !loading {
                    title = place
                }
            } else {
                placeLabel.text = nil
            }
        }
    }
    
    var distance: String? {
        didSet {
            if distance != nil && distance != "" {
                if !loading && place != nil && place != "" {
                    title = nil
                    hideAll(but: placeLabel, distanceLabel)
                } else if !loading {
                    title = distance
                }
            } else {
                distanceLabel.text = nil
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        loadNib()
        clipsToBounds = true
        backgroundColor = UIColor.hearPrimaryColor()
    }
    
    override func drawRect(rect: CGRect) {
        layer.cornerRadius = bounds.height/2
        
        springIndicator.frame.origin.x = bounds.width/2 - springIndicator.bounds.width/2
        springIndicator.frame.origin.y = bounds.height/2 - springIndicator.bounds.height/2
    }
    
    private func hideAll(but objects: UIView...) {
        if !objects.contains(titleLabel) {
            titleLabel.text = nil
            titleLabel.hidden = true
        } else {
            titleLabel.text = title
            titleLabel.hidden = false
        }
        
        if !objects.contains(placeLabel) {
            placeLabel.text = nil
            placeLabel.hidden = true
        } else {
            placeLabel.text = place
            placeLabel.hidden = false
        }
        
        if !objects.contains(distanceLabel) {
            distanceLabel.text = nil
            distanceLabel.hidden = true
        } else {
            distanceLabel.text = distance
            distanceLabel.hidden = false
        }
        
        if !objects.contains(springIndicator) {
            springIndicator.hidden = true
        } else {
            springIndicator.hidden = false
        }
    }
    
    private func restore() {
        springIndicator.hidden = true
        
        if place != nil && distance != nil {
            placeLabel.text = place
            placeLabel.hidden = place != nil ? false : true
            
            distanceLabel.text = distance
            distanceLabel.hidden = distance != nil ? false : true
        } else if title != nil {
            titleLabel.text = title
            titleLabel.hidden = false
        }
    }
}
