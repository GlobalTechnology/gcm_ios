//
//  Church.swift
//  gcmapp
//
//  Created by Jon Vellacott on 27/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.


import Foundation
import CoreData
@objc(Church)
class Church: NSManagedObject {

    @NSManaged var changed: NSNumber
    @NSManaged var contact_email: String
    @NSManaged var contact_name: String
    @NSManaged var contact_mobile: String
    @NSManaged var development: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var jf_contrib: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var ministry_id: String
    @NSManaged var created_by: String
    @NSManaged var name: String
    @NSManaged var parent_id: NSNumber
    @NSManaged var security: NSNumber
    @NSManaged var size: NSNumber
    @NSManaged var start_date: String
    @NSManaged var children: NSSet
    @NSManaged var parent: Church

}
