//
//  FriendshipViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 11/10/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FriendshipViewController: UITableViewController {
    var myFriends:NSMutableArray = NSMutableArray()
    var appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
    var usersUpdated: Bool = false
    var loadImage = 0
    var loadedImage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        loadData()
    }

    func loadData(){
        self.myFriends.removeAllObjects()
        let indicator = CustomIndicator(view: self.view)
        var alertView = UIAlertView()
        alertView.title = "Friends"
        alertView.addButtonWithTitle("Okay")

        if(!usersUpdated){
            let params = [
                "key": self.appDelegate.key!
            ]
            indicator.animate({
                let params = ["id": String(self.appDelegate.id!)]
                Alamofire.manager.request(.GET, API.url("users"), parameters: params) .responseSwiftyJSON { (request, response, json, error) in
                    if(json.boolValue){
                        if(json["status"].integerValue==1){
                            let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                            
                            let predicate:NSPredicate = NSPredicate(format:"id != %@", self.appDelegate.id!)!
                            let sorter:NSSortDescriptor? = NSSortDescriptor(key: "username" , ascending: false)
                            let usersResults:NSArray = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: predicate, withSorter: sorter, managedObjectContext: moc)

                            var downloadImage = 0
                            if(json["result"]["length"].integerValue>0){
                                var fetchedUsers:Array<JSON> = json["result"]["users"].arrayValue!
                                for userResult in usersResults {
                                    let singleUser:Users = userResult as Users
                                    var userExist = false
                                    for (fIdx, fUser) in enumerate(fetchedUsers) {
                                        if(singleUser.id == fUser["id"].stringValue!){
                                            userExist = true

                                            singleUser.firstname = fUser["firstname"].stringValue!
                                            singleUser.lastname = fUser["lastname"].stringValue!
                                            singleUser.email = fUser["email"].stringValue!
                                            singleUser.company = fUser["company"].stringValue!
                                            singleUser.location = fUser["location"].stringValue!
                                            singleUser.photo_url = fUser["photo"].stringValue!
                                            singleUser.photo = NSData()
                                            singleUser.background_url = fUser["timeline_photo"].stringValue!
                                            singleUser.background = NSData()
                                            SwiftCoreDataHelper.saveManagedObjectContext(moc)
                                            
                                            fetchedUsers.removeAtIndex(fIdx)

                                            break
                                        } else {
                                            // No update
                                        }
                                    }
                                    if(!userExist){
                                        moc.deleteObject(singleUser)
                                        SwiftCoreDataHelper.saveManagedObjectContext(moc)
                                    }
                                }

                                if(fetchedUsers.count>0){
                                    for (index, singleFUser) in enumerate(fetchedUsers) {
                                        var newUser:Users = SwiftCoreDataHelper.insertManagedObject("Users", managedObjectConect: moc)
                                            as Users
                                        newUser.id = singleFUser["id"].stringValue!
                                        newUser.username = singleFUser["username"].stringValue!
                                        newUser.firstname = singleFUser["firstname"].stringValue!
                                        newUser.lastname = singleFUser["lastname"].stringValue!
                                        newUser.email = singleFUser["email"].stringValue!
                                        newUser.company = singleFUser["company"].stringValue!
                                        newUser.location = singleFUser["location"].stringValue!
                                        newUser.photo = NSData()
                                        newUser.photo_url = singleFUser["photo"].stringValue!
                                        newUser.background = NSData()
                                        newUser.background_url = singleFUser["timeline_photo"].stringValue!
                                    }
                                    SwiftCoreDataHelper.saveManagedObjectContext(moc)
                                }

                                let usersResults:NSArray = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: predicate, withSorter: sorter, managedObjectContext: moc)

                                if(usersResults.count>0){
                                    self.loadImage = 0
                                    self.loadedImage = 0
                                    var no_photoload = true
                                    for userResult in usersResults {
                                        let getSingleUser:Users = userResult as Users

                                        let userId = getSingleUser.id
                                        let photoURL = getSingleUser.valueForKey("photo_url") as String
                                        
                                        if(photoURL != ""){
                                            no_photoload = false
                                            self.loadImage += 1
                                            indicator.setLabel(label: "Downloading user photos \(self.loadedImage) of \(self.loadImage)")
                                            Alamofire.manager.request(.GET, API.updateHost(getSingleUser.photo_url)).response { (request, response, data, error) in
                                                if(data != nil){
                                                    let userPhotoMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()

                                                    let userPhotoPredicate: NSPredicate = NSPredicate(format: "id = %@", userId)!
                                                    let userPhotoResults = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: userPhotoPredicate, withSorter: nil, managedObjectContext: userPhotoMoc)
                                                    for userPhotoResult in userPhotoResults {
                                                        var singleUserPhoto: Users = userPhotoResult as Users
                                                        singleUserPhoto.photo = data! as NSData
                                                    }
                                                    SwiftCoreDataHelper.saveManagedObjectContext(userPhotoMoc)
                                                }
                                                self.loadedImage += 1
                                                indicator.setLabel(label: "Downloading user photos \(self.loadedImage) of \(self.loadImage)")
                                                if(self.loadedImage==self.loadImage){
                                                    indicator.stop({
                                                        self.usersUpdated = true
                                                        self.loadTable()
                                                    })
                                                }
                                            }
                                        }
                                    }
                                    if(no_photoload){
                                        indicator.stop({
                                            self.usersUpdated = true
                                            self.loadTable()
                                        })
                                    }
                                } else {
                                    indicator.stop({
                                        self.usersUpdated = true
                                        self.loadTable()
                                    })
                                }
                            } else {
                                indicator.stop({
                                    self.loadTable()
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
            }, label: "Grabbing users")
        } else {
            self.loadTable()
        }
    }
    
    func loadTable(){
        let friendsMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        let friendPredicate:NSPredicate = NSPredicate(format:"my_id = %@", self.appDelegate.id!)!
        let friendsSorter:NSSortDescriptor? = NSSortDescriptor(key: "friend_username" , ascending: true)
        let friendsResults:NSArray = SwiftCoreDataHelper.fetchEntities("Friendship", withPredicate: friendPredicate, withSorter: friendsSorter, managedObjectContext: friendsMoc)
        
        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        let predicate:NSPredicate = NSPredicate(format:"id != %@", self.appDelegate.id!)!
        let sorter:NSSortDescriptor? = NSSortDescriptor(key: "username" , ascending: false)
        let usersResults:NSArray = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: predicate, withSorter: sorter, managedObjectContext: moc)
        for userResult in usersResults {
            let singleUser:Users = userResult as Users
            var is_friend = 0
            for (fIdx, friendResult) in enumerate(friendsResults) {
                let singleFriend:Friendship = friendResult as Friendship
                if(singleUser.id == singleFriend.friend_id){
                    is_friend = 1
                    break
                }
            }
            var photoData = NSData()
            if(singleUser.valueForKey("photo") != nil){
                photoData = singleUser.photo
            }
            var userDict:NSMutableDictionary = ["id":singleUser.id,"username":singleUser.username,"firstname":singleUser.firstname,"lastname":singleUser.lastname,"photo":photoData,"company":singleUser.company,"location":singleUser.location,"friend":is_friend]
            self.myFriends.addObject(userDict)
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFriends.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FriendViewCell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as FriendViewCell
        
        let friendDict:NSDictionary = myFriends.objectAtIndex(indexPath.row) as NSDictionary
        
        let username = friendDict.objectForKey("username") as String
        let firstname = friendDict.objectForKey("firstname") as String
        let lastname = friendDict.objectForKey("lastname") as String
        let company = friendDict.objectForKey("company") as String
        let location = friendDict.objectForKey("location") as String
        let imageData:NSData? = friendDict.objectForKey("photo") as? NSData
        let is_friend: Bool = (friendDict.objectForKey("friend") as Int == 1)

        cell.data_username.text = username

        if(!cell.loaded){
            if(imageData != nil && imageData?.length>0) {
                let photo = UIImage(data:imageData!)!
                let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: cell.friend_photo.frame.size)
                let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                cell.friend_photo.image = photoResized
                
            } else {
                cell.friend_photo.image = UIImage(named: "icon-photo")
            }
        }
        cell.friend_name.text = "\(firstname) \(lastname)"
        cell.friend_info.text = company
        if(location.utf16Count > 0){
            cell.friend_info.text = "\(company), \(location)"
        }
        
        // Overflow hidden
        cell.friend_photo.clipsToBounds = true;
        cell.friend_photo.layer.cornerRadius = cell.friend_photo.frame.size.width / 2;
        
        cell.btn_friendship.tag = indexPath.row

        if(is_friend){
            cell.btn_friendship.imageView?.image = UIImage(named: "icon-unfriend")
            cell.friend_indicator_label.text = "\(username) is your friend"
            cell.friend_indicator_label.textColor = CustomIndicator.UIColorFromHex(0x007ef6, alpha: 1)
            cell.data_is_friend.text = "1"
        } else {
            cell.btn_friendship.imageView?.image = UIImage(named: "icon-add-friend")
            cell.friend_indicator_label.text = "\(username) not your friend"
            cell.friend_indicator_label.textColor = CustomIndicator.UIColorFromHex(0xcccccc, alpha: 1)
            cell.data_is_friend.text = "0"
        }
        cell.btn_friendship.addTarget(self, action: "updateFriendship:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.loaded = true
        
        return cell
    }

    func updateFriendship(sender:UIButton){
        let button: UIButton = sender as UIButton;
        let friendDict:NSDictionary = self.myFriends.objectAtIndex(button.tag) as NSDictionary
        
        let username = friendDict.objectForKey("username") as String
        let is_friend: Bool = (friendDict.objectForKey("friend") as Int == 1)

        let miniIndi = MiniIndicator(view: self.tableView.superview!, targetView: self.view.superview!)
        
        if(!is_friend){
            miniIndi.animate({
                let params = [
                    "key": String(self.appDelegate.key!)
                ]
                Alamofire.manager.request(.POST, API.url("friendship/\(username)"), parameters: params) .responseSwiftyJSON { (request, response, json, error) in
                    miniIndi.stop({
                        if(json.boolValue){
                            if(json["status"].integerValue==1){
                                let friendsMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                var newFriendship:Friendship = SwiftCoreDataHelper.insertManagedObject("Friendship", managedObjectConect: friendsMoc)
                                    as Friendship
                                newFriendship.id = json["result"]["id"].stringValue!
                                newFriendship.my_id = self.appDelegate.id!
                                newFriendship.my_username = self.appDelegate.username!
                                newFriendship.friend_id = json["result"]["friend_id"].stringValue!
                                newFriendship.friend_username = json["result"]["username"].stringValue!
                                SwiftCoreDataHelper.saveManagedObjectContext(friendsMoc)
                                CustomNotification(view: self.view, label: "You are now friend with \(username)")
                                
                                self.loadData()
                            } else {
                                CustomNotification(view: self.view, label: json["message"].stringValue!)
                            }
                        } else {
                            CustomNotification(view: self.view, label: "Failed to connect")
                        }
                    })
                }
            })
        } else {
            miniIndi.animate({
                let params = [
                    "key": String(self.appDelegate.key!)
                ]
                Alamofire.manager.request(.DELETE, API.url("friendship/\(username)"), parameters: params) .responseSwiftyJSON { (request, response, json, error) in
                    miniIndi.stop({
                        if(json.boolValue){
                            if(json["status"].integerValue==1){
                                let friendsMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                let friendPredicate:NSPredicate = NSPredicate(format:"friend_username = %@", username)!
                                let friendsResults:NSArray = SwiftCoreDataHelper.fetchEntities("Friendship", withPredicate: friendPredicate, withSorter: nil, managedObjectContext: friendsMoc)
                                for friendResult in friendsResults {
                                    let singleFriendship:Friendship = friendResult as Friendship
                                        friendsMoc.deleteObject(singleFriendship)
                                }
                                SwiftCoreDataHelper.saveManagedObjectContext(friendsMoc)
                                CustomNotification(view: self.view, label: "You have been unfriend with \(username)")

                                self.loadData()
                            } else {
                                CustomNotification(view: self.view, label: json["message"].stringValue!)
                            }
                        } else {
                            CustomNotification(view: self.view, label: "Failed to connect")
                        }
                    })
                }
            })
        }
    }
}
