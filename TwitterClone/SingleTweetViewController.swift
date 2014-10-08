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

    var tweet: Tweet?
    private var backgroundQueue: NSOperationQueue = NSOperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 40
        avatarImage.layer.borderWidth = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tweet = tweet {
            self.title = (tweet.userName)! + " says:"
            
            if let backgroundColor = tweet.backgroundColor {
                backgroundLineView.backgroundColor = backgroundColor
                avatarImage.layer.borderColor = backgroundColor.colorWithAlphaComponent(0.5).CGColor
                
            }
            else {
                backgroundLineView.backgroundColor = UIColor(white: 0, alpha: 0.1)
                avatarImage.layer.borderColor = UIColor(white: 0, alpha: 0.2).CGColor
            }
            
            backgroundQueue.cancelAllOperations()
            backgroundQueue.addOperationWithBlock({ () -> Void in
                
                if let imageUrl = tweet.imageUrl {
                    
                    let imageData = NSData(contentsOfURL:NSURL(string: imageUrl.stringByReplacingOccurrencesOfString("_normal", withString: "_bigger", options: nil, range: nil)))
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.avatarImage.image = UIImage(data: imageData)
                    })
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

}
