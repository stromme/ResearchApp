//
//  SettingsController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickSaveSetting(sender: AnyObject) {
        var alertView = UIAlertView()
        alertView.title = "Setting"
        alertView.message = "Setting saved!"
        alertView.addButtonWithTitle("Okay")
        alertView.show()
    }
}
