//
//  MeasurementValueSubTeam.swift
//  gcmapp
//
//  Created by Jon Vellacott on 09/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData

class MeasurementValueSubTeam: NSManagedObject {

    @NSManaged var ministry_id: String
    @NSManaged var name: String
    @NSManaged var total: NSNumber
    @NSManaged var measurmentValue: GMAapp.MeasurementValue

}
