//
//  TaskViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TaskViewController: UITableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    var appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
    @IBOutlet weak var task_title: UITextField!
    @IBOutlet weak var task_desc: UITextField!
    @IBOutlet weak var task_public: UISwitch!
    @IBOutlet weak var task_done: UISwitch!
    @IBOutlet weak var task_photo: UIImageView!
    @IBOutlet weak var task_date: UIDatePicker!
    @IBOutlet weak var task_location_name: UITextField!
    
    var task_original_photo: UIImage =  UIImage()
    var task_id: String?
    var action: String = "add"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        task_title.delegate = self
        task_desc.delegate = self
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseImage:")
        
        task_photo.addGestureRecognizer(tapGestureRecognizer)
        task_photo.userInteractionEnabled = true
        
        // Round corner it
        task_photo.layer.cornerRadius = 20;
        task_photo.clipsToBounds = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTask(segue: UIStoryboardSegue){}
    
    @IBAction func clickCancelTask(sender: AnyObject) {
        self.performSegueWithIdentifier("returnToTasks", sender: self)
    }
    
    @IBAction func clickSaveTask(sender: AnyObject) {
        task_title.resignFirstResponder()
        task_desc.resignFirstResponder()
        
        var alertView = UIAlertView()
        alertView.addButtonWithTitle("Okay")

        var indicator = CustomIndicator(view: self.view)
        if(self.action == "add"){
            alertView.title = "Add New Task"
            if(task_title.text != "" && task_desc != ""){
                let params = [
                    "key": String(self.appDelegate.key!),
                    "title": self.task_title.text,
                    "desc": self.task_desc.text,
                    "public": (self.task_public.on) ? 1 : 0,
                    "done": (self.task_done.on) ? 1 : 0,
                    "due": self.task_date.date,
                    "location": self.task_location_name.text
                ]

                var taskImageData: NSData = NSData()
                var imageEmpty: Bool = true
                
                let original_size: CGSize = self.task_original_photo.size
                let zero = CGSizeMake(0,0)
                if(original_size.width>zero.width || original_size.height>zero.height){
                    taskImageData = UIImageJPEGRepresentation(self.task_photo.image, 1)
                    imageEmpty = false
                }

                indicator.animate({
                    let req = API()
                    var uploadProgress: SwifterHTTPRequest.UploadProgressHandler? = nil
                    if(!imageEmpty){
                        uploadProgress = {
                            (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                            let percentage: Float = (Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))*100
                            let percentageStr = NSString(format: "%.0f", percentage)
                            indicator.setLabel(label: "Uploading \(percentageStr)%")
                        }
                    }

                    let successHandler: API.SuccessHandler = { (json, string, response) in
                        indicator.stop({
                            if(json["status"].integerValue==1){

                                let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                var task:Tasks = SwiftCoreDataHelper.insertManagedObject("Tasks", managedObjectConect: moc)
                                    as Tasks

                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                                
                                task.id = json["result"]["id"].stringValue!
                                task.user_id = json["result"]["user_id"].stringValue!
                                task.title = self.task_title.text
                                task.desc = self.task_desc.text
                                task.due = self.task_date.date
                                task.is_done = self.task_done.on
                                task.is_public = self.task_public.on
                                task.user_id = String(self.appDelegate.id!)
                                task.location = self.task_location_name.text
                                task.photo = taskImageData
                                task.photo_url = json["result"]["photo"].stringValue!
                                task.modified = dateFormatter.dateFromString(json["result"]["modified"].stringValue!)!

                                SwiftCoreDataHelper.saveManagedObjectContext(moc)
                                
                                self.navigationController?.popViewControllerAnimated(true)
                            } else {
                                alertView.message = json["message"].stringValue
                                alertView.show()
                            }
                        })
                        return
                    }

                    let failureHandler: API.FailureHandler = { (error: NSError) in
                        indicator.stop({
                            println(error)
                            alertView.message = "Could not connect to server"
                            alertView.show()
                        })
                    }

                    req.request(.POST, endpoint: "tasks", parameters: params, media_upload: (!imageEmpty) ? taskImageData : nil, media_filename: "media.jpg",
                        uploadProgress: uploadProgress, downloadProgress: nil,
                        success: successHandler, failure: failureHandler
                    )
                }, label: "Saving task")
            } else {
                alertView.message = "Please add at least title and description"
                alertView.show()
            }
        } else if(self.action == "edit") {
            alertView.title = "Update Task"
            if(task_title.text != "" && task_desc != ""){
                let params = [
                    "key": "036db17bac87dbb1e610df07ccc2468e",
                    "title": self.task_title.text,
                    "desc": self.task_desc.text,
                    "public": (self.task_public.on) ? 1 : 0,
                    "done": (self.task_done.on) ? 1 : 0,
                    "due": self.task_date.date,
                    "location": self.task_location_name.text
                ]
                
                var taskImageData: NSData?
                var imageEmpty: Bool = true
                let original_size: CGSize = self.task_original_photo.size
                let zero = CGSizeMake(0,0)
                if(original_size.width>zero.width || original_size.height>zero.height){
                    taskImageData = UIImageJPEGRepresentation(self.task_original_photo, 100)
                    imageEmpty = false
                }
                
                let req = API(responseType: "string")
                var uploadProgress: SwifterHTTPRequest.UploadProgressHandler? = nil
                if(!imageEmpty){
                    uploadProgress = {
                        (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        /*println("bytes written")
                        println(bytesWritten)
                        println("total bytes written")
                        println(totalBytesWritten)
                        println("total bytes expected to write")
                        println(totalBytesExpectedToWrite)*/
                    }
                }
                
                let successHandler: API.SuccessHandler = { (json, string, response) in
                    println("string")
                    println(string)
                    if(json["status"].integerValue==1){
                        // TODO: Save data to task database
                        // TODO: Save this photo to task database
                        println("---id---")
                        println(json["id"])
                    } else {
                        alertView.message = json["message"].stringValue
                        alertView.show()
                    }
                    
                    
                    //self.loginButton.hidden = false
                    
                    return
                }
                
                let failureHandler: API.FailureHandler = { (error: NSError) in
                    println(error)
                    alertView.message = "Could not connect to server"
                    alertView.show()
                }

                if(task_id != nil){
                    req.request(.POST, endpoint: "tasks_with_media/\(task_id)", parameters: params, media_upload: (!imageEmpty) ? taskImageData : nil, media_filename: "media.jpg",
                        uploadProgress: uploadProgress, downloadProgress: nil,
                        success: successHandler, failure: failureHandler
                    )
                } else {
                    alertView.message = "Task id not valid"
                    alertView.show()
                }
                
                // Without PHOTO Update
                /*Alamofire.manager.request(.PUT, API.url("tasks/\(task)id)"), parameters: params)
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
                }*/
            } else {
                alertView.message = "Please add at least title and description"
                alertView.show()
            }
        }
    }
    
    func chooseImage(recognizer: UITapGestureRecognizer){
        task_title.resignFirstResponder()
        task_desc.resignFirstResponder()

        let actionSheet:UIActionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.title = "Task Photo"
        
        actionSheet.addButtonWithTitle("Take a Photo")
        actionSheet.addButtonWithTitle("Camera Roll")
        actionSheet.addButtonWithTitle("Library")
        
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = 3
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(sheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int){
        // println("index %d %@", buttonIndex, sheet.buttonTitleAtIndex(buttonIndex));
        
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
        
        let pickedImage:UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        
        // Aspect
        let pickedSize = pickedImage.size
        let aspect:CGFloat  = pickedSize.width / pickedSize.height
        
        let viewSize:CGRect = task_photo.frame
        var resizedSize = ImageHelper.aspectFill(pickedSize, frameSize: viewSize.size)

        // Thumb picture
        let thumbPic = ImageHelper.scaleImage(pickedImage, newSize: resizedSize)
        task_photo.image = thumbPic

        // Round corner it
        task_photo.layer.cornerRadius = 10;
        task_photo.clipsToBounds = true;
        
        let originalSize:CGSize = CGSizeMake(640, 640)
        resizedSize = ImageHelper.aspectFill(pickedSize, frameSize: originalSize)
        task_original_photo = ImageHelper.scaleImage(pickedImage, newSize: resizedSize)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Hide keyboard on press return
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.clickSaveTask(textField)
        return true;
    }
}
