//
//  User.swift
//  TwitterClone
//
//  Created by Alex G on 09.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import Foundation
import UIKit

class User {
    var imageUrl: String?
    var userName: String?
    var alias: String?
    var userColorString: NSString?
    var backgroundColor: UIColor? {
        get {
            if userColorString != nil {
                return colorWithHexString(userColorString!)
            }
            
            return nil
        }
    }
    
    init() {
    }
    
    init(jsonData: NSData) {
        var error: NSError?
        if let userObject = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as? NSDictionary {
            imageUrl = userObject["profile_image_url"] as? String
            userName = userObject["name"] as? String
            alias = userObject["screen_name"] as? String
            userColorString = userObject["profile_background_color"] as? NSString
        }
    }
    
    // MARK: Methods
    private func colorWithHexString (hexString: NSString) -> UIColor? {
        if (hexString.length != 6) {
            return nil
        }
        
        var rString = hexString.substringToIndex(2)
        var gString = hexString.substringWithRange(NSRange(location: 2, length: 2))
        var bString = hexString.substringWithRange(NSRange(location: 4, length: 2))
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
        NSScanner.scannerWithString(rString).scanHexInt(&r)
        NSScanner.scannerWithString(gString).scanHexInt(&g)
        NSScanner.scannerWithString(bString).scanHexInt(&b)
        
        var rf: CGFloat = CGFloat(r)
        var gf: CGFloat = CGFloat(g)
        var bf: CGFloat = CGFloat(b)
        
        return UIColor(red: rf / 255.0, green: gf / 255.0, blue: bf / 255.0, alpha: 1.0)
    }
}