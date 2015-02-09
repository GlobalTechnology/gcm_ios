//
//  Ministry.swift
//  gcmapp
//
//  Created by Jon Vellacott on 09/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData

class Ministry: NSManagedObject {

    @NSManaged var has_ds: NSNumber
    @NSManaged var has_gcm: NSNumber
    @NSManaged var has_llm: NSNumber
    @NSManaged var has_slm: NSNumber
    @NSManaged var id: String
    @NSManaged var min_code: String
    @NSManaged var name: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var zoom: NSNumber
    @NSManaged var assignments: NSSet
    @NSManaged var children: NSSet
    @NSManaged var mccs: NSSet
    @NSManaged var parent: Ministry

}
