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
    
}