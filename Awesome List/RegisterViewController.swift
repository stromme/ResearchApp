//
//  RegisterViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UITableViewController {
    @IBOutlet weak var reg_username: UITextField!
    @IBOutlet weak var reg_firstname: UITextField!
    @IBOutlet weak var reg_lastname: UITextField!
    @IBOutlet weak var reg_email: UITextField!
    @IBOutlet weak var reg_password: UITextField!
    @IBOutlet weak var reg_confirm: UITextField!

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
        alertView.addButtonWithTitle("Okay")
        var notif = ""
        
        if(self.reg_username.text.utf16Count<3){
            notif = "Username length at least more than 3"
        }
        else if self.reg_username.text =~ "[\\ ]+" {
            notif = "Username cannot contain spaces"
        }
        else if(self.reg_firstname.text == ""){
            notif = "Please insert First Name"
        }
        else if(self.reg_lastname.text == ""){
            notif = "Please insert Last Name"
        }
        else if !isValidEmail(self.reg_email.text) {
            notif = "Invalid Email address"
        }
        else if(self.reg_password.text == ""){
            notif = "Please insert Password"
        }
        else if(self.reg_confirm.text == ""){
            notif = "Please confirm Password"
        }
        else if(self.reg_password.text != self.reg_confirm.text){
            notif = "Password not match"
        }
        
        if(notif != "") {
            alertView.message = notif
            alertView.show()
        }
        else {
            // Ref to app Delegate
            let appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate

            // Ref manage object context
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            let entityDesc = NSEntityDescription.entityForName("Members", inManagedObjectContext: context)
            
            
            alertView.message = "Sucessfully registered!"
            alertView.show()
            self.performSegueWithIdentifier("backToLogin", sender: self)
        }
    }
}
