//
//  measurements+extension.swift
//  gcmapp
//
//  Created by Jon Vellacott on 03/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData
extension Measurements {
    func sortOrder() -> NSNumber{
        switch(self.section.lowercaseString){
        case "win":
            return 0
        case "build":
            return 1
        case "send":
            return 2
        default:
            return 3
        }
        
    }
    func updateMeasurementFromResponse(m: JSONDictionary,ministry_id:String,period:String,mcc:String, managedContext:NSManagedObjectContext) -> Bool {
        var error: NSError?
        var rtn:Bool = false
        self.name = m["name"] as String
        self.id = m["measurement_id"] as String
        self.perm_link = m["perm_link"] as String
        self.section = m["section"] as String
        self.sort_order = self.sortOrder()
        self.column = m["column"] as String
        self.ministry_id = ministry_id
        
        var mv:MeasurementValue!
//        if self.measurementValue.count == 0 {
//            
//            let entity =  NSEntityDescription.entityForName( "MeasurementValue", inManagedObjectContext: managedContext)
//            
//            mv =  NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as MeasurementValue
//            mv.measurement=self
//            mv.period = period
//            mv.mcc = mcc
//            rtn=m["total"] != nil
//            
//        } else {
        
        
            var mvs = self.measurementValue.filteredSetUsingPredicate(NSPredicate(format: "period = %@ && mcc= %@", period, mcc)!)

            if mvs.count == 0{
                let entity =  NSEntityDescription.entityForName( "MeasurementValue", inManagedObjectContext: managedContext)
                
                mv =  NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as MeasurementValue
                mv.measurement=self
                mv.period = period
                mv.mcc = mcc
                rtn=m["total"] != nil
            }
            else{
                mv = mvs.allObjects.first as MeasurementValue
                
            }
//        }
        var ids = m["measurement_type_ids"] as JSONDictionary
        
        if ids["total"] != nil {
            self.id_total = (ids["total"] as String)
        }
        if ids["local"] != nil {
            self.id_local = ids["local"] as String
        }
        if ids["person"] != nil {
            self.id_person = ids["person"] as String
        }
        
        
    
            
        if m["total"] != nil{
            if mv.total != m["total"] as NSNumber{
                rtn = true
                mv.total = m["total"] as NSNumber
                println(mv.total)
            }
        }
        else if m["my_values"] != nil{
            mv.updateMeSource(period, input: m["my_values"] as JSONDictionary, managedContext: managedContext)
        }
        
        
        if m["person_measurement_type_id"] != nil{
            self.id_person = m["person_measurement_type_id"]  as String
        }
        
        
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        
        
        return rtn
    }
    func updateMeasurementDetailFromResponse(md: JSONDictionary,ministry_id:String,period:String,mcc:String, managedContext:NSManagedObjectContext) {
        self.id_total = (md["measurement_type_ids"] as JSONDictionary)["total"] as String
        self.id_local = (md["measurement_type_ids"] as JSONDictionary)["local"] as String
        self.id_person = (md["measurement_type_ids"] as JSONDictionary)["person"] as String
        
        
        
        var error: NSError?
        //Get or Create MeasurementValue
        var mv:MeasurementValue!
        var mvs = self.measurementValue.filteredSetUsingPredicate(NSPredicate(format: "period = %@ && mcc= %@", period, mcc)!)

        if mvs.count == 0{
            let entity =  NSEntityDescription.entityForName( "MeasurementValue", inManagedObjectContext: managedContext)
            
            mv =  NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as MeasurementValue
            mv.measurement=self
            mv.period = period
            mv.mcc = mcc
        }
        else{
            mv = mvs.allObjects.first as MeasurementValue
            
        }
     
        
        //Process the details
        mv.updateDetailFromResp(md, managedContext: managedContext)
        
        
        
        
        
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
       
    }
    
    
}