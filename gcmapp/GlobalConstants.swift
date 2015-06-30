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
    static let kShouldAddNewTrainingPhase = "ShouldAddNewTrainingPhase"
    static let kLogout = "UserWillLogout"
    static let kReset = "UserWillReset"
    static let kDidChangeChurch = "DidChangeChurch"
    static let kDidChangeTraining = "DidChangeTraining"
    static let kShouldUpdateMin = "ShouldUpdateMin"
    static let kShouldRefreshAll = "ShouldRefreshAll"
    static let kIsRefreshingToken = "IsRefreshingToken"
    static let kShouldLoadMeasurmentDetail = "ShouldLoadMeasurmentDetail"
    // these are used when an API request is started and stopped
    //   - displays can show busy indicators to indicate when an action is in progress
    static let kDidBeginMeasurementRequest = "DidBeginMeasurementRequest"
    static let kDidEndMeasurementRequest   = "DidEndMeasurementRequest"
   
    static  let SERVICE_ROOT = NSBundle.mainBundle().objectForInfoDictionaryKey("api_url") as! String
     static let SERVICE_API = SERVICE_ROOT.stringByReplacingOccurrencesOfString("192.168.0.5:8080", withString: "localhost:52195", options: NSStringCompareOptions.LiteralSearch, range: nil) + "token"
    static let LOCAL_SOURCE = "gma-app"
    static let MEMBERS_ONLY = ["leader","inherited_leader","member"]
    static let LEADERS_ONLY = ["leader","inherited_leader"]
    static let NOT_BLOCKED =  ["leader","inherited_leader","member","self_assigned"]
    
    static let RefreshInterval = 300
    static let apiSessionInvalid = "SESSION_INVALID"
    
}