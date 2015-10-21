//
//  MCC.swift
//  gcmapp
//
//  Created by Jon Vellacott on 27/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData
@objc(MCC)
class MCC: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var ministry: Ministry

}
