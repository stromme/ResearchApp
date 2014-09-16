//
//  RegisterViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class RegisterViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickDoneRegister(sender: AnyObject) {
        var alertView = UIAlertView()
        alertView.title = "Register"
        alertView.message = "Sucessfully registered!"
        alertView.addButtonWithTitle("Okay")
        alertView.show()
        self.performSegueWithIdentifier("backToLogin", sender: self)
        
    }
}
