//
//  UserListTableViewCell.swift
//  ForgetMeNot
//
//  Created by Seth on 7/27/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    func configure(with user: User) {
        nameLabel.text = user.name
        locationLabel.text = user.log.locationName
    }
}
