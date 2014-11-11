//
//  FriendViewCell.swift
//  Awesome List
//
//  Created by Josua Sihombing on 11/10/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class FriendViewCell: UITableViewCell {
    @IBOutlet weak var friend_name: UILabel!
    @IBOutlet weak var friend_photo: UIImageView!
    @IBOutlet weak var friend_info: UILabel!
    @IBOutlet weak var btn_friendship: UIButton!
    @IBOutlet weak var friend_indicator_label: UILabel!
    @IBOutlet weak var data_username: UILabel!
    @IBOutlet weak var data_is_friend: UILabel!

    var loaded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
