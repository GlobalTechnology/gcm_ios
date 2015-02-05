//
//  MeasurementMeSource.swift
//  gcmapp
//
//  Created by Jon Vellacott on 05/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData

class MeasurementMeSource: NSManagedObject {

    @NSManaged var changed: NSNumber
    @NSManaged var source: String
    @NSManaged var value: NSNumber
    @NSManaged var measurementValue: MeasurementValue

}
