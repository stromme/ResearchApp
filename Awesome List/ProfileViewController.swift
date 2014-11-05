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
        if(strcmp("update_user", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e",
                //"username": "solidrock",
                "firstname": "Rock"//,
                //"lastname": "Solid",
                //"email": "solid.rock@mailinator.com",
                //"password": "test",
                //"company": "Solid Rock, Ltd.",
                //"location": "Jakarta"
            ]
            Alamofire.manager.request(.PUT, API.url("account"), parameters: params)
                .responseSwiftyJSON {
                    (request, response, json, error) in
                    println("---raw---")
                    println(json)
                    println("---error---")
                    println(error)
                    println("---status---")
                    println(json["status"])
                    println("---message---")
                    println(json["message"])
                    
                    if(json.arrayValue?.count>0){
                        var alertView = UIAlertView()
                        alertView.title = "Profile"
                        alertView.message = "Profile updated!"
                        alertView.addButtonWithTitle("Okay")
                        alertView.show()
                        
                        /*let users = json["result"]["users"]
                        
                        // Make it array
                        let users_arr: Array<JSON> = json["result"]["users"].arrayValue!
                        println("---count---")
                        println(users_arr.count)
                        println("---each one---")
                        for (index, user) in enumerate(users_arr) {
                        println("\(index+1) ----")
                        println(user)
                        }*/
                    }
                    if(error != nil){
                        var alertView = UIAlertView()
                        alertView.title = "Profile"
                        alertView.message = "Failed to update user profile"
                        alertView.addButtonWithTitle("Okay")
                        alertView.show()
                    }
            }
        }
        
        
        // TODO: Confirm deactivate
        if(strcmp("deactivate", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e"
            ]
            Alamofire.manager.request(.DELETE, API.url("account"), parameters: params)
                .responseSwiftyJSON {
                    (request, response, json, error) in
                    
                    // TODO: Logout/remove key from db
                    
                    println("---raw---")
                    println(json)
                    println("---error---")
                    println(error)
                    println("---status---")
                    println(json["status"])
                    println("---message---")
                    println(json["message"])
            }
        }
    }
    
}
