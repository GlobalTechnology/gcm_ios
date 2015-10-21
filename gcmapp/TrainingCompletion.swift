//
//  TrainingCompletion.swift
//  gcmapp
//
//  Created by Jon Vellacott on 27/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData
@objc(TrainingCompletion)
class TrainingCompletion: NSManagedObject {

    @NSManaged var changed: NSNumber
    @NSManaged var date: String
    @NSManaged var id: NSNumber
    @NSManaged var number_completed: NSNumber
    @NSManaged var phase: NSNumber
    @NSManaged var training: Training

}
