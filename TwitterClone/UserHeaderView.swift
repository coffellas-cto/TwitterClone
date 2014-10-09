//
//  UserHeaderView.swift
//  TwitterClone
//
//  Created by Alex G on 09.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit

class UserHeaderView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAlias: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatar.layer.masksToBounds = true
        avatar.layer.cornerRadius = 40
        avatar.layer.borderWidth = 1
    }
}
