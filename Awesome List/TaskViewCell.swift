//
//  TaskViewCell.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/22/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class TaskViewCell: UITableViewCell {
    @IBOutlet weak var task_title: UILabel!
    @IBOutlet weak var task_desc: UILabel!
    @IBOutlet weak var task_photo: UIImageView!
    @IBOutlet weak var task_private: UIImageView!
    @IBOutlet weak var icon_public: UIImageView!
    @IBOutlet weak var btn_public: UIButton!
    @IBOutlet weak var btn_done: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
