//
//  TaskViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UITableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var task_title: UITextField!
    @IBOutlet weak var task_desc: UITextField!
    @IBOutlet weak var task_public: UISwitch!
    @IBOutlet weak var task_done: UISwitch!
    @IBOutlet weak var task_photo: UIImageView!
    @IBOutlet weak var task_date: UIDatePicker!
    var task_original_photo: UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        var task:Tasks = SwiftCoreDataHelper.insertManagedObject("Tasks", managedObjectConect: moc)
         as Tasks

        task.id = "\(NSDate())"
        task.title = task_title.text
        task.desc = task_desc.text
        task.datetime = task_date.date
        task.is_done = task_done.on
        
        task.is_public = task_public.on
        var taskImageData = NSData()
        let original_size = task_original_photo.size
        let zero = CGSizeMake(0,0)
        if(original_size.width>zero.width || original_size.height>zero.height){
            taskImageData = UIImageJPEGRepresentation(task_original_photo, 100)
        }
        task.photo = taskImageData
        
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func chooseImage(recognizer: UITapGestureRecognizer){
        let actionSheet:UIActionSheet = UIActionSheet()
        //actionSheet.title = "Task photo"
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.addButtonWithTitle("Library")
        actionSheet.addButtonWithTitle("Take a Photo")
        actionSheet.cancelButtonIndex = 0
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(sheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int){
        // println("index %d %@", buttonIndex, sheet.buttonTitleAtIndex(buttonIndex));
        
        if(sheet.buttonTitleAtIndex(buttonIndex) == "Library"){
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
}
