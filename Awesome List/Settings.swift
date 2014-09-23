//
//  Settings.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/22/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import CoreData

@objc(Settings)
class Settings: NSManagedObject {

    @NSManaged var value: String
    @NSManaged var varname: String

}
