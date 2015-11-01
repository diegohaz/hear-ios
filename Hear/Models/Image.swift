//
//  Image.swift
//  Hear
//
//  Created by Diego Haz on 11/1/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts

enum ImageSize: String {
    case Default = "default"
    case Small = "small"
    case Medium = "medium"
    case Big = "big"
}

class Image: NSObject {
    var defaultImage: UIImage!
    var smallImage: UIImage?
    var mediumImage: UIImage?
    var bigImage: UIImage?
    
    var roundedDefaultImage: UIImage!
    var roundedSmallImage: UIImage?
    var roundedMediumImage: UIImage?
    var roundedBigImage: UIImage?
    
    private static var images = [String: Image]()
    
    private var id: String
    
    private var defaultUrl: NSURL
    private var smallUrl: NSURL?
    private var mediumUrl: NSURL?
    private var bigUrl: NSURL?
    
    private var defaultTask: BFTask?
    private var smallTask: BFTask?
    private var mediumTask: BFTask?
    private var bigTask: BFTask?
    
    private init(defaultUrl: NSURL, smallUrl: NSURL? = nil, mediumUrl: NSURL? = nil, bigUrl: NSURL? = nil) {
        self.defaultUrl = defaultUrl
        self.id = defaultUrl.absoluteString
        
        self.smallUrl = smallUrl
        self.mediumUrl = mediumUrl
        self.bigUrl = bigUrl
    }
    
    static func create(defaultUrl: NSURL, smallUrl: NSURL? = nil, mediumUrl: NSURL? = nil, bigUrl: NSURL? = nil) -> Image {
        let id = defaultUrl.absoluteString
        
        if images.indexForKey(id) != nil {
            return images[id]!
        }
        
        images[id] = Image(defaultUrl: defaultUrl, smallUrl: smallUrl, mediumUrl: mediumUrl, bigUrl: bigUrl)
        return images[id]!
    }
    
    func load(var size: ImageSize = .Default, rounded: Bool = false) -> BFTask {
        size = getSizeForReachability(size)
        
        let sizeValue = isSizeAvailable(size) ? size.rawValue : ImageSize.Default.rawValue
        let imageProperty = rounded ? "rounded\(sizeValue.capitalizedString)Image" : "\(sizeValue)Image"
        let taskProperty = "\(sizeValue)Task"
        let urlProperty = "\(sizeValue)Url"
        
        if let image = self.valueForKey(imageProperty) as? UIImage {
            return BFTask(result: image)
        } else if let task = self.valueForKey(taskProperty) as? BFTask {
            return task
        } else {
            let task = rounded ? load(size, rounded: false) : BFTask(delay: 0)
            
            task.continueWithSuccessBlock({ (task) -> AnyObject! in
                if rounded {
                    if let image = task.result as? UIImage {
                        let rect = CGRectMake(0, 0, image.size.width, image.size.height)
                        
                        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
                        UIBezierPath(roundedRect: rect, cornerRadius: image.size.width/2).addClip()
                        image.drawInRect(rect)
                        
                        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
                        self.setValue(roundedImage, forKey: imageProperty)
                        
                        UIGraphicsEndImageContext()
                        
                        return roundedImage
                    }
                } else if let data = NSData(contentsOfURL: self.valueForKey(urlProperty) as! NSURL) {
                    let image = UIImage(data: data)
                    self.setValue(image, forKey: imageProperty)
                    
                    return image
                }
                
                return BFTask(error: NSError(domain: BFTaskErrorDomain, code: 0, userInfo: nil))
            })
            
            return task
        }
    }
    
    private func getSizeForReachability(size: ImageSize) -> ImageSize {
        let reachability = Reachability.reachabilityForInternetConnection()
        
        if reachability?.isReachableViaWiFi() == true {
            return size
        } else {
            switch size {
            case .Big:
                return .Medium
            case .Medium:
                return .Small
            case .Small:
                return .Small
            default:
                return .Default
            }
        }
    }
    
    private func isSizeAvailable(size: ImageSize) -> Bool {
        return valueForKey("\(size.rawValue)Url") as? NSURL != nil
    }
}