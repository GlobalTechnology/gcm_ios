//
//  MCC.swift
//  gcmapp
//
//  Created by Jon Vellacott on 05/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData

class MCC: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var id: String
    @NSManaged var ministry: Ministry

}
