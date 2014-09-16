//
//  Tasks.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/15/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import CoreData

class Tasks: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var desc: String
    @NSManaged var photo: String
    @NSManaged var is_public: Bool
    @NSManaged var is_done: String
    @NSManaged var datetime: NSDate
    @NSManaged var members: NSManagedObject

}
