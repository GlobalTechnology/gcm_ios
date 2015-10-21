//
//  Training.swift
//  gcmapp
//
//  Created by Jon Vellacott on 27/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData
@objc(Training)
class Training: NSManagedObject {

    @NSManaged var changed: NSNumber
    @NSManaged var date: String
    @NSManaged var id: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var mcc: String
    @NSManaged var ministry_id: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var stages: NSSet
    @NSManaged var created_by: String

}
