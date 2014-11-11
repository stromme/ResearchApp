//
//  RegisterViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RegisterViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var reg_username: UITextField!
    @IBOutlet weak var reg_firstname: UITextField!
    @IBOutlet weak var reg_lastname: UITextField!
    @IBOutlet weak var reg_email: UITextField!
    @IBOutlet weak var reg_password: UITextField!
    @IBOutlet weak var reg_confirm: UITextField!
    @IBOutlet weak var reg_company: UITextField!
    @IBOutlet weak var reg_location: UITextField!
    @IBOutlet var registerTableView: UITableView!
    let appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        reg_username.delegate = self
        reg_firstname.delegate = self
        reg_firstname.delegate = self
        reg_lastname.delegate = self
        reg_email.delegate = self
        reg_password.delegate = self
        reg_confirm.delegate = self
        reg_company.delegate = self
        reg_location.delegate = self
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        registerTableView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickDoneRegister(sender: AnyObject) {
        reg_username.resignFirstResponder()
        reg_firstname.resignFirstResponder()
        reg_firstname.resignFirstResponder()
        reg_lastname.resignFirstResponder()
        reg_email.resignFirstResponder()
        reg_password.resignFirstResponder()
        reg_confirm.resignFirstResponder()
        reg_company.resignFirstResponder()
        reg_location.resignFirstResponder()

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
            let indicator = CustomIndicator(view: self.view)
            indicator.animate({
                let params = [
                    "username": self.reg_username.text,
                    "firstname": self.reg_firstname.text,
                    "lastname": self.reg_lastname.text,
                    "email": self.reg_email.text,
                    "password": self.reg_password.text,
                    "company": self.reg_company.text,
                    "location": self.reg_location.text
                ]
                Alamofire.manager.request(.POST, API.url("account"), parameters: params)
                .responseSwiftyJSON {
                    (request, response, json, error) in
                    
                    if(json.boolValue){
                        if(json["status"].integerValue==1){
                            // Ref manage object context
                            let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                            
                            var user:Users = SwiftCoreDataHelper.insertManagedObject("Users", managedObjectConect: moc) as Users
                            
                            user.id = json["id"].stringValue!
                            user.username = self.reg_username.text
                            user.firstname = self.reg_firstname.text
                            user.lastname = self.reg_lastname.text
                            user.email = self.reg_email.text
                            user.location = self.reg_location.text
                            let defaultPhoto = UIImage(named: "default-portrait")
                            user.photo = UIImageJPEGRepresentation(defaultPhoto, 100)
                            let defaultBg = UIImage(named: "login-bg-blur-iphone5")
                            user.background = UIImageJPEGRepresentation(defaultBg, 100)
                            SwiftCoreDataHelper.saveManagedObjectContext(moc)

                            indicator.stop({
                                alertView.message = "Sucessfully registered! You may now login."
                                alertView.show()

                                self.performSegueWithIdentifier("backToLogin", sender: self)
                            })
                        } else {
                            indicator.stop({
                                alertView.message = json["message"].stringValue
                                alertView.show()
                            })
                        }
                    } else {
                        indicator.stop({
                            println(error)
                            alertView.message = error?.description
                            alertView.show()
                        })
                    }
                }
            }, label: "Submitting")
        }
    }
    
    // Hide keyboard on press return
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.clickDoneRegister(textField)
        return true;
    }
    
    func hideKeyboard(recognizer: UITapGestureRecognizer){
        reg_username.resignFirstResponder()
        reg_firstname.resignFirstResponder()
        reg_firstname.resignFirstResponder()
        reg_lastname.resignFirstResponder()
        reg_email.resignFirstResponder()
        reg_password.resignFirstResponder()
        reg_confirm.resignFirstResponder()
        reg_company.resignFirstResponder()
        reg_location.resignFirstResponder()
    }
}
