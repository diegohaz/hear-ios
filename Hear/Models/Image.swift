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
    case Small = "small"
    case Medium = "medium"
    case Big = "big"
}

class Image: NSObject {
    private static var images = [String: Image]()
    private var id: String
    
    private var image: [ImageSize: UIImage?] = [
        .Small: nil,
        .Medium: nil,
        .Big: nil
    ]
    
    private var roundedImage: [ImageSize: UIImage?] = [
        .Small: nil,
        .Medium: nil,
        .Big: nil
    ]
    
    private var url: [ImageSize: NSURL?] = [
        .Small: nil,
        .Medium: nil,
        .Big: nil
    ]
    
    private var task: [ImageSize: BFTask?] = [
        .Small: nil,
        .Medium: nil,
        .Big: nil
    ]
    
    private init(smallUrl: NSURL, mediumUrl: NSURL? = nil, bigUrl: NSURL? = nil) {
        self.id = smallUrl.absoluteString
        
        url[.Small] = smallUrl
        url[.Medium] = mediumUrl
        url[.Big] = bigUrl
    }
    
    static func create(smallUrl: NSURL, mediumUrl: NSURL? = nil, bigUrl: NSURL? = nil) -> Image {
        let id = smallUrl.absoluteString
        
        if images.indexForKey(id) != nil {
            return images[id]!
        }
        
        images[id] = Image(smallUrl: smallUrl, mediumUrl: mediumUrl, bigUrl: bigUrl)
        return images[id]!
    }
    
    func load(var size: ImageSize = .Small, rounded: Bool = false) -> BFTask {
        size = isSizeAvailable(size) ? getSizeForReachability(size) : ImageSize.Small
        
        let image = rounded ? roundedImage[size] : self.image[size]
        let task = self.task[size]
        
        if image! != nil {
            return BFTask(result: image!)
        } else if task! != nil {
            return task!!
        } else {
            let task = rounded ? load(size, rounded: false) : BFTask(delay: 0)
            
            return task.continueWithSuccessBlock({ (task) -> AnyObject! in
                if rounded {
                    if let image = task.result as? UIImage {
                        let rect = CGRectMake(0, 0, image.size.width, image.size.height)

                        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
                        UIBezierPath(roundedRect: rect, cornerRadius: image.size.width/2).addClip()
                        image.drawInRect(rect)
                        
                        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
                        self.roundedImage[size] = roundedImage
                        
                        UIGraphicsEndImageContext()
                        
                        return roundedImage
                    }
                } else if let data = NSData(contentsOfURL: self.url[size]!!) {
                    self.image[size] = UIImage(data: data)
                    
                    return self.image[size]!
                }
                
                return BFTask(error: NSError(domain: BFTaskErrorDomain, code: 0, userInfo: nil))
            })
        }
    }
    
    func getLargestAvailable() -> UIImage? {
        if let big = image[.Big]! {
            return big
        } else if let medium = image[.Medium]! {
            return medium
        } else if let small = image[.Small]! {
            return small
        }
        
        return nil
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
            }
        }
    }
    
    private func isSizeAvailable(size: ImageSize) -> Bool {
        return url[size] != nil
    }
}