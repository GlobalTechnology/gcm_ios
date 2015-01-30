//
//  GlobalFunctions.swift
//  gcmapp
//
//  Created by Jon Vellacott on 09/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
class GlobalFunctions{
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
    
}