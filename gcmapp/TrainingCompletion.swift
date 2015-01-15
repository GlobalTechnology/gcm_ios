//
//  TrainingCompletion.swift
//  gcmapp
//
//  Created by Jon Vellacott on 11/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData

class TrainingCompletion: NSManagedObject {

    @NSManaged var date: String
    @NSManaged var id: NSNumber
    @NSManaged var number_completed: NSNumber
    @NSManaged var phase: NSNumber
    @NSManaged var changed: NSNumber
    @NSManaged var training: Training

}
