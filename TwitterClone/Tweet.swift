//
//  Twitter.swift
//  TwitterClone
//
//  Created by Alex G on 06.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import Foundation
import UIKit

extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
        // TODO: Use US locale as default, but might need other if sent other
        self.locale = NSLocale(localeIdentifier: "en_US")
    }
}

class Tweet {
    // MARK: Public Properties
    var user: User?
    var text: String?
    var favouriteCount: Int?
    var retweets: Int?
    
    // MARK: Private Properties
    private var date: NSDate?
    
    // MARK: 
    init(tweetDictionary dic: NSDictionary) {
        text = dic["text"] as? String
        favouriteCount = dic["favorite_count"] as? Int
        retweets = dic["retweet_count"] as? Int
        if let userObject: AnyObject = dic["user"] {
            // TODO: Actually user objects should be global so several tweets can have one and only user object
            // associated with it
            
            user = User()
            if let user = user {
                user.id = userObject["id"] as? Int
                user.imageUrl = userObject["profile_image_url"] as? String
                user.userName = userObject["name"] as? String
                user.alias = userObject["screen_name"] as? String
                user.userColorString = userObject["profile_background_color"] as? NSString
            }
        }
        
        // Format that date
        var dateFormatter = NSDateFormatter(dateFormat: "EEE MMM dd HH:mm:ss Z yyyy")
        if let originalDateText = dic["created_at"] as? String {
            date = dateFormatter.dateFromString(originalDateText)
        }
    }
    
    // MARK: Class Methods
    // Factory Method
    class func parseJSONDataIntoTweets(rawJSONData: NSData) -> [Tweet]? {
        var error: NSError?
        if let JSONArray = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSArray {
            var tweets = [Tweet]()
            for JSONDictionary in JSONArray {
                if let tweetDictionary = JSONDictionary as? NSDictionary {
                    tweets.append(Tweet(tweetDictionary: tweetDictionary))
                }
            }
            
            return tweets
        }
        
        return nil
    }
    
    // MARK: Public Methods
    func dateString() -> String {
        if date == nil {
            return ""
        }
        
        // Return date depending on now
        let now = NSDate()
        let flags: NSCalendarUnit = .YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date!, toDate: now, options: nil)
    
        // Year
        switch components.year {
        case 1...3:
            return "\(components.year)y"
        case let x where x > 3:
            var dateFormatter = NSDateFormatter(dateFormat: "yyyy")
            return dateFormatter.stringFromDate(date!)
        default:
            break
        }
        
        // Month & Day
        if (components.month > 0) || (components.day > 1) {
            var dateFormatter = NSDateFormatter(dateFormat: "MMM dd")
            return dateFormatter.stringFromDate(date!)
        }
        
        // Yeasterday
        if components.day > 0 {
            return "Yesterday"
        }
        
        // Hour
        if components.hour > 0 {
            return "\(components.hour)h"
        }
        
        // Minute & Second        
        switch components.minute {
        case 0:
            return "\(components.second)s"
        default:
            return "\(components.minute)m"
        }
        
    }
}