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
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(strcmp("delete_task", "")<0){
            let params = [
                "key": "036db17bac87dbb1e610df07ccc2468e"
            ]
            let task_id = 1;
            Alamofire.manager.request(.DELETE, API.url("tasks/\(task_id)"), parameters: params)
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        loadData();
    }
    
    func loadData(){
        myTasks.removeAllObjects()
        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        let predicate:NSPredicate? = nil //NSPredicate(format:"name CONTAINS 'B' ")
        let sorter:NSSortDescriptor? = nil //NSSortDescriptor(key: "name" , ascending: false)
        
        let results:NSArray = SwiftCoreDataHelper.fetchEntities("Tasks", withPredicate: predicate, withSorter: sorter, managedObjectContext: moc)
        
        for task in results {
            let singleTask:Tasks = task as Tasks
            if(singleTask.valueForKey("photo")==nil){
                singleTask.photo = NSData()
            }
            let taskDict:NSDictionary = ["id":singleTask.id,"title":singleTask.title,"desc":singleTask.desc,"photo":singleTask.photo,"is_public":singleTask.is_public,"is_done":singleTask.is_done,"datetime":singleTask.datetime]
            myTasks.addObject(taskDict)
        }
        self.tableView.reloadData()
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
        
        let taskDict:NSDictionary = myTasks.objectAtIndex(indexPath.row) as NSDictionary
        
        let title = taskDict.objectForKey("title") as String
        let desc = taskDict.objectForKey("desc") as String
        let imageData:NSData? = taskDict.objectForKey("photo") as? NSData

        var photo:UIImage = UIImage(data: NSData())!
        if(imageData == NSData()){
            cell.task_photo.image = UIImage(named: "icon-photo")
            cell.task_photo.layer.borderWidth = 1.0;
            cell.task_photo.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).CGColor
        } else {
            photo = UIImage(data:imageData!)!
            let resizedSize = ImageHelper.aspectFill(photo.size, frameSize: cell.task_photo.frame.size)
            let photoResized = ImageHelper.scaleImage(photo, newSize: resizedSize)
            cell.task_photo.image = photoResized
        }
        
        cell.task_title.text = title
        cell.task_desc.text = desc

        cell.task_photo.layer.cornerRadius = 5;
        cell.task_photo.clipsToBounds = true;
        
        cell.btn_public.tag = indexPath.row
        cell.btn_public.addTarget(self, action: "updatePrivacy:", forControlEvents: UIControlEvents.TouchUpInside)

        return cell
    }
    
    func updatePrivacy(sender:UIButton){
        sender.setTitle("Private", forState: UIControlState.Normal)
    }
}

