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

// http://vperi.com/2014/06/04/flatten-an-array-to-a-string-swift-extension/
extension Array {
    func combine(separator: String) -> String{
        var str : String = ""
        for (idx, item) in enumerate(self) {
            str += "\(item)"
            if idx < self.count - 1 {
                str += separator
            }
        }
        return str
    }
}

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
    
    func setup(completion: (errorString: String?) -> Void) {
        ACAccountStore().requestAccessToAccountsWithType(accountType, options: nil) { (granted, error) -> Void in
            var errorString: String?
            if error != nil {
                errorString = "\(error!.localizedDescription)"
            }
            else if !granted {
                errorString = "Access to accounts not granted"
            }
            
            if errorString == nil {
                let accounts = ACAccountStore().accountsWithAccountType(self.accountType)
                self.twitterAccount = accounts.first as? ACAccount
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(errorString: errorString)
            })
        }
    }
    
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
    
    func fetchSelf(completion: (errorString: String?, userData: NSData?) -> Void) {
        performRequest(requestMethod: .GET, URLString: "https://api.twitter.com/1.1/account/verify_credentials.json", parameters: ["include_entities": false, "skip_status": true]) { (errorString, data) -> Void in
            completion(errorString: errorString, userData: data)
        }
    }
    
    func fetchUserTimeline(userID: Int?, sinceID: Int, maxID: Int, completion: (errorString: String?, tweetsData: NSData?) -> Void) {
        var parametersArray = [String]()
        if maxID != 0 {
            parametersArray.append("max_id=\(maxID - 1)")
        }
        else if sinceID != 0 {
            parametersArray.append("since_id=\(sinceID)")
        }
        
        var urlString: String
        
        if let userID = userID {
            parametersArray.append("user_id=\(userID)")
            urlString = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        }
        else {
            urlString = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        }
        
        if !parametersArray.isEmpty {
            let parametersString = parametersArray.combine("&")
            urlString += "?\(parametersString)"
        }
        
        performRequest(requestMethod: .GET, URLString:urlString, parameters: nil, completion: { (errorString, data) -> Void in
            completion(errorString: errorString, tweetsData: data)
        })
    }
    
    // MARK: Private Methods
    private func performRequest(#requestMethod: SLRequestMethod, URLString: String, parameters: [NSObject : AnyObject]!, completion: (errorString: String?, data: NSData?) -> Void) {
        if twitterAccount == nil {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(errorString: "No Twitter account", data: nil)
            })
            return
        }
        
        let timelineRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: requestMethod, URL: NSURL(string: URLString), parameters: parameters)
        timelineRequest.account = self.twitterAccount
        timelineRequest.performRequestWithHandler({ (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(errorString: "Error happened during constructing request: \(error.localizedDescription)", data: nil)
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
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    println(NSString(data: data, encoding: NSUTF8StringEncoding))
                    completion(errorString: "\(errorString): \(response.statusCode)", data: nil)
                })
                return
            }
            
            if data == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(errorString: "Fatal error! Request succeed, but data is nil!", data: nil)
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(errorString: nil, data: data)
            })
            
        })
    }
}