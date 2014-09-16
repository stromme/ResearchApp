//
//  Settings.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import CoreData

class Settings: NSManagedObject {

    @NSManaged var varname: String
    @NSManaged var value: String

}
