//
//  MeasurementSettings.swift
//  gcmapp
//
//  Created by Justin Mohit on 08/10/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//


import Foundation
import CoreData
@objc(MeasurementSettings)
class MeasurementSettings: NSManagedObject {
    
    @NSManaged var perm_link: String
    @NSManaged var status: NSNumber
    
}
