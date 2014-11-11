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
    var id: String?
    var progressDone: Int = 0
    var totalProgress: Int = 0

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
                indicator.animate({
                    self.progressDone = 0
                    
                    Alamofire.manager.request(.POST, API.url("auth"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
                        if(json.boolValue){
                            if(json["status"].integerValue==1){
                                self.appDelegate.username = String(cred["username"]!)
                                self.appDelegate.key = String(cred["key"]!)
                                self.appDelegate.id = json["result"]["user_id"].stringValue

                                indicator.setLabel(label: "Updating data")

                                self.initLogin(indicator)
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
                }, label: "Authenticating existing user")
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
        inputUsername.resignFirstResponder()
        inputPassword.resignFirstResponder()

        let indicator = CustomIndicator(view: self.view)
        indicator.animate({
            let params = [
                "username": self.inputUsername.text,
                "password": self.inputPassword.text
            ]
            Alamofire.manager.request(.POST, API.url("auth"), parameters: params)
                .responseSwiftyJSON {
                    (request, response, json, error) in
                    var alertView = UIAlertView()
                    alertView.title = "Login"
                    alertView.addButtonWithTitle("Okay")
                    self.totalProgress = 0

                    if(json.boolValue){
                        if(json["status"].integerValue==1){
                            //var dateFormatter = NSDateFormatter()
                            //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            //dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

                            indicator.setLabel(label: "Updating data")

                            self.userKey = json["key"].stringValue!
                            self.appDelegate.username = self.inputUsername.text
                            self.appDelegate.key = self.userKey
                            
                            var insertItems = [
                                "username": self.inputUsername.text,
                                "key": self.userKey
                            ]
                            let keySettingsMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                            for (itemKey, itemValue) in insertItems {
                                var settings:Settings = SwiftCoreDataHelper.insertManagedObject("Settings", managedObjectConect: keySettingsMoc)
                                    as Settings
                                settings.varname = itemKey
                                settings.value = itemValue
                            }
                            SwiftCoreDataHelper.saveManagedObjectContext(keySettingsMoc)
                            
                            self.initLogin(indicator)
                            
                            /*self.progressDone = 0
                            
                            var insertItems = [
                                "username": self.inputUsername.text,
                                "key": self.userKey
                            ]
                            let keySettingsMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                            for (itemKey, itemValue) in insertItems {
                                var settings:Settings = SwiftCoreDataHelper.insertManagedObject("Settings", managedObjectConect: keySettingsMoc)
                                    as Settings
                                settings.varname = itemKey
                                settings.value = itemValue
                            }
                            SwiftCoreDataHelper.saveManagedObjectContext(keySettingsMoc)
                            
                            let params = [
                                "key": String(self.userKey!)
                            ]
                            self.totalProgress += 1
                            Alamofire.manager.request(.GET, API.url("account"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
                                if(json.boolValue){
                                    if(json["status"].integerValue==1){
                                        let userdata = json["result"]["user"]

                                        self.id = userdata["id"].stringValue!
                                        self.appDelegate.id = self.id

                                        let settingsMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                        let settingResults:NSArray = SwiftCoreDataHelper.fetchEntities("Settings", withPredicate: nil, withSorter: nil, managedObjectContext: settingsMoc)

                                        if(settingResults.count>0){
                                            for setting in settingResults {
                                                let singleSetting = setting as Settings
                                                if(
                                                    singleSetting.value == "id" ||
                                                        singleSetting.value == "friends"
                                                    ){
                                                        settingsMoc.deleteObject(singleSetting)
                                                }
                                            }
                                        }
                                        SwiftCoreDataHelper.saveManagedObjectContext(settingsMoc)

                                        var insertItems = [
                                            "id": self.id,
                                            "friends": json["result"]["length"].stringValue!
                                        ]
                                        for (itemKey, itemValue) in insertItems {
                                            var settings:Settings = SwiftCoreDataHelper.insertManagedObject("Settings", managedObjectConect: settingsMoc)
                                                as Settings
                                            settings.varname = itemKey
                                            settings.value = itemValue!
                                        }
                                        SwiftCoreDataHelper.saveManagedObjectContext(settingsMoc)
                                        
                                        // Delete existing user details
                                        let accountUserMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                        let delUserResultPredicate: NSPredicate = NSPredicate(format: "username = %@", userdata["username"].stringValue!)!
                                        let delUserResults = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: delUserResultPredicate, withSorter: nil, managedObjectContext: accountUserMoc)

                                        //var photoData: NSData = NSData()
                                        //var timelinePhotoData: NSData = NSData()

                                        if(delUserResults.count>0){
                                            // Download profile photo and background photo, insert as well
                                            // This may take longer if image not found
                                            /*if(userdata["photo"].stringValue != nil && userdata["photo"].stringValue != ""){
                                                let imageURL: String? = userdata["photo"].stringValue!
                                                if(imageURL != nil && imageURL != ""){
                                                    let imageData = NSData(contentsOfURL: NSURL(string: API.updateHost(imageURL!))!)
                                                    if(imageData != nil){
                                                        let image = UIImage(data: imageData!)
                                                        photoData = UIImageJPEGRepresentation(image, 100)
                                                    }
                                                }
                                            }
                                            if(userdata["timeline_photo"].stringValue != nil && userdata["timeline_photo"].stringValue != ""){
                                                let imageURL: String? = userdata["timeline_photo"].stringValue!
                                                if(imageURL != nil && imageURL != ""){
                                                    let imageData = NSData(contentsOfURL: NSURL(string: API.updateHost(imageURL!))!)
                                                    if(imageData != nil){
                                                        let image = UIImage(data: imageData!)
                                                        timelinePhotoData = UIImageJPEGRepresentation(image, 100)
                                                    }
                                                }
                                            }*/
                                            // Delete old data
                                            for delUser in delUserResults {
                                                var delUserItem = delUser as Users
                                                accountUserMoc.deleteObject(delUserItem)
                                            }
                                            SwiftCoreDataHelper.saveManagedObjectContext(accountUserMoc)
                                        }

                                        // Insert latest user data
                                        var user:Users = SwiftCoreDataHelper.insertManagedObject("Users", managedObjectConect: accountUserMoc)
                                            as Users
                                        user.id = userdata["id"].stringValue!
                                        user.username = userdata["username"].stringValue!
                                        user.firstname = userdata["firstname"].stringValue!
                                        user.lastname = userdata["lastname"].stringValue!
                                        user.email = userdata["email"].stringValue!
                                        user.company = userdata["company"].stringValue!
                                        user.location = userdata["location"].stringValue!
                                        user.photo = NSData()//photoData
                                        user.photo_url = userdata["photo"].stringValue!
                                        user.background = NSData()//timelinePhotoData
                                        user.background_url = userdata["timeline_photo"].stringValue!
                                        SwiftCoreDataHelper.saveManagedObjectContext(accountUserMoc)
                                        
                                        // Delete existing friendship for the user
                                        let resultPredicate: NSPredicate = NSPredicate(format: "my_id = %@", userdata["id"].stringValue!)!
                                        let sorter:NSSortDescriptor? = NSSortDescriptor(key: "id" , ascending: false)
                                        var friendshipResults = SwiftCoreDataHelper.fetchEntities("Friendship", withPredicate: resultPredicate, withSorter: sorter, managedObjectContext: accountUserMoc)
                                        if(friendshipResults.count>0){
                                            for friendshipResult in friendshipResults {
                                                var friendshipItem = friendshipResult as Friendship
                                                accountUserMoc.deleteObject(friendshipItem);
                                            }
                                            SwiftCoreDataHelper.saveManagedObjectContext(accountUserMoc)
                                        }

                                        // Insert new friendship data
                                        let myFriendship:Array<JSON> = json["result"]["friends"].arrayValue!

                                        if(json["result"]["length"].integerValue>0){
                                            for(index, singleFFriend) in enumerate(myFriendship) {
                                                var friend:Friendship = SwiftCoreDataHelper.insertManagedObject("Friendship", managedObjectConect: accountUserMoc) as Friendship
                                                let fId = singleFFriend["id"].stringValue!
                                                friend.id = "\(fId)_\(self.appDelegate.id)"
                                                friend.my_id = self.appDelegate.id!
                                                friend.my_username = self.appDelegate.username!
                                                friend.friend_id = singleFFriend["friend_id"].stringValue!
                                                friend.friend_username = singleFFriend["username"].stringValue!
                                            }
                                            SwiftCoreDataHelper.saveManagedObjectContext(accountUserMoc)
                                        }
                                        
                                        self.progressDone += 1
                                        println("\(self.progressDone)>=\(self.totalProgress)")
                                        if(self.progressDone>=self.totalProgress){
                                            indicator.stop({
                                                self.performSegueWithIdentifier("pushToHomeViewController", sender: self)
                                            })
                                        }
                                    } else {
                                        indicator.stop({
                                            let customNotif = CustomNotification(view: self.view, label: json["message"].stringValue!)
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

                            self.totalProgress += 1
                            Alamofire.manager.request(.GET, API.url("stats"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
                                if(json.boolValue){
                                    if(json["status"].integerValue==1){
                                        let statsMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                        
                                        let settingResults:NSArray = SwiftCoreDataHelper.fetchEntities("Settings", withPredicate: nil, withSorter: nil, managedObjectContext: statsMoc)
                                        
                                        if(settingResults.count>0){
                                            for setting in settingResults {
                                                let singleSetting = setting as Settings
                                                if(
                                                    singleSetting.value == "total_tasks" ||
                                                        singleSetting.value == "week_tasks" ||
                                                        singleSetting.value == "week_done" ||
                                                        singleSetting.value == "month_tasks" ||
                                                        singleSetting.value == "month_done"
                                                    ){
                                                        statsMoc.deleteObject(singleSetting)
                                                }
                                            }
                                            SwiftCoreDataHelper.saveManagedObjectContext(statsMoc)
                                        }
                                        
                                        let stats = json["result"]["stats"]
                                        var insertItems = [
                                            "total_tasks": (stats["total_tasks"].stringValue != nil) ? stats["total_tasks"].stringValue : "0",
                                            "week_tasks": (stats["week_tasks"].stringValue != nil) ? stats["week_tasks"].stringValue : "0",
                                            "week_done": (stats["week_done"].stringValue != nil) ? stats["week_done"].stringValue : "0",
                                            "month_tasks": (stats["month_tasks"].stringValue != nil) ? stats["month_tasks"].stringValue : "0",
                                            "month_done": (stats["month_done"].stringValue != nil) ? stats["month_done"].stringValue : "0"
                                        ]
                                        for (itemKey, itemValue) in insertItems {
                                            var settings:Settings = SwiftCoreDataHelper.insertManagedObject("Settings", managedObjectConect: statsMoc)
                                                as Settings
                                            settings.varname = itemKey
                                            settings.value = itemValue!
                                        }
                                        SwiftCoreDataHelper.saveManagedObjectContext(statsMoc)
                                    } else {
                                        alertView.message = json["message"].stringValue
                                        alertView.show()
                                    }
                                } else {
                                    println(error)
                                    alertView.message = error?.description
                                    alertView.show()
                                }
                                
                                self.progressDone += 1
                                println("\(self.progressDone)>=\(self.totalProgress)")
                                if(self.progressDone>=self.totalProgress){
                                    indicator.stop({
                                        self.performSegueWithIdentifier("pushToHomeViewController", sender: self)
                                    })
                                }
                            }

                            self.totalProgress += 1
                            Alamofire.manager.request(.GET, API.url("tasks"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
                                if(json.boolValue){
                                    if(json["status"].integerValue==1){
                                        var fetchedTasks:Array<JSON> = json["result"]["tasks"].arrayValue!

                                        var tasksMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                        let tasksPredicate:NSPredicate? = NSPredicate(format:"user_id='\(self.appDelegate.id!)'")
                                        let tasksSorter:NSSortDescriptor? = NSSortDescriptor(key: "due" , ascending: false)
                                        var tasksResults:NSArray = SwiftCoreDataHelper.fetchEntities("Tasks", withPredicate: tasksPredicate, withSorter: tasksSorter, managedObjectContext: tasksMoc)

                                        if(json["result"]["length"].integerValue>0){
                                            if(tasksResults.count>0){
                                                for taskResult in tasksResults {
                                                    let singleTask:Tasks = taskResult as Tasks
                                                    var recordExist: Bool = false
                                                    for (index, singleFTask) in enumerate(fetchedTasks) {
                                                        if(singleFTask["id"].stringValue==singleTask.id){
                                                            recordExist = true
                                                            let modDateStr = dateFormatter.stringFromDate(singleTask.modified)
                                                            if(singleFTask["modified"].stringValue! != modDateStr){
                                                                singleTask.title = singleFTask["title"].stringValue!
                                                                singleTask.desc = singleFTask["desc"].stringValue!
                                                                singleTask.is_public = singleFTask["public"].integerValue!
                                                                singleTask.is_done = singleFTask["done"].integerValue!
                                                                singleTask.due = dateFormatter.dateFromString(singleFTask["due"].stringValue!)!
                                                                singleTask.modified = dateFormatter.dateFromString(singleFTask["modified"].stringValue!)!
                                                                var photoData = NSData()
                                                                if(singleFTask["photo"].stringValue != nil && singleFTask["photo"].stringValue != ""){
                                                                    let imageURL: String? = singleFTask["photo"].stringValue!
                                                                    if(imageURL != nil && imageURL != ""){
                                                                        let imageData = NSData(contentsOfURL: NSURL(string: API.updateHost(imageURL!))!)
                                                                        if(imageData != nil){
                                                                            let image = UIImage(data: imageData!)
                                                                            photoData = UIImageJPEGRepresentation(image, 100)
                                                                        }
                                                                    }
                                                                }
                                                                singleTask.photo = NSData()
                                                                singleTask.photo_url = singleFTask["photo"].stringValue!
                                                                SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                                            } else {
                                                                // Skip (no update)
                                                            }
                                                            // Remove from array after use
                                                            fetchedTasks.removeAtIndex(index)
                                                            break
                                                        }
                                                    }
                                                    // Not in fetched, means it must have been removed
                                                    if(!recordExist){
                                                        tasksMoc.deleteObject(singleTask)
                                                        SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                                    }
                                                }
                                            }

                                            // Insert new data for remaining tasks
                                            if(fetchedTasks.count>0){
                                                for (index, singleFTask) in enumerate(fetchedTasks) {
                                                    var newTask:Tasks = SwiftCoreDataHelper.insertManagedObject("Tasks", managedObjectConect: tasksMoc)
                                                        as Tasks
                                                    newTask.id = singleFTask["id"].stringValue!
                                                    newTask.user_id = singleFTask["user_id"].stringValue!
                                                    newTask.title = singleFTask["title"].stringValue!
                                                    newTask.desc = singleFTask["desc"].stringValue!
                                                    newTask.is_public = singleFTask["public"].integerValue!
                                                    newTask.is_done = singleFTask["done"].integerValue!
                                                    newTask.due = dateFormatter.dateFromString(singleFTask["due"].stringValue!)!
                                                    newTask.modified = dateFormatter.dateFromString(singleFTask["modified"].stringValue!)!
                                                    newTask.location = singleFTask["location"].stringValue!

                                                    /*photoData = NSData()
                                                    if(singleFTask["photo"].stringValue != nil && singleFTask["photo"].stringValue != ""){
                                                        let imageURL: String? = singleFTask["photo"].stringValue!
                                                        if(imageURL != nil && imageURL != ""){
                                                            let imageData = NSData(contentsOfURL: NSURL(string: API.updateHost(imageURL!))!)
                                                            if(imageData != nil){
                                                                let image = UIImage(data: imageData!)
                                                                photoData = UIImageJPEGRepresentation(image, 100)
                                                            }
                                                        }
                                                    }*/
                                                    newTask.photo = NSData()
                                                    newTask.photo_url = singleFTask["photo"].stringValue!
                                                }
                                                SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                            }
                                        }

                                        Alamofire.manager.request(.GET, API.url("dashboard"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
                                            if(json.boolValue){
                                                if(json["status"].integerValue==1){
                                                    var fetchedDashboardTasks:Array<JSON> = json["result"]["tasks"].arrayValue!
                                                    var tasksMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                                    let tasksPredicate:NSPredicate? = NSPredicate(format:"user_id!='\(self.appDelegate.id!)'")
                                                    let tasksSorter:NSSortDescriptor? = NSSortDescriptor(key: "due" , ascending: false)
                                                    var tasksFResults:NSArray = SwiftCoreDataHelper.fetchEntities("Tasks", withPredicate: tasksPredicate, withSorter: tasksSorter, managedObjectContext: tasksMoc)
                                                    
                                                    if(json["result"]["length"].integerValue>0){
                                                        if(tasksFResults.count>0){
                                                            for taskResult in tasksFResults {
                                                                let singleDTask:Tasks = taskResult as Tasks
                                                                var recordExist: Bool = false
                                                                for (fIndex, singleFTask) in enumerate(fetchedDashboardTasks) {
                                                                    if(singleFTask["id"].stringValue==singleDTask.id){
                                                                        recordExist = true
                                                                        let modDateStr = dateFormatter.stringFromDate(singleDTask.modified)
                                                                        if(singleFTask["modified"].stringValue! != modDateStr){
                                                                            singleDTask.title = singleFTask["title"].stringValue!
                                                                            singleDTask.desc = singleFTask["desc"].stringValue!
                                                                            singleDTask.is_public = singleFTask["public"].integerValue!
                                                                            singleDTask.is_done = singleFTask["done"].integerValue!
                                                                            singleDTask.due = dateFormatter.dateFromString(singleFTask["due"].stringValue!)!
                                                                            singleDTask.modified = dateFormatter.dateFromString(singleFTask["modified"].stringValue!)!
                                                                            singleDTask.photo = NSData()
                                                                            singleDTask.photo_url = singleFTask["photo"].stringValue!
                                                                            SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                                                        } else {
                                                                            // Skip (no update)
                                                                        }
                                                                        // Remove from array after use
                                                                        fetchedDashboardTasks.removeAtIndex(fIndex)
                                                                        break
                                                                    }
                                                                }
                                                                // Not in fetched, means it must have been removed
                                                                if(!recordExist){
                                                                    tasksMoc.deleteObject(singleDTask)
                                                                    SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                                                }
                                                            }
                                                        }

                                                        // Insert new data for remaining tasks
                                                        if(fetchedDashboardTasks.count>0){
                                                            for (index, singleFTask) in enumerate(fetchedDashboardTasks) {
                                                                var newTask:Tasks = SwiftCoreDataHelper.insertManagedObject("Tasks", managedObjectConect: tasksMoc)
                                                                    as Tasks
                                                                newTask.id = singleFTask["id"].stringValue!
                                                                newTask.user_id = singleFTask["user_id"].stringValue!
                                                                newTask.title = singleFTask["title"].stringValue!
                                                                newTask.desc = singleFTask["desc"].stringValue!
                                                                newTask.is_public = singleFTask["public"].integerValue!
                                                                newTask.is_done = singleFTask["done"].integerValue!
                                                                newTask.due = dateFormatter.dateFromString(singleFTask["due"].stringValue!)!
                                                                newTask.modified = dateFormatter.dateFromString(singleFTask["modified"].stringValue!)!
                                                                newTask.location = singleFTask["location"].stringValue!
                                                                newTask.photo = NSData()
                                                                newTask.photo_url = singleFTask["photo"].stringValue!
                                                            }
                                                            SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                                        }
                                                    }
                                                    self.progressDone += 1
                                                    println("\(self.progressDone)>=\(self.totalProgress)")
                                                    if(self.progressDone>=self.totalProgress){
                                                        indicator.stop({
                                                            self.performSegueWithIdentifier("pushToHomeViewController", sender: self)
                                                        })
                                                    }
                                                } else {
                                                    indicator.stop({
                                                        alertView.message = json["message"].stringValue
                                                        alertView.show()
                                                    })
                                                }
                                            } else {
                                                indicator.stop({
                                                    alertView.message = error?.description
                                                    alertView.show()
                                                })
                                            }
                                        }
                                    } else {
                                        indicator.stop({
                                            alertView.message = json["message"].stringValue
                                            alertView.show()
                                        })
                                    }
                                } else {
                                    indicator.stop({
                                        alertView.message = error?.description
                                        alertView.show()
                                    })
                                }
                            }*/
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
        }, label: "Authenticating user")
    }

    // Hide keyboard on press return
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.doLogin(textField)
        return true;
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        inputUsername.resignFirstResponder()
        inputPassword.resignFirstResponder()
        self.view.endEditing(true)
    }

    func initLogin(indicator: CustomIndicator){
        var alertView = UIAlertView()
        alertView.title = "Login"
        alertView.addButtonWithTitle("Okay")
        self.totalProgress = 0

        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        indicator.setLabel(label: "Updating data")

        self.progressDone = 0
        
        let params = [
            "key": String(self.appDelegate.key!)
        ]
        self.totalProgress += 1
        Alamofire.manager.request(.GET, API.url("account"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
            if(json.boolValue){
                if(json["status"].integerValue==1){
                    let userdata = json["result"]["user"]
                    
                    self.id = userdata["id"].stringValue!
                    self.appDelegate.id = self.id
                    
                    let settingsMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                    let settingResults:NSArray = SwiftCoreDataHelper.fetchEntities("Settings", withPredicate: nil, withSorter: nil, managedObjectContext: settingsMoc)
                    
                    if(settingResults.count>0){
                        for setting in settingResults {
                            let singleSetting = setting as Settings
                            if(
                                singleSetting.value == "id" ||
                                    singleSetting.value == "friends"
                                ){
                                    settingsMoc.deleteObject(singleSetting)
                            }
                        }
                    }
                    SwiftCoreDataHelper.saveManagedObjectContext(settingsMoc)
                    
                    var insertItems = [
                        "id": self.id,
                        "friends": json["result"]["length"].stringValue!
                    ]
                    for (itemKey, itemValue) in insertItems {
                        var settings:Settings = SwiftCoreDataHelper.insertManagedObject("Settings", managedObjectConect: settingsMoc)
                            as Settings
                        settings.varname = itemKey
                        settings.value = itemValue!
                    }
                    SwiftCoreDataHelper.saveManagedObjectContext(settingsMoc)
                    
                    // Delete existing user details
                    let accountUserMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                    let delUserResultPredicate: NSPredicate = NSPredicate(format: "username = %@", userdata["username"].stringValue!)!
                    let delUserResults = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: delUserResultPredicate, withSorter: nil, managedObjectContext: accountUserMoc)

                    if(delUserResults.count>0){
                        // Delete old data
                        for delUser in delUserResults {
                            var delUserItem = delUser as Users
                            accountUserMoc.deleteObject(delUserItem)
                        }
                        SwiftCoreDataHelper.saveManagedObjectContext(accountUserMoc)
                    }
                    
                    // Insert latest user data
                    var user:Users = SwiftCoreDataHelper.insertManagedObject("Users", managedObjectConect: accountUserMoc)
                        as Users
                    user.id = userdata["id"].stringValue!
                    user.username = userdata["username"].stringValue!
                    user.firstname = userdata["firstname"].stringValue!
                    user.lastname = userdata["lastname"].stringValue!
                    user.email = userdata["email"].stringValue!
                    user.company = userdata["company"].stringValue!
                    user.location = userdata["location"].stringValue!
                    user.photo = NSData()//photoData
                    user.photo_url = userdata["photo"].stringValue!
                    user.background = NSData()//timelinePhotoData
                    user.background_url = userdata["timeline_photo"].stringValue!
                    SwiftCoreDataHelper.saveManagedObjectContext(accountUserMoc)
                    
                    // Delete existing friendship for the user
                    let resultPredicate: NSPredicate = NSPredicate(format: "my_id = %@", userdata["id"].stringValue!)!
                    let sorter:NSSortDescriptor? = NSSortDescriptor(key: "id" , ascending: false)
                    var friendshipResults = SwiftCoreDataHelper.fetchEntities("Friendship", withPredicate: resultPredicate, withSorter: sorter, managedObjectContext: accountUserMoc)
                    if(friendshipResults.count>0){
                        for friendshipResult in friendshipResults {
                            var friendshipItem = friendshipResult as Friendship
                            accountUserMoc.deleteObject(friendshipItem);
                        }
                        SwiftCoreDataHelper.saveManagedObjectContext(accountUserMoc)
                    }
                    
                    // Insert new friendship data
                    let myFriendship:Array<JSON> = json["result"]["friends"].arrayValue!
                    
                    if(json["result"]["length"].integerValue>0){
                        for(index, singleFFriend) in enumerate(myFriendship) {
                            var friend:Friendship = SwiftCoreDataHelper.insertManagedObject("Friendship", managedObjectConect: accountUserMoc) as Friendship
                            let fId = singleFFriend["id"].stringValue!
                            friend.id = "\(fId)_\(self.appDelegate.id)"
                            friend.my_id = self.appDelegate.id!
                            friend.my_username = self.appDelegate.username!
                            friend.friend_id = singleFFriend["friend_id"].stringValue!
                            friend.friend_username = singleFFriend["username"].stringValue!
                        }
                        SwiftCoreDataHelper.saveManagedObjectContext(accountUserMoc)
                    }
                    
                    self.progressDone += 1
                    indicator.setLabel(label: "Updating data \(self.progressDone) of \(self.totalProgress)")
                    if(self.progressDone>=self.totalProgress){
                        indicator.setLabel(label: "Updating data \(self.progressDone) of \(self.totalProgress)")
                        indicator.stop({
                            self.performSegueWithIdentifier("pushToHomeViewController", sender: self)
                        })
                    }
                } else {
                    indicator.stop({
                        let customNotif = CustomNotification(view: self.view, label: json["message"].stringValue!)
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
        
        self.totalProgress += 1
        Alamofire.manager.request(.GET, API.url("stats"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
            if(json.boolValue){
                if(json["status"].integerValue==1){
                    let statsMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                    
                    let settingResults:NSArray = SwiftCoreDataHelper.fetchEntities("Settings", withPredicate: nil, withSorter: nil, managedObjectContext: statsMoc)
                    
                    if(settingResults.count>0){
                        for setting in settingResults {
                            let singleSetting = setting as Settings
                            if(
                                singleSetting.value == "total_tasks" ||
                                    singleSetting.value == "week_tasks" ||
                                    singleSetting.value == "week_done" ||
                                    singleSetting.value == "month_tasks" ||
                                    singleSetting.value == "month_done"
                                ){
                                    statsMoc.deleteObject(singleSetting)
                            }
                        }
                        SwiftCoreDataHelper.saveManagedObjectContext(statsMoc)
                    }
                    
                    let stats = json["result"]["stats"]
                    var insertItems = [
                        "total_tasks": (stats["total_tasks"].stringValue != nil) ? stats["total_tasks"].stringValue : "0",
                        "week_tasks": (stats["week_tasks"].stringValue != nil) ? stats["week_tasks"].stringValue : "0",
                        "week_done": (stats["week_done"].stringValue != nil) ? stats["week_done"].stringValue : "0",
                        "month_tasks": (stats["month_tasks"].stringValue != nil) ? stats["month_tasks"].stringValue : "0",
                        "month_done": (stats["month_done"].stringValue != nil) ? stats["month_done"].stringValue : "0"
                    ]
                    for (itemKey, itemValue) in insertItems {
                        var settings:Settings = SwiftCoreDataHelper.insertManagedObject("Settings", managedObjectConect: statsMoc)
                            as Settings
                        settings.varname = itemKey
                        settings.value = itemValue!
                    }
                    SwiftCoreDataHelper.saveManagedObjectContext(statsMoc)
                } else {
                    alertView.message = json["message"].stringValue
                    alertView.show()
                }
            } else {
                println(error)
                alertView.message = error?.description
                alertView.show()
            }
            
            self.progressDone += 1
            indicator.setLabel(label: "Updating data \(self.progressDone) of \(self.totalProgress)")
            if(self.progressDone>=self.totalProgress){
                indicator.setLabel(label: "Updating data \(self.progressDone) of \(self.totalProgress)")
                indicator.stop({
                    self.performSegueWithIdentifier("pushToHomeViewController", sender: self)
                })
            }
        }
        
        self.totalProgress += 1
        Alamofire.manager.request(.GET, API.url("tasks"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
            if(json.boolValue){
                if(json["status"].integerValue==1){
                    var fetchedTasks:Array<JSON> = json["result"]["tasks"].arrayValue!
                    
                    var tasksMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                    let tasksPredicate:NSPredicate? = NSPredicate(format:"user_id='\(self.appDelegate.id!)'")
                    let tasksSorter:NSSortDescriptor? = NSSortDescriptor(key: "id" , ascending: false)
                    var tasksResults:NSArray = SwiftCoreDataHelper.fetchEntities("Tasks", withPredicate: tasksPredicate, withSorter: tasksSorter, managedObjectContext: tasksMoc)

                    if(json["result"]["length"].integerValue>0){
                        if(tasksResults.count>0){
                            for taskResult in tasksResults {
                                let singleTask:Tasks = taskResult as Tasks
                                var recordExist: Bool = false
                                for (index, singleFTask) in enumerate(fetchedTasks) {
                                    if(singleFTask["id"].stringValue==singleTask.id){
                                        recordExist = true

                                        var modDateStr = ""
                                        if(singleTask.valueForKey("modified") != nil){
                                            modDateStr = dateFormatter.stringFromDate(singleTask.modified)
                                        }
                                        if(singleFTask["modified"].stringValue! != modDateStr){
                                            singleTask.title = singleFTask["title"].stringValue!
                                            singleTask.desc = singleFTask["desc"].stringValue!
                                            singleTask.is_public = singleFTask["public"].integerValue!
                                            singleTask.is_done = singleFTask["done"].integerValue!
                                            singleTask.due = dateFormatter.dateFromString(singleFTask["due"].stringValue!)!
                                            singleTask.modified = dateFormatter.dateFromString(singleFTask["modified"].stringValue!)!
                                            var photoData = NSData()
                                            if(singleFTask["photo"].stringValue != nil && singleFTask["photo"].stringValue != ""){
                                                let imageURL: String? = singleFTask["photo"].stringValue!
                                                if(imageURL != nil && imageURL != ""){
                                                    let imageData = NSData(contentsOfURL: NSURL(string: API.updateHost(imageURL!))!)
                                                    if(imageData != nil){
                                                        let image = UIImage(data: imageData!)
                                                        photoData = UIImageJPEGRepresentation(image, 100)
                                                    }
                                                }
                                            }
                                            singleTask.photo = NSData()
                                            singleTask.photo_url = singleFTask["photo"].stringValue!
                                            SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                        } else {
                                            // Skip (no update)
                                        }
                                        // Remove from array after use
                                        fetchedTasks.removeAtIndex(index)
                                        break
                                    }
                                }
                                // Not in fetched, means it must have been removed
                                if(!recordExist){
                                    tasksMoc.deleteObject(singleTask)
                                    SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                }
                            }
                        }

                        // Insert new data for remaining tasks
                        if(fetchedTasks.count>0){
                            for (index, singleFTask) in enumerate(fetchedTasks) {
                                var newTask:Tasks = SwiftCoreDataHelper.insertManagedObject("Tasks", managedObjectConect: tasksMoc)
                                    as Tasks
                                newTask.id = singleFTask["id"].stringValue!
                                newTask.user_id = singleFTask["user_id"].stringValue!
                                newTask.title = singleFTask["title"].stringValue!
                                newTask.desc = singleFTask["desc"].stringValue!
                                newTask.is_public = singleFTask["public"].integerValue!
                                newTask.is_done = singleFTask["done"].integerValue!
                                newTask.due = dateFormatter.dateFromString(singleFTask["due"].stringValue!)!
                                newTask.modified = dateFormatter.dateFromString(singleFTask["modified"].stringValue!)!
                                newTask.location = singleFTask["location"].stringValue!
                                newTask.photo = NSData()
                                newTask.photo_url = singleFTask["photo"].stringValue!
                            }
                            SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                        }
                    }
                    
                    Alamofire.manager.request(.GET, API.url("dashboard"), parameters: params).responseSwiftyJSON { (request, response, json, error) in
                        if(json.boolValue){
                            if(json["status"].integerValue==1){
                                var fetchedDashboardTasks:Array<JSON> = json["result"]["tasks"].arrayValue!
                                var tasksMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                let tasksPredicate:NSPredicate? = NSPredicate(format:"user_id!='\(self.appDelegate.id!)'")
                                let tasksSorter:NSSortDescriptor? = NSSortDescriptor(key: "due" , ascending: false)
                                var tasksFResults:NSArray = SwiftCoreDataHelper.fetchEntities("Tasks", withPredicate: tasksPredicate, withSorter: tasksSorter, managedObjectContext: tasksMoc)
                                
                                if(json["result"]["length"].integerValue>0){
                                    if(tasksFResults.count>0){
                                        for taskResult in tasksFResults {
                                            let singleDTask:Tasks = taskResult as Tasks
                                            var recordExist: Bool = false
                                            for (fIndex, singleFTask) in enumerate(fetchedDashboardTasks) {
                                                if(singleFTask["id"].stringValue==singleDTask.id){
                                                    recordExist = true
                                                    let modDateStr = dateFormatter.stringFromDate(singleDTask.modified)
                                                    if(singleFTask["modified"].stringValue! != modDateStr){
                                                        singleDTask.title = singleFTask["title"].stringValue!
                                                        singleDTask.desc = singleFTask["desc"].stringValue!
                                                        singleDTask.is_public = singleFTask["public"].integerValue!
                                                        singleDTask.is_done = singleFTask["done"].integerValue!
                                                        singleDTask.due = dateFormatter.dateFromString(singleFTask["due"].stringValue!)!
                                                        singleDTask.modified = dateFormatter.dateFromString(singleFTask["modified"].stringValue!)!
                                                        singleDTask.photo = NSData()
                                                        singleDTask.photo_url = singleFTask["photo"].stringValue!
                                                        SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                                    } else {
                                                        // Skip (no update)
                                                    }
                                                    // Remove from array after use
                                                    fetchedDashboardTasks.removeAtIndex(fIndex)
                                                    break
                                                }
                                            }
                                            // Not in fetched, means it must have been removed
                                            if(!recordExist){
                                                tasksMoc.deleteObject(singleDTask)
                                                SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                            }
                                        }
                                    }
                                    
                                    // Insert new data for remaining tasks
                                    if(fetchedDashboardTasks.count>0){
                                        for (index, singleFTask) in enumerate(fetchedDashboardTasks) {
                                            var newTask:Tasks = SwiftCoreDataHelper.insertManagedObject("Tasks", managedObjectConect: tasksMoc)
                                                as Tasks
                                            newTask.id = singleFTask["id"].stringValue!
                                            newTask.user_id = singleFTask["user_id"].stringValue!
                                            newTask.title = singleFTask["title"].stringValue!
                                            newTask.desc = singleFTask["desc"].stringValue!
                                            newTask.is_public = singleFTask["public"].integerValue!
                                            newTask.is_done = singleFTask["done"].integerValue!
                                            newTask.due = dateFormatter.dateFromString(singleFTask["due"].stringValue!)!
                                            newTask.modified = dateFormatter.dateFromString(singleFTask["modified"].stringValue!)!
                                            newTask.location = singleFTask["location"].stringValue!
                                            newTask.photo = NSData()
                                            newTask.photo_url = singleFTask["photo"].stringValue!
                                        }
                                        SwiftCoreDataHelper.saveManagedObjectContext(tasksMoc)
                                    }
                                }
                                self.progressDone += 1
                                indicator.setLabel(label: "Updating data \(self.progressDone) of \(self.totalProgress)")
                                if(self.progressDone>=self.totalProgress){
                                    indicator.setLabel(label: "Updating data \(self.progressDone) of \(self.totalProgress)")
                                    indicator.stop({
                                        self.performSegueWithIdentifier("pushToHomeViewController", sender: self)
                                    })
                                }
                            } else {
                                indicator.stop({
                                    alertView.message = json["message"].stringValue
                                    alertView.show()
                                })
                            }
                        } else {
                            indicator.stop({
                                alertView.message = error?.description
                                alertView.show()
                            })
                        }
                    }
                } else {
                    indicator.stop({
                        alertView.message = json["message"].stringValue
                        alertView.show()
                    })
                }
            } else {
                indicator.stop({
                    alertView.message = error?.description
                    alertView.show()
                })
            }
        }
    }
}
