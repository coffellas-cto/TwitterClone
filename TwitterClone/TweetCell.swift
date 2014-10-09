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
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(white: 0, alpha: 0.07)
        self.selectedBackgroundView = bgColorView
        
        if self.respondsToSelector("setLayoutMargins:") {
            self.layoutMargins = UIEdgeInsetsZero
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
