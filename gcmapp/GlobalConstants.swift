//
//  GlobalConstants.swift
//  gcmapp
//
//  Created by Jon Vellacott on 04/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
struct GlobalConstants {
    static let kLogin = "UserDidAuthenticate"
    static let kDidReceiveChurches = "DidReceiveChurches"
    static let kDidReceiveTraining = "DidReceiveTraining"
    static let kDidChangeAssignment = "DidChangesAssignment"
    static let kDidChangeMcc = "DidChangesMcc"
    static let kDidReceiveMeasurements = "DidReceiveMeasurements"
    static let kDidChangePeriod = "DidChangePeriod"
    static let kDidChangeTrainingCompletion = "DidChangeTrainingCompletion"
    static let kDidChangeMeasurementValues = "DidChangeMeasurementValues"
    static let kShouldJoinMinistry = "ShouldJoinMinistry"
    static let kLogout = "UserWillLogout"
    static let kReset = "UserWillReset"
    static let kDidChangeChurch = "DidChangeChurch"
    static let kDidChangeTraining = "DidChangeTraining"
    static let SERVICE_API = "https://stage.sbr.global-registry.org/api/measurements/token"
    static  let SERVICE_ROOT = "https://stage.global-registry.org/api/measurements/"
    
    static let LOCAL_SOURCE = "gcmapp"
    static let MEMBERS_ONLY = ["leader","inherited_leader","member"]
    static let LEADERS_ONLY = ["leader","inherited_leader"]
    static let NOT_BLOCKED =  ["leader","inherited_leader","member","self_assigned"]

}