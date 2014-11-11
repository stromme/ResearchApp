//
//  Friendship.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/22/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import CoreData

@objc(Friendship)
class Friendship: NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var my_id: String
    @NSManaged var my_username: String
    @NSManaged var friend_id: String
    @NSManaged var friend_username: String
    @NSManaged var users: Users
    
}
