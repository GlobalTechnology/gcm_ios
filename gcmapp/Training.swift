//
//  Training.swift
//  gcmapp
//
//  Created by Jon Vellacott on 11/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData

class Training: NSManagedObject {

    @NSManaged var date: String
    @NSManaged var id: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var mcc: String
    @NSManaged var ministry_id: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var changed: NSNumber
    @NSManaged var stages: NSSet

}
