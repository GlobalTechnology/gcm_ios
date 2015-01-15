//
//  MeasurementLocalSource.swift
//  gcmapp
//
//  Created by Jon Vellacott on 11/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData

class MeasurementLocalSource: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var value: NSNumber
    @NSManaged var changed: NSNumber
    @NSManaged var measurementValue: MeasurementValue

}
