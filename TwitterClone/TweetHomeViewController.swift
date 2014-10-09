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
    private var avatarImagesDictionary = Dictionary<String, UIImage>()
    private var headerView: UserHeaderView?

    // MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI stuff
        tweetsTable.backgroundColor = UIColor.clearColor()
        tweetsTable.estimatedRowHeight = 200
        tweetsTable.rowHeight = UITableViewAutomaticDimension
        
        tweetsTable.registerNib(UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
                
        if let headerView = NSBundle.mainBundle().loadNibNamed("UserHeader", owner: self, options: nil).first as? UserHeaderView {
            self.headerView = headerView
            headerView.frame = CGRectMake(0, 0, tweetsTable.frame.width, 96)
            tweetsTable.tableHeaderView?.addSubview(headerView)
            headerView.userName.text = nil
            headerView.userAlias.text = nil
            headerView.avatar.image = UIImage(named: "avatar_big")
            
            // Fill user view
            TwitterNetworkController.controller.fetchSelf { (errorString, userData) -> Void in
                headerView.activityIndicator.stopAnimating()
                if let errorString = errorString {
                    self.showError(errorString)
                    return
                }
                
                let user: User? = User(jsonData: userData!)
                if let user = user {
                    headerView.userName.text = user.userName
                    headerView.userAlias.text = "@" + user.alias!
                    if let backgroundColor = user.backgroundColor {
                        headerView.backgroundColor = backgroundColor
                        headerView.avatar.layer.borderColor = backgroundColor.colorWithAlphaComponent(0.5).CGColor
                    }
                    
                    if let imageUrl = user.imageUrl {
                        TwitterNetworkController.controller.downloadImage(imageURLString: imageUrl.stringByReplacingOccurrencesOfString("_normal", withString: "", options: nil, range: nil)) { (image) -> Void in
                            if let image = image {
                                headerView.avatar.image = image
                            }
                        }
                    }
                }
            }
        }
        
        // Network calls
        
        self.activityIndicator.startAnimating()
        
        TwitterNetworkController.controller.fetchTimeline { (errorString: String?, tweetsData: NSData?) -> Void in
            self.activityIndicator.stopAnimating()
            
            if let errorString = errorString {
                self.showError(errorString)
                return
            }
            
            if let tweetsData = tweetsData {
                if let tweets = Tweet.parseJSONDataIntoTweets(tweetsData) {
                    self.tweetsArray.extend(tweets)
                    self.tweetsTable.reloadData()
                }
            }
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
    
    // MARK: Private Methods
    func showError(errorString: NSString) {
        println(errorString)
        UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    // MARK: UITableView Delegates Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL") as TweetCell
        
        if indexPath.row >= tweetsArray.count {
            cell.userName.text = nil
            cell.alias.text = nil
            cell.tweetText.text = nil
            cell.time.text = nil
            cell.favouriteCount.text = nil
            cell.retweets = nil
            return cell
        }
        
        var tweet = tweetsArray[indexPath.row]
        
        cell.tweetText.text = tweet.text
        cell.time.text = tweet.dateString()
        cell.favouriteCount.text = tweet.favouriteCount != nil ? String(tweet.favouriteCount!) : nil
        cell.retweets.text = tweet.retweets != nil ? String(tweet.retweets!) : nil
        
        if let user = tweet.user {
            cell.userName.text = user.userName
            cell.alias.text = "@" + user.alias!

            if let imageUrl = user.imageUrl {
                if let image = avatarImagesDictionary[imageUrl] {
                    cell.avatar.image = image
                }
                else {
                    cell.avatar.image = UIImage(named: "avatar")
                    
                    TwitterNetworkController.controller.downloadImage(imageURLString: imageUrl) { (image) -> Void in
                        if let image = image {
                            self.avatarImagesDictionary[imageUrl] = image
                            
                            if let cell = self.tweetsTable.cellForRowAtIndexPath(indexPath) as? TweetCell {
                                cell.avatar.image = image
                            }
                        }
                    }
                }
            }
            else {
                cell.avatar.image = UIImage(named: "avatar")
            }
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
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return tableView.dequeueReusableHeaderFooterViewWithIdentifier("TEST") as? UIView
//    }
    
    
    // MARK: Private Methods

}
