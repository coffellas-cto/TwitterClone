//
//  Twitter.swift
//  TwitterClone
//
//  Created by Alex G on 06.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import Foundation

class Tweet {
    // MARK: Public Properties
    var text: String?
    var dateText: String?
    
    init (tweetDictionary dic: NSDictionary) {
        text = dic["text"] as? String
        dateText = dic["created_at"] as? String
    }
    
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
}