//
//  TweetHomeViewController.swift
//  TwitterClone
//
//  Created by Alex G on 06.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit
import Accounts
import Social

class TweetHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Outlets
    @IBOutlet weak var tweetsTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // MARK: Private properties
    private var tweetsArray = [Tweet]()
    private var twitterAccount: ACAccount?
    private var backgroundQueue: NSOperationQueue = NSOperationQueue()
    private var avatarImagesDictionary = Dictionary<String, NSData>()

    // MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetsTable.backgroundColor = UIColor(red: 245/255, green: 244/255, blue: 242/255, alpha: 1)
        tweetsTable.estimatedRowHeight = 44
        tweetsTable.rowHeight = UITableViewAutomaticDimension
        
        let accountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        ACAccountStore().requestAccessToAccountsWithType(accountType, options: nil) { (granted, error) -> Void in
            if !granted || (error != nil) {
                return
            }
            
            let accounts = ACAccountStore().accountsWithAccountType(accountType)
            self.twitterAccount = accounts.first as? ACAccount
            
            self.activityIndicator.startAnimating()
            
            let timelineRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json"), parameters: ["count": "40"])
            timelineRequest.account = self.twitterAccount
            timelineRequest.performRequestWithHandler({ (jsonData: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                if error != nil {
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
                
                if errorString != nil {
                    println("\(errorString): \(response.statusCode)")
                    return
                }
                
                if let tweetsArray = Tweet.parseJSONDataIntoTweets(jsonData) {
                    self.tweetsArray.extend(tweetsArray)
                }
                
                println(self.tweetsArray.count)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.activityIndicator.stopAnimating()
                    self.tweetsTable.reloadData()
                })
                
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableView Delegates Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL") as TweetCell
        
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.textLabel?.numberOfLines = 0;
        
        var tweet = tweetsArray[indexPath.row]
        
        
        cell.userName.text = tweet.userName
        cell.alias.text = "@" + tweet.alias!
        cell.tweetText.text = tweet.text
        cell.time.text = tweet.dateString()
        
        if let imageUrl = tweet.imageUrl {
            if let imageData = avatarImagesDictionary[imageUrl] {
                cell.avatar.image = UIImage(data: imageData, scale: UIScreen.mainScreen().scale)
            }
            else {
                cell.avatar.image = UIImage(named: "avatar.png")
                
                let avatarDownloadOperation = AvatarDownloadOperation(url: imageUrl, indexPath: indexPath, completion: { (imageData: NSData?, path: NSIndexPath) -> Void in
                    if (indexPath.row < self.tweetsArray.count) && imageData != nil {
                        self.avatarImagesDictionary[imageUrl] = imageData
                        self.tweetsTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                })
                backgroundQueue.addOperation(avatarDownloadOperation)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsArray.count;
    }
    
    override func viewDidLayoutSubviews() {
        tweetsTable.separatorInset = UIEdgeInsetsZero
        tweetsTable.layoutMargins = UIEdgeInsetsZero
    }
    
    
    // MARK: Private Methods

}
