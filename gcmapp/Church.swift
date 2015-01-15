//
//  Church.swift
//  gcmapp
//
//  Created by Jon Vellacott on 11/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData

class Church: NSManagedObject {

    @NSManaged var contact_email: String
    @NSManaged var contact_name: String
    @NSManaged var development: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var jf_contrib: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var ministry_id: String
    @NSManaged var name: String
    @NSManaged var parent_id: NSNumber
    @NSManaged var security: NSNumber
    @NSManaged var size: NSNumber
    @NSManaged var start_date: String
    @NSManaged var changed: NSNumber
    @NSManaged var children: NSSet
    @NSManaged var parent: Church

}
