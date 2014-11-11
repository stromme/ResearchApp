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

    @NSManaged var id: String
    @NSManaged var user_id: String
    @NSManaged var title: String
    @NSManaged var desc: String
    @NSManaged var photo: NSData
    @NSManaged var photo_url: String
    @NSManaged var is_done: NSNumber
    @NSManaged var is_public: NSNumber
    @NSManaged var due: NSDate
    @NSManaged var modified: NSDate
    @NSManaged var location: String
    @NSManaged var users: Users

}
