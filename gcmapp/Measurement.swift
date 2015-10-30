//
//  Measurement.swift
//  gcmapp
//
//  Created by Jon Vellacott on 19/01/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation


class Measurement {
    
    
    
    var measurement_type_id: String!
    var related_entity_id: String!
    var period: String!
    var mcc: String!
    var value: NSNumber!
    
    
    init(measurement_type_id: String, related_entity_id: String, period: String, mcc: String, value: NSNumber){
        self.measurement_type_id = measurement_type_id
        self.related_entity_id = related_entity_id
        self.period = period
        self.mcc = mcc
        self.value = value
    }
    
    func toJSON() -> String{
       
        return "{\"measurement_type_id\": \"\(self.measurement_type_id)\", \"related_entity_id\": \"\(self.related_entity_id)\",\"period\": \"\(self.period)\", \"mcc\":\"\(self.mcc)\", \"value\":\(self.value) }"
        
    }
    
}
