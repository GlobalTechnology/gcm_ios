//
//  createTrainingStage.swift
//  gcmapp
//
//  Created by Jon Vellacott on 06/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
class createTrainingStage {
    
    var training_id: NSNumber!
    var phase: NSNumber!
    var date: String!
    var number_completed: NSNumber!
    
    
    init(training_id: NSNumber, phase: NSNumber, date: String, number_completed: NSNumber){
        self.training_id = training_id
        self.phase = phase
        self.date = date
        self.number_completed = number_completed
      
    }
    func toJSON() -> String{
        
        return "{\"training_id\": \(self.training_id), \"phase\": \(self.phase),\"date\": \"\(self.date)\", \"number_completed\": \(self.number_completed)}"
        
    }
    
}