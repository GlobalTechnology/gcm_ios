		//
//  training+extension.swift
//  gcmapp
//
//  Created by Jon Vellacott on 29/01/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
        

extension Training {
    
    func toJson() -> String{
//        //println("\"date\": \"\(self.date)\",")

        var rtn:String = "{"
        rtn += "\"name\": \"\(self.name)\","
        rtn += "\"mcc\": \"\(self.mcc)\","
        rtn += "\"type\": \"\(self.type)\","
        rtn += "\"ministry_id\": \"\(self.ministry_id)\","
        rtn += "\"date\": \"\(self.date)\","
        rtn += "\"longitude\": \(self.longitude.stringValue),"
        rtn += "\"latitude\": \(self.latitude.stringValue)"
        rtn += "}"
        return rtn
    }
}