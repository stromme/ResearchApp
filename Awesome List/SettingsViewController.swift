//
//  SettingsController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UITableViewController {
    @IBOutlet weak var keyLabel: UILabel!
    var appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.appDelegate.key != nil){
            self.keyLabel.text = self.appDelegate.key
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickSaveSetting(sender: AnyObject) {
        var alertView = UIAlertView()
        alertView.title = "Setting"
        alertView.message = "Setting saved!"
        alertView.addButtonWithTitle("Okay")
        alertView.show()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row==2){
            let indicator = CustomIndicator(view: self.view)
            indicator.animate()
            
            let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
            var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Settings")
            let resultPredicate1: NSPredicate = NSPredicate(format: "varname = %@", "username")!
            let resultPredicate2: NSPredicate = NSPredicate(format: "varname = %@", "key")!
            var sorter: NSSortDescriptor = NSSortDescriptor(key: "varname" , ascending: true)
            
            let results = SwiftCoreDataHelper.fetchEntities("Settings", withPredicate: [resultPredicate1, resultPredicate2], compound: .OR, withSorter: sorter, managedObjectContext: moc)
            if(results.count>0){
                for setting in results {
                    var settingItem = setting as Settings
                    moc.deleteObject(settingItem)
                }
                SwiftCoreDataHelper.saveManagedObjectContext(moc)
            }
            
            // Fake progress
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                indicator.stop()
                self.performSegueWithIdentifier("returnToLogin", sender: self)
            }
        }
    }

    // Clear login form
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "returnToLogin") {
            var loginVC = segue.destinationViewController as LoginViewController
            loginVC.inputUsername.text = ""
            loginVC.inputPassword.text = ""
        }
    }*/
}
