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
    private var backgroundQueue: NSOperationQueue = NSOperationQueue()
    private var avatarImagesDictionary = Dictionary<String, UIImage>()

    // MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetsTable.backgroundColor = UIColor.clearColor()
        tweetsTable.estimatedRowHeight = 44
        tweetsTable.rowHeight = UITableViewAutomaticDimension
        
        self.activityIndicator.startAnimating()
        
        TwitterNetworkController.controller.fetchTimeline { (errorString: String?, tweets: [Tweet]?) -> Void in
            self.activityIndicator.stopAnimating()
            
            if let errorString = errorString {
                println(errorString)
                UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "OK").show()
                return
            }
            
            self.tweetsArray.extend(tweets!)
            self.tweetsTable.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        tweetsTable.separatorInset = UIEdgeInsetsZero
        tweetsTable.layoutMargins = UIEdgeInsetsZero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vcToPush = segue.destinationViewController as SingleTweetViewController;
        vcToPush.tweet = sender as? Tweet;
    }
    
    // MARK: UITableView Delegates Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL") as TweetCell
        
        if indexPath.row >= tweetsArray.count {
            cell.userName.text = nil
            cell.alias.text = nil
            cell.tweetText.text = nil
            cell.time.text = nil
            return cell
        }
        
        var tweet = tweetsArray[indexPath.row]
        
        cell.userName.text = tweet.userName
        cell.alias.text = "@" + tweet.alias!
        cell.tweetText.text = tweet.text
        cell.time.text = tweet.dateString()
        
        if let imageUrl = tweet.imageUrl {
            if let image = avatarImagesDictionary[imageUrl] {
                cell.avatar.image = image
            }
            else {
                cell.avatar.image = UIImage(named: "avatar")
                
                let avatarDownloadOperation = AvatarDownloadOperation(url: imageUrl, indexPath: indexPath, completion: { (imageData: NSData?, path: NSIndexPath?) -> Void in
                    if (indexPath.row < self.tweetsArray.count) && imageData != nil {
                        let newImage = UIImage(data: imageData!, scale: UIScreen.mainScreen().scale)
                        self.avatarImagesDictionary[imageUrl] = newImage
                        
                        if let cell = self.tweetsTable.cellForRowAtIndexPath(indexPath) as? TweetCell {
                            cell.avatar.image = newImage
                        }
                    }
                })
                backgroundQueue.addOperation(avatarDownloadOperation)
            }
        }
        else {
            cell.avatar.image = UIImage(named: "avatar")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tweetsTable.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.row < tweetsArray.count {
            performSegueWithIdentifier("showSingleTweet", sender: tweetsArray[indexPath.row])
        }
    }
    
    
    // MARK: Private Methods

}
