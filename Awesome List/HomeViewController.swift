//
//  FirstViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/15/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var backgroundPhoto: UIImageView!
    @IBOutlet weak var nameDarkenBG: UIView!
    
    var profile_original_photo: UIImage =  UIImage()
    var bg_original_photo: UIImage =  UIImage()
    var currentPhotoItem: String = "pp"
    var currentPhotoVar: UIImageView = UIImageView()
    let viewMoc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tapPPGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseProfilePhoto:")
        self.profilePhoto.addGestureRecognizer(tapPPGestureRecognizer)
        self.profilePhoto.userInteractionEnabled = true

        let tapBGGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseBackgroundPhoto:")
        self.backgroundPhoto.addGestureRecognizer(tapBGGestureRecognizer)
        self.backgroundPhoto.userInteractionEnabled = true
        let tapDarkenGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseBackgroundPhoto:")
        self.nameDarkenBG.addGestureRecognizer(tapDarkenGestureRecognizer)
        self.nameDarkenBG.userInteractionEnabled = true

        // Load user data from db
        let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
        let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: self.viewMoc)

        if(results.count>0){
            let singleUser = results[0] as Users

            let firstName = (String(singleUser.firstname) != nil) ? singleUser.firstname : ""
            let lastName = (String(singleUser.lastname) != nil) ? singleUser.lastname : ""
            self.fullName.text = "\(firstName) \(lastName)"

            // Get photos
            if(singleUser.valueForKey("photo") != nil){
                let photo = UIImage(data: singleUser.photo)!
                let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: self.profilePhoto.frame.size)
                let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                self.profilePhoto.image = photoResized
            }
            if(singleUser.valueForKey("background") != nil){
                let photo = UIImage(data: singleUser.background)!
                let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: self.backgroundPhoto.frame.size)
                let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                self.backgroundPhoto.image = photoResized
                self.backgroundPhoto.contentMode = UIViewContentMode.Center
            }
        }
        
        if(strcmp("friendship_stats", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e"
            ]
            Alamofire.manager.request(.GET, API.url("frienship"), parameters: params)
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
        
        if(strcmp("dashboard", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e"
            ]
            let friend_with = "josua"
            Alamofire.manager.request(.GET, API.url("dashboard"), parameters: params)
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
        
        if(strcmp("stats", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e"
            ]
            Alamofire.manager.request(.GET, API.url("stats"), parameters: params)
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
        
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.width / 2;
        self.profilePhoto.clipsToBounds = true;
        self.profilePhoto.layer.borderWidth = 3.0;
        self.profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func chooseProfilePhoto(recognizer: UITapGestureRecognizer){
        let actionSheet:UIActionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.title = "Profile Photo"
        
        actionSheet.addButtonWithTitle("Take a Photo")
        actionSheet.addButtonWithTitle("Camera Roll")
        actionSheet.addButtonWithTitle("Library")
        
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = 3
        actionSheet.showInView(self.view)
        
        self.currentPhotoItem = "pp"
        self.currentPhotoVar = self.profilePhoto
    }
    
    func chooseBackgroundPhoto(recognizer: UITapGestureRecognizer){
        let actionSheet:UIActionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.title = "Background Photo"
        
        actionSheet.addButtonWithTitle("Take a Photo")
        actionSheet.addButtonWithTitle("Camera Roll")
        actionSheet.addButtonWithTitle("Library")
        
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = 3
        actionSheet.showInView(self.view)
        
        self.currentPhotoItem = "bg"
        self.currentPhotoVar = self.backgroundPhoto
    }
    
    func actionSheet(sheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int){
        if(sheet.buttonTitleAtIndex(buttonIndex) == "Library"){
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else if(sheet.buttonTitleAtIndex(buttonIndex) == "Camera Roll"){
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else if(sheet.buttonTitleAtIndex(buttonIndex) == "Take a Photo"){
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary!) {
        picker.dismissViewControllerAnimated(true, completion: {
            let indicator = CustomIndicator(view: self.view)
            indicator.animate()

            let pickedImage:UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        
            // Aspect
            let pickedSize = pickedImage.size
            let aspect:CGFloat  = pickedSize.width / pickedSize.height

            let viewSize:CGRect = self.currentPhotoVar.frame
            var resizedSize = ImageHelper.aspectFill(pickedSize, frameSize: viewSize.size)
            
            // Resized photo
            let pic = ImageHelper.scaleImage(pickedImage, newSize: resizedSize)

            let params = [
                "key": String(self.appDelegate.key!)
            ]
            var alertView = UIAlertView()
            alertView.addButtonWithTitle("Okay")

            if(self.currentPhotoItem=="pp"){
                alertView.title = "Update Profile Photo"
                var imageData: NSData = UIImageJPEGRepresentation(pic, 1.0);
                let req = API(responseType: "string")
                req.request(.POST, endpoint: "profile_photo", parameters: params, media_upload: imageData, media_filename: "media.jpg", uploadProgress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        //println("percentage: \(totalBytesWritten/totalBytesExpectedToWrite*100)%")
                    }, downloadProgress: nil,
                    success: {
                        (json, string, response) in
                        if(json["status"].integerValue==1){
                            indicator.stop()
                            
                            // Modify and save
                            let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
                            let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: self.viewMoc)
                            if(results.count>0){
                                let singleUser = results[0] as Users
                                singleUser.photo = imageData
                                SwiftCoreDataHelper.saveManagedObjectContext(self.viewMoc)
                                self.profilePhoto.image = pic
                            } else {
                                alertView.message = "User data not exist on database, please re-login"
                                alertView.show()
                            }
                        } else {
                            alertView.message = json["message"].stringValue
                            alertView.show()
                        }
                        return
                    }, failure: { (error: NSError) in
                        println(error)
                        alertView.message = "Could not connect to server"
                        alertView.show()
                    }
                )
            }
            else {
                alertView.title = "Update Timeline Background"
                var imageData: NSData = UIImageJPEGRepresentation(pic, 1.0);
                let req = API(responseType: "string")
                req.request(.POST, endpoint: "timeline_photo", parameters: params, media_upload: imageData, media_filename: "media.jpg", uploadProgress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                    //println("percentage: \(totalBytesWritten/totalBytesExpectedToWrite*100)%")
                    }, downloadProgress: nil,
                    success: {
                        (json, string, response) in
                        if(json["status"].integerValue==1){
                            indicator.stop()
                            
                            // Modify and save
                            let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
                            let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: self.viewMoc)
                            if(results.count>0){
                                let singleUser = results[0] as Users
                                singleUser.background = imageData
                                SwiftCoreDataHelper.saveManagedObjectContext(self.viewMoc)
                                self.backgroundPhoto.image = pic
                                self.backgroundPhoto.contentMode = UIViewContentMode.Center
                            } else {
                                alertView.message = "User data not exist on database, please re-login"
                                alertView.show()
                            }
                        } else {
                            alertView.message = json["message"].stringValue
                            alertView.show()
                        }
                        return
                    }, failure: { (error: NSError) in
                        println(error)
                        alertView.message = "Could not connect to server"
                        alertView.show()
                    }
                )
            }
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

