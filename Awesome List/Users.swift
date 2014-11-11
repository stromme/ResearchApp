//
//  Users.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/22/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import CoreData

@objc(Users)
class Users: NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var username: String
    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var email: String
    @NSManaged var company: String
    @NSManaged var location: String
    @NSManaged var photo: NSData
    @NSManaged var background: NSData
    @NSManaged var photo_url: String
    @NSManaged var background_url: String
    @NSManaged var friendship: Friendship
    @NSManaged var tasks: Tasks
    
}
