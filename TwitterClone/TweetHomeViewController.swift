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
        
        self.activityIndicator.startAnimating()
        
        TwitterNetworkController.controller.fetchTimeline { (errorString: String?, tweets: [Tweet]?) -> Void in
            self.activityIndicator.stopAnimating()
            
            if let errorString = errorString {
                UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "OK").show()
                return
            }
            
            self.tweetsArray.extend(tweets!)
            self.tweetsTable.reloadData()
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
