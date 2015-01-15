//
//  Ministry.swift
//  gcmapp
//
//  Created by Jon Vellacott on 10/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
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
    @NSManaged var assignments: NSSet
    @NSManaged var children: NSSet
    @NSManaged var mccs: NSSet
    @NSManaged var parent: Ministry

}
