//
//  ProfileViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    @IBOutlet weak var profileImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickSaveProfile(sender: AnyObject) {
        var alertView = UIAlertView()
        alertView.title = "Profile"
        alertView.message = "Profile updated!"
        alertView.addButtonWithTitle("Okay")
        alertView.show()
    }
    
}
