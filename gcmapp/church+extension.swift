//
//  church+extension.swift
//  gcmapp
//
//  Created by Jon Vellacott on 29/01/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
extension Church {
    func toJson() -> String{
        var rtn:String = "{"
        rtn += "\"ministry_id\": \"\(self.ministry_id)\","
        rtn += "\"name\": \"\(self.name)\","
        rtn += "\"contact_name\": \"\(self.contact_name)\","
        rtn += "\"contact_email\": \"\(self.contact_email)\","
        rtn += "\"contact_mobile\": \"\(self.contact_mobile)\","
        rtn += "\"size\": \(self.size.stringValue),"
        rtn += "\"development\": \(self.development.stringValue),"
        rtn += "\"security\": \(self.security.stringValue),"
        if self.parent_id as NSNumber? != nil{
            rtn += "\"parent_id\": \(self.parent_id.stringValue),"
        }
        rtn += "\"longitude\": \(self.longitude.stringValue),"
        rtn += "\"latitude\": \(self.latitude.stringValue)"
        
        rtn += "}"
        return rtn
    }
    
    
  
    
    
}