//
//  LoginController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/15/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var hatchLogo: UIImageView!
    @IBOutlet weak var inputUsername: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    var appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
    var userKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputUsername.delegate = self
        inputPassword.delegate = self

        // Do any additional setup after loading the view, typically from a nib.
        self.hatchLogo.layer.cornerRadius = 8;
        self.hatchLogo.clipsToBounds = true;
        self.hatchLogo.layer.borderWidth = 2.0;
        self.hatchLogo.layer.borderColor = UIColor.whiteColor().CGColor;
        
        let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Settings")
        let resultPredicate1: NSPredicate = NSPredicate(format: "varname = %@", "username")!
        let resultPredicate2: NSPredicate = NSPredicate(format: "varname = %@", "key")!
        var sorter: NSSortDescriptor = NSSortDescriptor(key: "varname" , ascending: true)
        
        let results:NSArray = SwiftCoreDataHelper.fetchEntities("Settings", withPredicate: [resultPredicate1, resultPredicate2], compound: .OR, withSorter: sorter, managedObjectContext: moc)
 
        if(results.count>0){
            var alertView = UIAlertView()
            alertView.title = "Logging in..."
            alertView.addButtonWithTitle("Okay")

            var cred = [String: String]()
            
            for setting in results {
                let singleSetting = setting as Settings
                cred[singleSetting.varname] = singleSetting.value
            }
            
            if(cred["key"] != ""){
                let params = [
                    "key": String(cred["key"]!)
                ]

                let indicator = CustomIndicator(view: self.view)
                indicator.animate()

                Alamofire.manager.request(.POST, API.url("auth"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
                    if(json.boolValue){
                        if(json["status"].integerValue==1){
                            self.appDelegate.username = String(cred["username"]!)
                            self.appDelegate.key = String(cred["key"]!)

                            // TODO: Update tasks
                            // TODO: Update stats
                            // TODO: Update friendship
                            // TODO: Update dashboard

                            self.performSegueWithIdentifier("pushToHomeViewController", sender: self)
                        }
                        else {
                            alertView.message = json["message"].stringValue
                            alertView.show()
                        }
                    } else {
                        println(error)
                        alertView.message = "error?.description"
                        alertView.show()
                    }
                    indicator.stop()
                }
            }
        }
        else {
            // Do nothing, will ask to login
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToSegue(segue: UIStoryboardSegue){}
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue){}

    @IBAction func doLogin(sender: AnyObject) {
        let indicator = CustomIndicator(view: self.view)
        indicator.animate()

        let params = [
            "username": inputUsername.text,
            "password": inputPassword.text
        ]
        Alamofire.manager.request(.POST, API.url("auth"), parameters: params)
            .responseSwiftyJSON {
                (request, response, json, error) in
                var alertView = UIAlertView()
                alertView.title = "Login"
                alertView.addButtonWithTitle("Okay")

                if(json.boolValue){
                    if(json["status"].integerValue==1){
                        let indicator = CustomIndicator(view: self.view)
                        indicator.animate()

                        self.userKey = json["key"].stringValue!
                        self.appDelegate.username = self.inputUsername.text
                        self.appDelegate.key = self.userKey
                        
                        let params = [
                            "key": String(self.userKey!)
                        ]
                        Alamofire.manager.request(.GET, API.url("account"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
                            if(json.boolValue){
                                if(json["status"].integerValue==1){
                                    let userdata = json["result"]["user"]
                                    
                                    println("get local user")
                                    // Delete existing user details
                                    let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                    let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", userdata["username"].stringValue!)!

                                    let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: moc)

                                    var photoData: NSData = NSData()
                                    var timelinePhotoData: NSData = NSData()
                                    
                                    
                                    println(results)
                                    
                                    if(results.count>0){
                                        
                                        println("dld photo")
                                        println(userdata["photo"].stringValue)

                                        // Download profile photo and background photo, insert as well
                                        if(userdata["photo"].stringValue != nil && userdata["photo"].stringValue != ""){
                                            let imageURL = NSURL(string: userdata["photo"].stringValue!)
                                            let imageData = NSData(contentsOfURL: imageURL!)
                                            if(imageData != nil){
                                                let image = UIImage(data: imageData!)
                                                photoData = UIImageJPEGRepresentation(image, 100)
                                            }
                                        }
                                        
                                        println("dld bg")
                                        println(userdata["timeline_photo"].stringValue)
                                        
                                        if(userdata["timeline_photo"].stringValue != nil && userdata["timeline_photo"].stringValue != ""){
                                            let imageURL = NSURL(string: userdata["timeline_photo"].stringValue!)
                                            let imageData = NSData(contentsOfURL: imageURL!)
                                            if(imageData != nil){
                                                let image = UIImage(data: imageData!)
                                                timelinePhotoData = UIImageJPEGRepresentation(image, 100)
                                            }
                                        }

                                        // Delete old data
                                        for user in results {
                                            var userItem = user as Users
                                            moc.deleteObject(userItem)
                                        }
                                        SwiftCoreDataHelper.saveManagedObjectContext(moc)
                                    }
                                    
                                    println("try to insert")
                                    
                                    // Insert latest user data
                                    var user:Users = SwiftCoreDataHelper.insertManagedObject("Users", managedObjectConect: moc)
                                        as Users
                                    user.id = userdata["id"].stringValue!
                                    user.username = userdata["username"].stringValue!
                                    user.firstname = userdata["firstname"].stringValue!
                                    user.lastname = userdata["lastname"].stringValue!
                                    user.email = userdata["email"].stringValue!
                                    user.password = userdata["password"].stringValue!
                                    user.company = userdata["company"].stringValue!
                                    user.location = userdata["location"].stringValue!
                                    user.photo = photoData
                                    user.background = timelinePhotoData
                                    SwiftCoreDataHelper.saveManagedObjectContext(moc)
                                    
                                    // TODO: Clean Friendship database
                                    // TODO: Insert Friends (fresh)

                                    /*
                                    Alamofire.manager.request(.GET, API.url("tasks"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
                                        if(json.boolValue){
                                            if(json["status"].integerValue==1){
                                                let fetchedTasks:Array<JSON> = json["result"]["tasks"].arrayValue!
                                                for (index, singleTask) in enumerate(fetchedTasks) {
                                                    // TODO: Process tasks
                                                    println("--- \(index) ---")
                                                    println(singleTask["title"].stringValue)
                                                    println(singleTask["description"].stringValue)
                                                    println(singleTask)
                                                }
                                            } else {
                                                alertView.message = json["message"].stringValue
                                                alertView.show()
                                            }
                                        } else {
                                            println(error)
                                            alertView.message = error?.description
                                            alertView.show()
                                        }
                                    }*/
                                    
                                    self.performSegueWithIdentifier("pushToHomeViewController", sender: self)
                                } else {
                                    alertView.message = json["message"].stringValue
                                    alertView.show()
                                }
                            } else {
                                println(error)
                                alertView.message = error?.description
                                alertView.show()
                            }
                            indicator.stop()
                        }

                        // TODO: Fetch friendship
                        // TODO: Fetch stats
                        // TODO: Fetch dashboard
                        
                        // TODO: Set name, photo, background, stats via delegate
                        
                        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                        var insertItems = [
                            "username": self.inputUsername.text,
                            "key": self.userKey
                        ]
                        for (itemKey, itemValue) in insertItems {
                            var settings:Settings = SwiftCoreDataHelper.insertManagedObject("Settings", managedObjectConect: moc)
                                as Settings
                            settings.varname = itemKey
                            settings.value = itemValue
                        }
                        SwiftCoreDataHelper.saveManagedObjectContext(moc)
                    } else {
                        alertView.message = json["message"].stringValue
                        alertView.show()
                    }
                } else {
                    println(error)
                    alertView.message = error?.description
                    alertView.show()
                }
                indicator.stop()
        }
        


        if(strcmp("get_single_task", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e"
            ]
            let task_id = 1
            Alamofire.manager.request(.GET, API.url("tasks/\(task_id)"), parameters: params)
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
            }
        }

        if(strcmp("get_all_users_for_friendship", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e"
            ]
            Alamofire.manager.request(.GET, API.url("users"), parameters: params)
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
            }
        }

        if(strcmp("add_friend", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e"
            ]
            let friend_with = "josua"
            Alamofire.manager.request(.POST, API.url("tasks/\(friend_with)"), parameters: params)
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
            }
        }

        if(strcmp("unfriend", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e"
            ]
            let friend_with = "josua"
            Alamofire.manager.request(.DELETE, API.url("tasks/\(friend_with)"), parameters: params)
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
            }
        }
        
        if(strcmp("old_way", "")<0){
        /*let req = APIHelper(method: "GET", endpoint: "users")
        let request = req.getRequest()
        request.completionHandler = { response, data, error in
            if error != nil {
                // If there is an error in the web request, print it to the console
                println(error)
            }
            else {
                var err: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                if err != nil {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                else {
                    let json_result = JSON(object: jsonResult)
                    println(json_result["status"])
                    println(json_result["message"])
                    let users = json_result["result"]["users"]
                    
                    // Make it array
                    let users_arr: Array<JSON> = json_result["result"]["users"].arrayValue!
                    println(users_arr.count)
                    for (index, user) in enumerate(users_arr) {
                        println("\(index+1) ----")
                        println(user)
                    }
                    
                    /*
                    let length = json_result["result"]["length"].integerValue
                    println(length)
                    // Use as it is (JSON type)
                    for index in 0...length!-1 {
                        println("\(index) --------")
                        println(users[index])
                    }*/
                }
            }
        }
        request.loadRequest()*/
        }
    }
    
    // Hide keyboard on press return
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        inputUsername.resignFirstResponder()
        inputPassword.resignFirstResponder()
        self.doLogin(textField)
        return true;
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        inputUsername.resignFirstResponder()
        inputPassword.resignFirstResponder()
        self.view.endEditing(true)
    }
}
