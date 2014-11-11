//
//  ProfileViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ProfileViewController: UITableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    var appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var updateProfilePhotoButton: UIButton!
    @IBOutlet weak var editFirstName: UITextField!
    @IBOutlet weak var editLastName: UITextField!
    @IBOutlet weak var editCompany: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editLocation: UITextField!
    @IBOutlet weak var editPassword: UITextField!
    @IBOutlet weak var editConfirmPassword: UITextField!
    @IBOutlet weak var btnDeactivate: UIButton!
    @IBOutlet var profileTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    let viewMoc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        editFirstName.delegate = self
        editLastName.delegate = self
        editCompany.delegate = self
        editLocation.delegate = self
        editPassword.delegate = self
        editConfirmPassword.delegate = self
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        profileTableView.addGestureRecognizer(tapGestureRecognizer)
        
        let tapPPBtnGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseProfilePhoto:")
        self.updateProfilePhotoButton.addGestureRecognizer(tapPPBtnGestureRecognizer)
        self.updateProfilePhotoButton.userInteractionEnabled = true
        
        let tapPPGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseProfilePhoto:")
        self.profileImageView.addGestureRecognizer(tapPPGestureRecognizer)
        self.profileImageView.userInteractionEnabled = true
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = true;
        
        // Load user data from db
        let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
        let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: self.viewMoc)
        
        if(results.count>0){
            let singleUser = results[0] as Users
            let username = (String(singleUser.username) != nil) ? singleUser.username : ""
            let firstName = (String(singleUser.firstname) != nil) ? singleUser.firstname : ""
            let lastName = (String(singleUser.lastname) != nil) ? singleUser.lastname : ""
            let email = (String(singleUser.email) != nil) ? singleUser.email : ""
            let company = (String(singleUser.company) != nil) ? singleUser.company : ""
            let location = (String(singleUser.location) != nil) ? singleUser.location : ""
            
            self.usernameLabel.text = username
            self.editFirstName.text = firstName
            self.editLastName.text = lastName
            self.editEmail.text = email
            self.editCompany.text = company
            self.editLocation.text = location

            // Get photos
            if(singleUser.valueForKey("photo") != nil){
                let photo = UIImage(data: singleUser.photo)!
                let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: self.profileImageView.frame.size)
                let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                self.profileImageView.image = photoResized
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if(self.appDelegate.reusable["profilePhotoUpdated"] != nil){
            // Load user data from db
            let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
            let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: self.viewMoc)
            if(results.count>0){
                let singleUser = results[0] as Users
                // Get photos
                if(singleUser.valueForKey("photo") != nil){
                    let photo = UIImage(data: singleUser.photo)!
                    let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: self.profileImageView.frame.size)
                    let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                    self.profileImageView.image = photoResized
                }
            }
        }
    }
    
    @IBAction func clickSaveProfile(sender: AnyObject) {
        self.editFirstName.resignFirstResponder()
        self.editLastName.resignFirstResponder()
        self.editCompany.resignFirstResponder()
        self.editLocation.resignFirstResponder()
        self.editPassword.resignFirstResponder()
        self.editConfirmPassword.resignFirstResponder()

        var alertView = UIAlertView()
        alertView.title = "Profile"
        alertView.message = ""
        alertView.addButtonWithTitle("Okay")

        var formValid = true
        let editPassword = (self.editPassword.text != "" || self.editConfirmPassword.text != "")
        var passwordConfirm = false
        if(editPassword){
            passwordConfirm = (self.editPassword.text == self.editConfirmPassword.text)
            if(!passwordConfirm) {
                formValid = false
                alertView.message = "Please confirm password"
                alertView.show()
            }
        } else if(self.editFirstName.text == ""){
            formValid = false
            alertView.message = "First name can't be empty"
            alertView.show()
        } else if(self.editLastName.text == ""){
            formValid = false
            alertView.message = "Last name can't be empty"
            alertView.show()
        } else if(self.editEmail.text == ""){
            formValid = false
            alertView.message = "Email name can't be empty"
            alertView.show()
        }

        if(formValid){
            let indicator = CustomIndicator(view: self.view)
            indicator.animate({
                var params = [
                    "key": String(self.appDelegate.key!),
                    "firstname": self.editFirstName.text,
                    "lastname": self.editLastName.text,
                    "email": self.editEmail.text,
                    "company": self.editCompany.text,
                    "location": self.editLocation.text
                ]
                if(editPassword){
                    params["password"] = self.editPassword.text
                }
                Alamofire.manager.request(.PUT, API.url("account"), parameters: params)
                    .responseSwiftyJSON { (request, response, json, error) in
                    if(json.boolValue){
                        if(json["status"].integerValue==1){
                            // Load user data from db
                            let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
                            let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: self.viewMoc)
                            if(results.count>0){
                                var userItem: Users = results[0] as Users
                                userItem.firstname = self.editFirstName.text
                                userItem.lastname = self.editLastName.text
                                userItem.email = self.editEmail.text
                                userItem.company = self.editCompany.text
                                userItem.location = self.editLocation.text
                                SwiftCoreDataHelper.saveManagedObjectContext(self.viewMoc)
                            }

                            self.appDelegate.reusable["fullName"] = "\(self.editFirstName.text) \(self.editLastName.text)"

                            indicator.stop({
                                let customNotif = CustomNotification(view: self.view, label: "Profile saved!")
                                self.editPassword.text = ""
                                self.editConfirmPassword.text = ""
                            })
                        } else if(json["message"].stringValue == "Nothing to update") {
                            indicator.stop({
                                let customNotif = CustomNotification(view: self.view, label: "No changes")
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
            })
        }
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        editFirstName.resignFirstResponder()
        editLastName.resignFirstResponder()
        editCompany.resignFirstResponder()
        editLocation.resignFirstResponder()
        editPassword.resignFirstResponder()
        editConfirmPassword.resignFirstResponder()
        self.clickSaveProfile(textField)
        return true;
    }

    func hideKeyboard(recognizer: UITapGestureRecognizer){
        editFirstName.resignFirstResponder()
        editLastName.resignFirstResponder()
        editCompany.resignFirstResponder()
        editLocation.resignFirstResponder()
        editPassword.resignFirstResponder()
        editConfirmPassword.resignFirstResponder()
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
            indicator.animate({
                let pickedImage:UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
                
                // Aspect
                let pickedSize = pickedImage.size
                let aspect:CGFloat  = pickedSize.width / pickedSize.height
                
                let viewSize:CGRect = self.profileImageView.frame
                var resizedSize = ImageHelper.aspectFill(pickedSize, frameSize: viewSize.size)
                
                // Resized photo
                let pic = ImageHelper.scaleImage(pickedImage, newSize: resizedSize)
                let params = [
                    "key": String(self.appDelegate.key!)
                ]
                var alertView = UIAlertView()
                alertView.addButtonWithTitle("Okay")
                alertView.title = "Update Profile Photo"
                var imageData: NSData = UIImageJPEGRepresentation(pic, 1.0);
                let req = API(responseType: "string")
                req.request(.POST, endpoint: "profile_photo", parameters: params, media_upload: imageData, media_filename: "media.jpg", uploadProgress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        let percentage: Float = (Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))*100
                        let percentageStr = NSString(format: "%.0f", percentage)
                        indicator.setLabel(label: "Uploading \(percentageStr)%")
                    }, downloadProgress: nil, success: { (json, string, response) in
                        if(json["status"].integerValue==1){
                            // Modify and save
                            let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
                            let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: self.viewMoc)
                            if(results.count>0){
                                let singleUser = results[0] as Users
                                singleUser.photo = imageData
                                SwiftCoreDataHelper.saveManagedObjectContext(self.viewMoc)
                                self.appDelegate.reusable["profilePhotoUpdated"] = "1"
                                
                                indicator.stop({
                                    let duration = 0.6
                                    let delay = 0.0
                                    let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
                                    self.profileImageView.transform = CGAffineTransformMakeRotation(360)
                                    self.profileImageView.alpha = 0
                                    self.profileImageView.image = pic
                                    UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
                                        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/2, animations: {
                                            self.profileImageView.transform = CGAffineTransformMakeRotation(0)
                                            self.profileImageView.alpha = 1
                                        })
                                        }, completion: { finished in
                                    })
                                })
                            } else {
                                indicator.stop({
                                    alertView.message = "User data not exist on database, please re-login"
                                    alertView.show()
                                })
                            }
                        } else {
                            indicator.stop({
                                alertView.message = json["message"].stringValue
                                alertView.show()
                            })
                        }
                        return
                    }, failure: { (error: NSError) in
                        indicator.stop({
                            println(error)
                            alertView.message = "Could not connect to server"
                            alertView.show()
                        })
                    }
                )
            }, label: "Uploading")
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func deactivateClick(sender: AnyObject) {
        // TODO: Confirm deactivate
        if(strcmp("deactivate", "")<0){
            let params = [
                "key": String(self.appDelegate.key!)
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
