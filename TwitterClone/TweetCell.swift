//
//  TweetCell.swift
//  TwitterClone
//
//  Created by Alex G on 07.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var alias: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var favouriteCount: UILabel!
    @IBOutlet weak var retweets: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avatar.layer.masksToBounds = true;
        avatar.layer.cornerRadius = 20;
        
        self.backgroundColor = UIColor.clearColor()
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(white: 0, alpha: 0.07)
        self.selectedBackgroundView = bgColorView
        
        self.layoutMargins = UIEdgeInsetsZero
        
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapFired:"))
        userName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapFired:"))
        alias.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapFired:"))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tapFired(sender: UIGestureRecognizer) {
        NSNotificationCenter.defaultCenter().postNotificationName("userInfoTapped", object: self)
    }

}
