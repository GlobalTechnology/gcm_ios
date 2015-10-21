//
//  Assignment.swift
//  gcmapp
//
//  Created by Jon Vellacott on 27/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData
@objc(Assignment)
class Assignment: NSManagedObject {

    @NSManaged var first_name: String
    @NSManaged var id: String?
    @NSManaged var last_name: String
    @NSManaged var person_id: String
    @NSManaged var team_role: String
    @NSManaged var ministry: Ministry

}
