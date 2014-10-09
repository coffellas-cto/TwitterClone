//
//  TwitterNetworkController.swift
//  TwitterClone
//
//  Created by Alex G on 08.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import Foundation
import Accounts
import Social

class TwitterNetworkController {
    private var twitterAccount: ACAccount?
    private var accountType: ACAccountType
    private var urlSession: NSURLSession
    
    // Singleton instantiation
    class var controller: TwitterNetworkController {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : TwitterNetworkController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = TwitterNetworkController()
        }
        return Static.instance!
    }
    
    init () {
        accountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        urlSession = NSURLSession.sharedSession()//
        (configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }
    
    // MARK: Public Methods
    
    func downloadImage(#imageURLString: String, completion: (image: UIImage?) -> Void) {
//        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: imageURLString), completionHandler: { (data: NSData!, resonse: NSURLResponse!, error: NSError!) -> Void in
//            if error != nil {
//                println("\(error.localizedDescription) for \(imageURLString)")
//                return
//            }
//            
//            completion(image: UIImage(data: data))
//        }).resume()
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: imageURLString)))
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(image: image)
            })
        })
    }
    
    func fetchTimeline(completion: (errorString: String?, tweetsData: NSData?) -> Void) {
        performRequest(requestMethod: .GET, URLString: "https://api.twitter.com/1.1/statuses/home_timeline.json", parameters: ["count": "40"], completion: { (errorString, data) -> Void in
            if errorString != nil {
                completion(errorString: errorString, tweetsData: nil)
                return
            }
            
            if let data = data {
                completion(errorString: nil, tweetsData: data)
                return
            }
            
            completion(errorString: "Could not parse JSON data", tweetsData: nil)
        })
    }
    
    // MARK: Private Methods
    private func performRequest(#requestMethod: SLRequestMethod, URLString: String, parameters: [NSObject : AnyObject]!, completion: (errorString: String?, data: NSData?) -> Void) {
        if twitterAccount != nil {
            self.performRequestUnderHood(requestMethod: requestMethod, URLString: URLString, parameters: parameters, completion: completion)
            return
        }
        
        ACAccountStore().requestAccessToAccountsWithType(accountType, options: nil) { (granted, error) -> Void in
            if !granted || (error != nil) {
                completion(errorString: "Access to accounts not granted", data: nil)
                return
            }
            
            let accounts = ACAccountStore().accountsWithAccountType(self.accountType)
            self.twitterAccount = accounts.first as? ACAccount
            
            self.performRequestUnderHood(requestMethod: requestMethod, URLString: URLString, parameters: parameters, completion: completion)
        }
    }
    
    private func performRequestUnderHood(#requestMethod: SLRequestMethod, URLString: String, parameters: [NSObject : AnyObject]!, completion: (errorString: String?, data: NSData?) -> Void) {
        let timelineRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: requestMethod, URL: NSURL(string: URLString), parameters: parameters)
        timelineRequest.account = self.twitterAccount
        timelineRequest.performRequestWithHandler({ (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            if error != nil {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completion(errorString: "Error happened during constructing request", data: nil)
                })
                return
            }
            
            var errorString: String?
            switch response.statusCode {
            case 200...299:
                break
            case 400...499:
                errorString = "Client error"
            case 500...599:
                errorString = "Server error"
            default:
                errorString = "Unknown error"
            }
            
            if let errorString = errorString {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completion(errorString: "\(errorString): \(response.statusCode)", data: nil)
                })
                return
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completion(errorString: nil, data: data)
            })
            
        })
    }
}