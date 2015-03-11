//
//  GlobalFunctions.swift
//  gcmapp
//
//  Created by Jon Vellacott on 09/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
class GlobalFunctions{
  
    
    class func contains(value:String, list:[String]) -> Bool {
        let filtered = list.filter {$0 == value}
        return filtered.count > 0
    }
    
    class func currentPeriod() -> String{
        
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM"
            return dateFormatter.stringFromDate(NSDate())
    }
    class func currentDate() -> String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(NSDate())
    }
    
    class func convertPeriodToPrettyString(period:String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let d = dateFormatter.dateFromString(period + "-01")
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.stringFromDate(d!)
    }
    
    class func nextPeriod(current:String!) -> String {
        
        var year = (current as NSString).substringToIndex(4).toInt()
        var period = (current as NSString).substringFromIndex(5).toInt()
        if period < 12 {
            period!++
        }
        else {
            period = 1
            year!++
        }
        
        return String(format: "%04d-%02d", year!, period!)
        
       
    }
    class func prevPeriod(current:String!) -> String {
        
        var year = (current as NSString).substringToIndex(4).toInt()
        var period = (current as NSString).substringFromIndex(5).toInt()
        if period < 2 {
            period! = 12
            year!--
        }
        else {
            period!--
            
        }
        
        return String(format: "%04d-%02d", year!, period!)
        
        
        
    }
    class func getNameForDevelopment(development: NSNumber) -> String
    {
        switch(development){
           
        case 1:
            return "Target"
        case 2:
            return "Group"
        case 3:
            return "Church"
        case 5:
            return "Multiplying Church"
        default:
            return ""
        }
    }
    class func getNameForSecurity(security: NSNumber) -> String
    {
        switch(security){
        case 0:
            return "Local Private"
        case 1:
            return "Private"
        case 2:
            return "Public"
        case 3:
            return "Public"
        default:
            return security.stringValue
        }
    }
    class func getTeamRoleFormatted(team_role: String) -> String
    {
        switch(team_role){
        case "leader":
            return "Leader"
        case "inherited_leader":
            return "Inherited Leader"
        case "member":
            return "member"
        case "self_assigned":
            return "self-assigned"
        default:
            return ""
        }
    }
    
    // Calling this fn() when we don't have a ministry_id defined:
    class func joinMinistry( currentView: UIViewController) {
        
        // do we have a valid token?  (we've logged in already ...)
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String {
            
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
//            let storyboard = UIStoryboard.instantiateViewControllerWithIdentifier(<#UIStoryboard#>)
println("... token ok, so show JoinMinistryTVC")
            let storyboard = UIStoryboard(name:"Main", bundle:nil)
            if let joinMinistryTVC = storyboard.instantiateViewControllerWithIdentifier("JoinMinistryTVC") as? NewMinistryTVC {
                joinMinistryTVC.isModal = true
                currentView.presentViewController(joinMinistryTVC, animated: false, completion: nil)
            }
            
        } else {
            
println("... no token")
            // no token, so figure out if we have authorized with TheKey and either login,
        
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)

            
//            if (TheKeyOAuth2Client.sharedOAuth2Client().isAuthenticated() && TheKeyOAuth2Client.sharedOAuth2Client().guid() != nil){
//println("... postNotification: kLogin")
//                // perform login
//                let notificationCenter = NSNotificationCenter.defaultCenter()
//                notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
//                
//            }else
//            {
//println("... logout()")
//                // this sends the user to the login screen
//            //    TheKeyOAuth2Client.sharedOAuth2Client().logout()
//            }
        }

    }
    
}