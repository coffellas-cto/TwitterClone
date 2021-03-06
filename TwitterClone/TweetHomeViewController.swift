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

enum TweetHomeViewControllerMode {
    case Home
    case User
}

class TweetHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Outlets
    @IBOutlet weak var tweetsTable: UITableView!
    
    // MARK: Properties
    var mode: TweetHomeViewControllerMode = .Home
    var curUser: User?
    var homeUser: User?
    var appDelegate: AppDelegate!
    var canLoadOlderTweets = false
        
    //paired
    var refreshControl: UIRefreshControl! = UIRefreshControl()
    
    // MARK: Private properties
    private var tweetsArray = [Tweet]()
    private var headerView: UserHeaderView!
    private var singleTweetVC: SingleTweetViewController?

    // MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userInfoTapped:", name: "userInfoTapped", object: nil)
        
        // Setup UI stuff
        tweetsTable.backgroundColor = UIColor.clearColor()
        tweetsTable.estimatedRowHeight = 200
        tweetsTable.rowHeight = UITableViewAutomaticDimension
        
        // paired
        var tableViewController = UITableViewController()
        tableViewController.tableView = tweetsTable
        if refreshControl != nil {
            refreshControl.addTarget(self, action: "refreshed", forControlEvents: UIControlEvents.ValueChanged)
            tableViewController.refreshControl = refreshControl
        }
        
        tweetsTable.registerNib(UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
                
        if let headerView = NSBundle.mainBundle().loadNibNamed("UserHeader", owner: self, options: nil).first as? UserHeaderView {
            self.headerView = headerView
            headerView.frame = CGRectMake(0, 0, tweetsTable.frame.width, 96)
            tweetsTable.tableHeaderView?.addSubview(headerView)
            headerView.userName.text = nil
            headerView.userAlias.text = nil
            headerView.avatar.image = UIImage(named: "avatar_big")
            
            headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showSelfTimeline:"))
        }
        
        // Network calls
        refreshControl.beginRefreshing()
        
        TwitterNetworkController.controller.setup { (errorString) -> Void in
            if errorString != nil {
                self.showError(errorString!)
                return
            }
            
            if (self.mode == .User) && (self.curUser == nil) {
                TwitterNetworkController.controller.fetchSelf { (errorString, userData) -> Void in
                    self.processUserData(errorString: errorString, userData: userData)
                    TwitterNetworkController.controller.fetchUserTimeline(self.curUser?.id, sinceID: "0", maxID: "0") { (errorString: String?, tweetsData: NSData?) -> Void in
                        self.processTimelineData(errorString: errorString, tweetsData: tweetsData)
                    }
                }
                return
            }
            
            TwitterNetworkController.controller.fetchUserTimeline(self.mode == .Home ? nil : self.curUser?.id, sinceID: "0", maxID: "0") { (errorString: String?, tweetsData: NSData?) -> Void in
                self.processTimelineData(errorString: errorString, tweetsData: tweetsData)
            }
            
            // Fill user view
            if (self.curUser == nil) {
                TwitterNetworkController.controller.fetchSelf { (errorString, userData) -> Void in
                    self.processUserData(errorString: errorString, userData: userData)
                }
            }
            else if let userName = self.curUser!.userName {
                self.showUserInfo(nil)
                self.title = userName + "'s tweets"
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
    
    // MARK: Methods
    func refreshed() {
        if tweetsArray.count > 0 {
            let tweet = tweetsArray[0]
            if let tweetID = tweet.id {
                TwitterNetworkController.controller.fetchUserTimeline(self.mode == .Home ? nil : self.curUser?.id, sinceID: tweetID, maxID: "0") { (errorString, tweetsData) -> Void in
                    self.processTimelineData(errorString: errorString, tweetsData: tweetsData)
                }
            }
        }
        //println("REFRESHED")
    }
    
    func userInfoTapped(notification: NSNotification) {
        if refreshControl.refreshing {
            return
        }
        
        if let tweetCell = notification.object as? TweetCell {
            if let indexPath = tweetsTable.indexPathForCell(tweetCell) {
                if tweetsArray.count > indexPath.row {
                    let tweet = tweetsArray[indexPath.row] as Tweet
                    if let selectedUser = tweet.user {
                        if let curUser = curUser {
                            if selectedUser.id == curUser.id {
                                return
                            }
                        }
                        
                        showSelectedUser(selectedUser)
                    }
                }
            }
        }
    }
    
    func showSelfTimeline(sender: UIGestureRecognizer) {
        if refreshControl.refreshing {
            return
        }
        
        if homeUser != nil {
            showSelectedUser(homeUser!)
        }
    }
    
    // MARK: Private Methods
    private func showSelectedUser(selectedUser: User) {
        if let timeLineViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("HOME_TIMELINE_VC") as? TweetHomeViewController {
            timeLineViewController.mode = .User
            timeLineViewController.curUser = selectedUser
            self.navigationController?.pushViewController(timeLineViewController, animated: true)
        }
    }
    
    private func showError(errorString: NSString) {
        println(errorString)
        UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    private func processTimelineData(#errorString: String?, tweetsData: NSData?, append: Bool = false) {
        refreshControl.endRefreshing()
        
        if let errorString = errorString {
            self.showError(errorString)
            return
        }
        
        if let tweetsData = tweetsData {
            if var tweets = Tweet.parseJSONDataIntoTweets(tweetsData) {
                if append {
                    self.tweetsArray += tweets
                }
                else {
                    self.tweetsArray = tweets + self.tweetsArray
                }
            
                //println("tweets.count: \(tweets.count)")
                self.tweetsTable.reloadData()
                canLoadOlderTweets = !(append && tweets.isEmpty)
            }
        }
    }
    
    private func processUserData(#errorString: String?, userData: NSData?) {
        if let errorString = errorString {
            self.showError(errorString)
            return
        }
        
        showUserInfo(User(jsonData: userData!))
    }
    
    private func showUserInfo(var user: User?) {
        if user == nil {
            user = curUser
        }
        else if mode == .Home {
            homeUser = user
        }
        else if mode == .User {
            curUser = user
        }
        
        if let user = user {
            if let headerView = headerView {
                headerView.userName.text = user.userName
                headerView.userAlias.text = "@" + user.alias!
                if let backgroundColor = user.backgroundColor {
                    headerView.backgroundColor = backgroundColor
                    headerView.avatar.layer.borderColor = backgroundColor.colorWithAlphaComponent(0.5).CGColor
                }
                
                if var imageUrl = user.imageUrl {
                    imageUrl = imageUrl.stringByReplacingOccurrencesOfString("_normal", withString: "", options: nil, range: nil)
                    self.headerView.activityIndicator.stopAnimating()
                    if let image = appDelegate.cachedImageForUrl(imageUrl) {
                        self.headerView.avatar.image = UIImage(data: image)
                    } else {
                        TwitterNetworkController.controller.downloadImage(imageURLString: imageUrl) { (image) -> Void in
                            if let image = image {
                                self.appDelegate.saveCachedImageForUrl(imageUrl, data: image)
                                self.headerView.avatar.image = UIImage(data: image)
                            }
                        }
                    }
                }
            }
        }
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
                if let image = appDelegate.cachedImageForUrl(imageUrl) {
                    cell.avatar.image = UIImage(data: image)
                }
                else {
                    cell.avatar.image = UIImage(named: "avatar")
                    
                    TwitterNetworkController.controller.downloadImage(imageURLString: imageUrl) { (image) -> Void in
                        if let image = image {
                            self.appDelegate.saveCachedImageForUrl(imageUrl, data: image)
                            
                            if let cell = self.tweetsTable.cellForRowAtIndexPath(indexPath) as? TweetCell {
                                cell.avatar.image = UIImage(data: image)
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
        
        if refreshControl.refreshing {
            return
        }
        
        if singleTweetVC == nil {
            singleTweetVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SINGLE_TWEET_VC") as? SingleTweetViewController
        }
        
        
        if indexPath.row < tweetsArray.count {
            singleTweetVC!.tweet = tweetsArray[indexPath.row]
            self.navigationController?.pushViewController(singleTweetVC!, animated: true)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentYOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        let bottom = scrollView.contentInset.bottom
        if (contentHeight - contentYOffset + bottom <= height) && canLoadOlderTweets {
            canLoadOlderTweets = false
            let lastTweet = tweetsArray.last
            if let lastID = lastTweet?.id {
                TwitterNetworkController.controller.fetchUserTimeline(self.mode == .Home ? nil : self.curUser?.id, sinceID: "0", maxID: lastID) { (errorString: String?, tweetsData: NSData?) -> Void in
                    self.processTimelineData(errorString: errorString, tweetsData: tweetsData, append: true)
                }
            }
            //println("REFRESHING TIME")
        }
    }
}
