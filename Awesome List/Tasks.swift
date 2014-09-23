//
//  Tasks.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/22/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import CoreData

@objc(Tasks)
class Tasks: NSManagedObject {

    @NSManaged var datetime: NSDate
    @NSManaged var desc: String
    @NSManaged var id: String
    @NSManaged var is_done: NSNumber
    @NSManaged var is_public: NSNumber
    @NSManaged var photo: NSData
    @NSManaged var title: String
    @NSManaged var members: Members

}
