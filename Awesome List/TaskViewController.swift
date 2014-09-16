//
//  TaskViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class TaskViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTask(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func clickCancelTask(sender: AnyObject) {
        self.performSegueWithIdentifier("returnToTasks", sender: self)
    }
}
