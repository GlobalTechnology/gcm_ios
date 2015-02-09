//
//  Ministry+extension.swift
//  gcmapp
//
//  Created by Jon Vellacott on 09/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
extension Ministry {
    func toJson() -> String{
        var rtn:String = "{"
        rtn += "\"ministry_id\": \"\(self.id)\","
        rtn += "\"min_code\": \"\(self.min_code)\","
        
        rtn += "\"location\": {"
        rtn += "\"latitude\": \(self.latitude.stringValue),"
        rtn += "\"longitude\": \(self.longitude.stringValue)"
        
        rtn += "},"
        rtn += "\"location_zoom\": \(self.zoom)"
        
        rtn += "}"
        return rtn
    }
    
    
    
    
    
}