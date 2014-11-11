//
//  SecondViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/15/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TasksViewController: UITableViewController {
    var myTasks:NSMutableArray = NSMutableArray()
    var appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
    var selectedRow: Int = -1
    var loadImage = 0
    var loadedImage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        loadData();
    }

    func loadData(){
        self.myTasks.removeAllObjects()
        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()

        let predicate:NSPredicate = NSPredicate(format:"user_id = %@", self.appDelegate.id!)!
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
            var taskDict:NSMutableDictionary = ["id":singleTask.id,"title":singleTask.title,"desc":singleTask.desc,"photo":singleTask.photo,"photo_url":singleTask.photo_url,"is_public":singleTask.is_public,"is_done":singleTask.is_done,"due":singleTask.due,"download_photo":downloadPhoto]
            self.myTasks.addObject(taskDict)
        }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)

        if(downloadImage <= 0){
            self.tableView.reloadData()
        } else {
            let indi = CustomIndicator(view: self.view)
            self.loadImage = 0
            self.loadedImage = 0
            indi.animate({
                for (taskIdx, taskDict) in enumerate(self.myTasks) {
                    if(taskDict.objectForKey("download_photo") as Int == 1){
                        if(taskDict.objectForKey("photo_url") != nil){
                            self.loadImage += 1
                            Alamofire.manager.request(.GET, API.updateHost(taskDict.objectForKey("photo_url") as String)).response { (request, response, data, error) in
                                if(data != nil){
                                    var newTaskDict:NSMutableDictionary = self.myTasks.objectAtIndex(taskIdx) as NSMutableDictionary
                                    newTaskDict.setValue(data, forKey: "photo")
                                    newTaskDict.setValue(0, forKey: "download_photo")
                                    self.myTasks.replaceObjectAtIndex(taskIdx, withObject: newTaskDict)

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToTasks(segue: UIStoryboardSegue){}
    
    // #pragma mark - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTasks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:TaskViewCell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as TaskViewCell
        
        if(!cell.loaded){
            let taskDict:NSDictionary = myTasks.objectAtIndex(indexPath.row) as NSDictionary

            let title = taskDict.objectForKey("title") as String
            let desc = taskDict.objectForKey("desc") as String
            let done = taskDict.objectForKey("is_done") as Int
            
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
            
            if(done==1){
                //cell.task_done.hidden = false
            }

            cell.frame = CGRectMake(0, 0, 320, 80)
            cell.task_title.text = title
            cell.task_desc.text = desc

            // Overflow hidden
            cell.task_photo.clipsToBounds = true;

            cell.btn_public.tag = indexPath.row
            cell.btn_public.addTarget(self, action: "updatePrivacy:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.loaded = true
        }
        return cell
    }
    
    func updatePrivacy(sender:UIButton){
        if(sender.titleLabel?.text=="Public"){
            sender.setTitle("Private", forState: UIControlState.Normal)
        } else {
            sender.setTitle("Public", forState: UIControlState.Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "editTask"){
            if(self.selectedRow>=0){
                var taskDict:NSMutableDictionary = self.myTasks.objectAtIndex(self.selectedRow) as NSMutableDictionary
                let editTaskVC: TaskViewController = segue.destinationViewController as TaskViewController
                editTaskVC.task_title.text = taskDict.valueForKey("title") as String
                editTaskVC.task_desc.text = taskDict.valueForKey("desc") as String
                editTaskVC.action = "edit"
                self.selectedRow = -1
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedRow = indexPath.row
        //println("You selected cell #\(indexPath.row)!")
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let indicator = CustomIndicator(view: self.view)
        var alertView = UIAlertView()
        alertView.title = "Delete Task"
        alertView.message = ""
        alertView.addButtonWithTitle("Okay")

        if(editingStyle == .Delete){
            if(self.myTasks.count>0){
                var taskDict:NSMutableDictionary = self.myTasks.objectAtIndex(indexPath.row) as NSMutableDictionary
                indicator.animate({
                    let params = [
                        "key": String(self.appDelegate.key!)
                    ]
                    let task_id = taskDict.valueForKey("id") as String
                    Alamofire.manager.request(.DELETE, API.url("tasks/\(task_id)"), parameters: params) .responseSwiftyJSON { (request, response, json, error) in
                        if(json.boolValue){
                            if(json["status"].integerValue==1){
                                let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
                                let predicate: NSPredicate = NSPredicate(format: "id = %@", taskDict.objectForKey("id") as String)!
                                let tasksResults = SwiftCoreDataHelper.fetchEntities("Tasks", withPredicate: predicate, withSorter: nil, managedObjectContext: moc)
                                for taskResult in tasksResults {
                                    var singleTask: Tasks = taskResult as Tasks
                                    moc.deleteObject(singleTask)
                                }
                                SwiftCoreDataHelper.saveManagedObjectContext(moc)
                                indicator.stop({
                                    let notification = CustomNotification(view: self.view, label: "Task deleted")
                                    /*tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                                    let delay = 0.5 * Double(NSEC_PER_SEC)
                                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                    dispatch_after(time, dispatch_get_main_queue()) {*/
                                        self.loadData();
                                    //}
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
        } else if(editingStyle == .Insert) {
            
        }
    }
}

