//
//  AvatarDownloadOperation.swift
//  TwitterClone
//
//  Created by Alex G on 07.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit

class AvatarDownloadOperation: NSOperation {
    
    let url: String
    let indexPath: NSIndexPath?
    let completion: (NSData?, NSIndexPath?) -> Void
    
    // MARK: NSOperation specific methods
    
    init(url: String, indexPath: NSIndexPath, completion: (NSData?, NSIndexPath?) -> Void) {
        self.url = url
        self.indexPath = indexPath
        self.completion = completion
    }
    
    override func main () {
        if self.cancelled {
            return
        }
        
        let imageData = NSData(contentsOfURL:NSURL(string: url.stringByReplacingOccurrencesOfString("_normal", withString: "_bigger", options: nil, range: nil)))
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.completion(imageData, self.indexPath)
        })
    }
   
}
