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
    static let kShouldSaveUserPreferences = "ShouldSaveUserPreferences" // for save preferences
    static let kShouldSaveSupportStaffUserPreferences = "ShouldSaveSupportStaffUserPreferences"
    static let kShouldLoadUserPreferences = "ShouldLoadUserPreferences" // for load preferences
    static let kShouldDeleteTraining = "ShouldDeleteTraining" // for delete training
    static let kShouldDeleteChurch = "kShouldDeleteChurch" // for delete Church
    static let kDidLoadMinistryMap = "kDidLoadMinistryMap" // for delete Church
    
    static let kNoMinistrySelected = "NoMinistrySelected" // for post if there is no ministry
    static let kDrawChurchPinKey = "drawChurchPinKey" // for Draw the church pin
    static let kDrawTrainingPinKey = "drawTrainingPinKey" // for Draw the training pin
    static let kUpdatePinInforamtionKey = "updatePinInforamtionKey" // for update the pin information
    static let kLogoutNotification = "logoutNotification" // for logout
    
    static let kFromLeftMenuHomeTap = "FromLeftMenuHomeTap" // for come from left slider menu

    static let kShowTargets = "showTargets" // for show only targets
    static let kShowGroups = "showGroups" // for show only Groups
    static let kShowChurches = "showChurches" // for show only Churches
    static let kShowMultiplyingChurches = "showMultiplyingChurches" // for show only MultiplyingChurches
    static let kShowParents = "showParents" // for show only showParents
    static let kShowTraining = "showTraining" // for show only showTraining


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
    static let MEMBERS_ONLY = ["inherited_admin","admin","leader","inherited_leader","member"]
    static let LEADERS_ONLY = ["inherited_admin","admin","leader","inherited_leader"]
    static let NOT_BLOCKED =  ["inherited_admin","admin","leader","inherited_leader","member","self_assigned"]
    static let LEADERS_WITHOUT_INHERITED_ONLY = ["admin","leader"]
    static let RefreshInterval = 300
    static let apiSessionInvalid = "SESSION_INVALID"
    
}