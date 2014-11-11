//
//  HomeViewCell.swift
//  Awesome List
//
//  Created by Josua Sihombing on 11/11/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class HomeViewCell: UITableViewCell {
    @IBOutlet weak var task_photo: UIImageView!
    @IBOutlet weak var task_title: UILabel!
    @IBOutlet weak var task_desc: UILabel!
    @IBOutlet weak var task_owner: UILabel!
    var loaded: Bool = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
