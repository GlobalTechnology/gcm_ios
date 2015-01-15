//
//  MeasurementValueSubTeam.swift
//  gcmapp
//
//  Created by Jon Vellacott on 10/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData

class MeasurementValueSubTeam: NSManagedObject {

    @NSManaged var ministry_id: String
    @NSManaged var total: NSNumber
    @NSManaged var name: String
    @NSManaged var measurmentValue: MeasurementValue

}
