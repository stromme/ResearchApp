//
//  Members.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/15/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import CoreData

class Members: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var username: String
    @NSManaged var password: String
    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var email: String
    @NSManaged var company: String
    @NSManaged var location: String
    @NSManaged var photo: String
    @NSManaged var tasks: Tasks

}
