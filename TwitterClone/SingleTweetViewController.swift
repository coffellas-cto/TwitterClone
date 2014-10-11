//
//  SingleTweetViewController.swift
//  TwitterClone
//
//  Created by Alex G on 08.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit

class SingleTweetViewController: UIViewController {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var backgroundLineView: UIView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var favouriteCount: UILabel!
    @IBOutlet weak var retweets: UILabel!
    
    var tweet: Tweet?
    var appDelegate: AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 40
        avatarImage.layer.borderWidth = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.avatarImage.image = UIImage(named: "avatar_big")
        
        if let tweet = tweet {
            if let text = tweet.text {
                self.text.attributedText = NSAttributedString(string: text)
            }
            else {
                self.text.attributedText = nil
            }
            
            favouriteCount.text = tweet.favouriteCount != nil ? String(tweet.favouriteCount!) : nil
            retweets.text = tweet.retweets != nil ? String(tweet.retweets!) : nil
            
            time.text = tweet.dateString()
            
            if let user = tweet.user {
                self.title = (user.userName)! + " says:"
                if var imageUrl = user.imageUrl {
                    imageUrl = imageUrl.stringByReplacingOccurrencesOfString("_normal", withString: "", options: nil, range: nil)
                    
                    if let image = appDelegate.avatarImagesDictionary[imageUrl] {
                        avatarImage.image = image
                    } else {
                        TwitterNetworkController.controller.downloadImage(imageURLString: imageUrl, completion: { (image) -> Void in
                            self.appDelegate.avatarImagesDictionary[imageUrl] = image
                            self.avatarImage.image = image
                        })
                    }
                }
                
                if let backgroundColor = user.backgroundColor {
                    backgroundLineView.backgroundColor = backgroundColor
                    avatarImage.layer.borderColor = backgroundColor.colorWithAlphaComponent(0.5).CGColor
                }
                else {
                    backgroundLineView.backgroundColor = UIColor(white: 0, alpha: 0.1)
                    avatarImage.layer.borderColor = UIColor(white: 0, alpha: 0.2).CGColor
                }
            }
        }
        else {
            self.title = nil
            text.text = nil
            time.text = nil
            favouriteCount.text = nil
            retweets.text = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

}
