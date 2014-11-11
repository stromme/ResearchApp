//
//  FirstViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/15/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var friendTasks:NSMutableArray = NSMutableArray()
    var appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
    var loadImage = 0
    var loadedImage = 0
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var backgroundPhoto: UIImageView!
    @IBOutlet weak var nameDarkenBG: UIView!
    @IBOutlet weak var statDarkenBG: UIView!
    @IBOutlet weak var labelTotalTasks: UILabel!
    @IBOutlet weak var labelWeekTasks: UILabel!
    @IBOutlet weak var labelWeekDoneTasks: UILabel!
    @IBOutlet weak var labelMonthTasks: UILabel!
    @IBOutlet weak var labelMonthDoneTasks: UILabel!

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
        let tapStatDarkenGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseBackgroundPhoto:")
        self.statDarkenBG.addGestureRecognizer(tapStatDarkenGestureRecognizer)
        self.statDarkenBG.userInteractionEnabled = true

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
            } else if(singleUser.valueForKey("photo_url") != nil && singleUser.photo_url != "") {
                let photoIndicator = MiniIndicator(view: self.view, targetView: self.profilePhoto)
                let imageURL: String? = singleUser.photo_url
                photoIndicator.animate({
                    let imageData = NSData(contentsOfURL: NSURL(string: API.updateHost(imageURL!))!)
                    photoIndicator.stop({
                        if(imageData != nil){
                            // Update photo data
                            let userPhotoMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                            let userPhotoPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
                            let userPhotoResults = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: userPhotoPredicate, withSorter: nil, managedObjectContext: userPhotoMoc)
                            for userPhotoResult in userPhotoResults {
                                var singleUserPhoto = userPhotoResult as Users
                                singleUserPhoto.photo = imageData!
                            }
                            SwiftCoreDataHelper.saveManagedObjectContext(userPhotoMoc)
                            self.profilePhoto.transform = CGAffineTransformMakeRotation(360)
                            self.profilePhoto.alpha = 0
                            
                            let photo = UIImage(data: imageData!)!
                            let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: self.profilePhoto.frame.size)
                            let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                            self.profilePhoto.image = photoResized
                            
                            let duration = 0.6
                            let delay = 0.0
                            let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
                            UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
                                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/2, animations: {
                                    self.profilePhoto.transform = CGAffineTransformMakeRotation(0)
                                    self.profilePhoto.alpha = 1
                                })
                                }, completion: { finished in
                            })
                        }
                    })
                })
            }

            if(singleUser.valueForKey("background") != nil){
                let photo = UIImage(data: singleUser.background)!
                let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: self.backgroundPhoto.frame.size)
                let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                self.backgroundPhoto.image = photoResized
                self.backgroundPhoto.contentMode = UIViewContentMode.Center
            } else if(singleUser.valueForKey("background_url") != nil && singleUser.background_url != "") {
                let bgPhotoIndicator = MiniIndicator(view: self.view, targetView: self.backgroundPhoto)
                let imageURL: String? = singleUser.background_url
                bgPhotoIndicator.animate({
                    let bgImageData = NSData(contentsOfURL: NSURL(string: API.updateHost(imageURL!))!)
                    bgPhotoIndicator.stop({
                        if(bgImageData != nil){
                            // Update photo data
                            let userBgMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                            let userBgPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
                            let userBgResults = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: userBgPredicate, withSorter: nil, managedObjectContext: userBgMoc)
                            for userBgResult in userBgResults {
                                var singleUserBg = userBgResult as Users
                                singleUserBg.background = bgImageData!
                            }
                            SwiftCoreDataHelper.saveManagedObjectContext(userBgMoc)
                            self.backgroundPhoto.alpha = 0
                            let photo = UIImage(data: bgImageData!)!
                            let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: self.backgroundPhoto.frame.size)
                            let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                            self.backgroundPhoto.image = photoResized
                            self.backgroundPhoto.contentMode = UIViewContentMode.Center
                            let duration = 0.6
                            let delay = 0.0
                            let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
                            UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
                                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/2, animations: {
                                    self.backgroundPhoto.alpha = 1
                                })
                                }, completion: { finished in
                            })
                        }
                    })
                })
            }
        }

        // Load stats data from db

        let resultPredicate1: NSPredicate = NSPredicate(format: "varname = %@", "total_tasks")!
        let resultPredicate2: NSPredicate = NSPredicate(format: "varname = %@", "week_tasks")!
        let resultPredicate3: NSPredicate = NSPredicate(format: "varname = %@", "week_done")!
        let resultPredicate4: NSPredicate = NSPredicate(format: "varname = %@", "month_tasks")!
        let resultPredicate5: NSPredicate = NSPredicate(format: "varname = %@", "month_done")!
        var sorter: NSSortDescriptor = NSSortDescriptor(key: "varname" , ascending: true)

        let setting_results:NSArray = SwiftCoreDataHelper.fetchEntities("Settings", withPredicate: [resultPredicate1, resultPredicate2, resultPredicate3, resultPredicate4, resultPredicate5], compound: .OR, withSorter: sorter, managedObjectContext: self.viewMoc)
        
        if(setting_results.count>0){
            for setting in setting_results {
                let singleSetting = setting as Settings
                switch(singleSetting.varname){
                case "total_tasks":
                    self.labelTotalTasks.text = "Total tasks: \(singleSetting.value)"
                    break;
                case "week_tasks":
                    self.labelWeekTasks.text = "Tasks this week: \(singleSetting.value)"
                    break;
                case "week_done":
                    self.labelWeekDoneTasks.text = "Tasks done this week: \(singleSetting.value)"
                    break;
                case "month_tasks":
                    self.labelMonthTasks.text = "Tasks this month: \(singleSetting.value)"
                    break;
                case "month_done":
                    self.labelMonthDoneTasks.text = "Tasks done this month: \(singleSetting.value)"
                    break;
                default: break;
                }
            }
        }

        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.width / 2;
        self.profilePhoto.clipsToBounds = true;
        self.profilePhoto.layer.borderWidth = 3.0;
        self.profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor

        self.statDarkenBG.layer.cornerRadius = 5;
        self.statDarkenBG.clipsToBounds = true;
        
        self.statDarkenBG.alpha = 0.0
        self.labelTotalTasks.alpha = 0.0
        self.labelWeekTasks.alpha = 0.0
        self.labelWeekDoneTasks.alpha = 0.0
        self.labelMonthTasks.alpha = 0.0
        self.labelMonthDoneTasks.alpha = 0.0
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(HomeViewCell.self, forCellReuseIdentifier: "DashboardCell")
        var nib = UINib(nibName: "HomeViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "DashboardCell")
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 40))
    }
    
    override func viewDidAppear(animated: Bool) {
        if(self.appDelegate.reusable["fullName"] != nil){
            self.fullName.text = self.appDelegate.reusable["fullName"]
            self.appDelegate.reusable["fullName"] = nil
        }
        if(self.appDelegate.reusable["profilePhotoUpdated"] != nil){
            // Load user data from db
            let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
            let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: self.viewMoc)
            
            if(results.count>0){
                let singleUser = results[0] as Users
                // Get photos
                if(singleUser.valueForKey("photo") != nil){
                    let photo = UIImage(data: singleUser.photo)!
                    let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: self.profilePhoto.frame.size)
                    let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                    self.profilePhoto.image = photoResized
                }
            }
        }

        // Only once
        if(self.statDarkenBG.alpha==0.0){
            self.statDarkenBG.frame.origin.x += 20
            self.labelTotalTasks.frame.origin.x += 20
            self.labelWeekTasks.frame.origin.x += 20
            self.labelWeekDoneTasks.frame.origin.x += 20
            self.labelMonthTasks.frame.origin.x += 20
            self.labelMonthDoneTasks.frame.origin.x += 20
            
            let duration = 2.0
            let delay = 0.0
            let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
            UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/5, animations: {
                    self.statDarkenBG.alpha = 0.3
                    self.statDarkenBG.frame.origin.x -= 20
                })
                UIView.addKeyframeWithRelativeStartTime(1/8, relativeDuration: 1/5, animations: {
                    self.labelTotalTasks.alpha = 1.0
                    self.labelTotalTasks.frame.origin.x -= 20
                })
                UIView.addKeyframeWithRelativeStartTime(2/8, relativeDuration: 1/5, animations: {
                    self.labelWeekTasks.alpha = 1.0
                    self.labelWeekTasks.frame.origin.x -= 20
                })
                UIView.addKeyframeWithRelativeStartTime(3/8, relativeDuration: 1/5, animations: {
                    self.labelWeekDoneTasks.alpha = 1.0
                    self.labelWeekDoneTasks.frame.origin.x -= 20
                })
                UIView.addKeyframeWithRelativeStartTime(4/8, relativeDuration: 1/5, animations: {
                    self.labelMonthTasks.alpha = 1.0
                    self.labelMonthTasks.frame.origin.x -= 20
                })
                UIView.addKeyframeWithRelativeStartTime(5/8, relativeDuration: 1/5, animations: {
                    self.labelMonthDoneTasks.alpha = 1.0
                    self.labelMonthDoneTasks.frame.origin.x -= 20
                })
                }, completion: { finished in
            })
        }
        
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.loadData();
        }
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
            indicator.animate({
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
                                        self.profilePhoto.transform = CGAffineTransformMakeRotation(360)
                                        self.profilePhoto.alpha = 0
                                        self.profilePhoto.image = pic
                                        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
                                            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/2, animations: {
                                                self.profilePhoto.transform = CGAffineTransformMakeRotation(0)
                                                self.profilePhoto.alpha = 1
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
                }
                else {
                    alertView.title = "Update Timeline Background"
                    var imageData: NSData = UIImageJPEGRepresentation(pic, 1.0);
                    let req = API(responseType: "string")
                    req.request(.POST, endpoint: "timeline_photo", parameters: params, media_upload: imageData, media_filename: "media.jpg", uploadProgress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        let percentage: Float = (Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))*100
                        let percentageStr = NSString(format: "%.0f", percentage)
                        indicator.setLabel(label: "Uploading \(percentageStr)%")
                    }, downloadProgress: nil,
                        success: { (json, string, response) in
                            if(json["status"].integerValue==1){
                                // Modify and save
                                let resultPredicate: NSPredicate = NSPredicate(format: "username = %@", self.appDelegate.username!)!
                                let results = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: resultPredicate, withSorter: nil, managedObjectContext: self.viewMoc)
                                if(results.count>0){
                                    let singleUser = results[0] as Users
                                    singleUser.background = imageData
                                    SwiftCoreDataHelper.saveManagedObjectContext(self.viewMoc)
                                    self.backgroundPhoto.contentMode = UIViewContentMode.Center
                                    indicator.stop({
                                        self.backgroundPhoto.image = pic
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
                }
            }, label: "Uploading")
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadData(){
        self.friendTasks.removeAllObjects()
        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        
        let predicate:NSPredicate = NSPredicate(format:"user_id != %@", self.appDelegate.id!)!
        let sorter:NSSortDescriptor? = NSSortDescriptor(key: "id" , ascending: false)
        
        let tasksResults:NSArray = SwiftCoreDataHelper.fetchEntities("Tasks", withPredicate: predicate, withSorter: sorter, managedObjectContext: moc)

        var downloadImage = 0
        for taskResult in tasksResults {
            let singleTask:Tasks = taskResult as Tasks
            var downloadPhoto = 0
            if(singleTask.valueForKey("photo") == nil){
                singleTask.photo = NSData()
                if(singleTask.valueForKey("photo_url") != nil && singleTask.valueForKey("photo_url")?.length>0){
                    downloadPhoto = 1
                    downloadImage += 1
                }
            }
            var taskDict:NSMutableDictionary = ["id":singleTask.id,"user_id":singleTask.user_id,"title":singleTask.title,"desc":singleTask.desc,"photo":singleTask.photo,"photo_url":singleTask.photo_url,"is_public":singleTask.is_public,"is_done":singleTask.is_done,"due":singleTask.due,"download_photo":downloadPhoto]
            self.friendTasks.addObject(taskDict)
        }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)

        if(downloadImage <= 0){
            self.tableView.reloadData()
        } else {
            let indi = CustomIndicator(view: self.view)
            self.loadImage = 0
            self.loadedImage = 0
            indi.animate({
                for (taskIdx, taskDict) in enumerate(self.friendTasks) {
                    if(taskDict.objectForKey("download_photo") as Int == 1){
                        if(taskDict.objectForKey("photo_url") != nil){
                            self.loadImage += 1
                            Alamofire.manager.request(.GET, API.updateHost(taskDict.objectForKey("photo_url") as String)).response { (request, response, data, error) in
                                if(data != nil){
                                    var newTaskDict:NSMutableDictionary = self.friendTasks.objectAtIndex(taskIdx) as NSMutableDictionary
                                    newTaskDict.setValue(data, forKey: "photo")
                                    newTaskDict.setValue(0, forKey: "download_photo")
                                    self.friendTasks.replaceObjectAtIndex(taskIdx, withObject: newTaskDict)
                                    
                                    let taskPhotoMoc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                    let taskPhotoPredicate: NSPredicate = NSPredicate(format: "id = %@", taskDict.objectForKey("id") as String)!
                                    let taskPhotoResults = SwiftCoreDataHelper.fetchEntities("Tasks", withPredicate: taskPhotoPredicate, withSorter: nil, managedObjectContext: taskPhotoMoc)
                                    for taskPhotoResult in taskPhotoResults {
                                        var singleTaskPhoto: Tasks = taskPhotoResult as Tasks
                                        singleTaskPhoto.photo = data! as NSData
                                    }
                                    SwiftCoreDataHelper.saveManagedObjectContext(taskPhotoMoc)
                                }
                                self.loadedImage += 1
                                indi.setLabel(label: "Downloading task photos \(self.loadedImage) of \(self.loadImage)")
                                if(self.loadedImage==self.loadImage){
                                    indi.stop({
                                        self.tableView.reloadData()
                                    })
                                }
                            }
                        }
                    }
                }
                }, label: "Downloading task photos")
        }
    }

    // #pragma mark - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendTasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:HomeViewCell = self.tableView.dequeueReusableCellWithIdentifier("DashboardCell", forIndexPath: indexPath) as HomeViewCell
        if(!cell.loaded){
            let taskDict:NSDictionary = friendTasks.objectAtIndex(indexPath.row) as NSDictionary

            let id = taskDict.objectForKey("id") as String
            let user_id = taskDict.objectForKey("user_id") as String
            let title = taskDict.objectForKey("title") as String
            let desc = taskDict.objectForKey("desc") as String
            //let done = taskDict.objectForKey("is_done") as Int
            
            let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
            let predicate:NSPredicate = NSPredicate(format:"id = %@", user_id)!
            let userResults:NSArray = SwiftCoreDataHelper.fetchEntities("Users", withPredicate: predicate, withSorter: nil, managedObjectContext: moc)
            if(userResults.count>0){
                for userResult in userResults {
                    let singleUser:Users = userResult as Users
                    let username = singleUser.valueForKey("username") as String
                    cell.task_owner.text = "\(username)'s task"
                }
            } else {
                cell.task_owner.text = ""
            }

            let imageData:NSData? = taskDict.objectForKey("photo") as? NSData
            if(imageData != nil && imageData?.length>0){
                let photo = UIImage(data:imageData!)!
                let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: cell.task_photo.frame.size)
                let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
                cell.task_photo.image = photoResized
            } else {
                cell.task_photo.image = UIImage(named: "icon-photo")
                cell.task_photo.layer.borderWidth = 1.0;
                cell.task_photo.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
            }

            //if(done==1){
                //cell.task_done.hidden = false
            //}
            
            cell.frame = CGRectMake(0, 0, 320, 90)
            cell.task_title.text = title
            cell.task_desc.text = desc
            
            // Overflow hidden
            cell.task_photo.clipsToBounds = true;
            cell.task_photo.layer.cornerRadius = cell.task_photo.frame.size.width / 2;

            cell.loaded = true
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        println("You selected cell #\(indexPath.row)!")
        
        
        
    }
}

