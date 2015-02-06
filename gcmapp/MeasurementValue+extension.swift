//
//  MeasurementValue+extension.swift
//  gcmapp
//
//  Created by Jon Vellacott on 05/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData
extension MeasurementValue{

    func updateMeSource(period:String, input:JSONDictionary, managedContext:NSManagedObjectContext){
        if input["total"] != nil {
            self.me = input["total"] as NSNumber
            
        }
        if input[GlobalConstants.LOCAL_SOURCE] == nil{
            
            addMeSource(GlobalConstants.LOCAL_SOURCE, value:0 , managedContext:managedContext)
            
        }
        for (key, value) in input{
            
            if key != "total" {
                addMeSource(key, value:value as NSNumber, managedContext:managedContext)
            }
        }
        
    }
    
    func addMeSource(source: String, value: NSNumber, managedContext: NSManagedObjectContext){
        var ms:MeasurementMeSource!
        var mes = self.meSources.filteredSetUsingPredicate(NSPredicate(format: "name = %@", source)!)
        if mes.count == 0{
            let entity =  NSEntityDescription.entityForName( "MeasurementMeSource", inManagedObjectContext: managedContext)
            
            ms =  NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as MeasurementMeSource
            ms.measurementValue = self
            ms.name = source
            ms.changed = false
            ms.value = value
            
        }
        else{
            ms = mes.allObjects.first as MeasurementMeSource
            
            let ch:Bool! = ms.changed as Bool
            
            if ((source != GlobalConstants.LOCAL_SOURCE as String ) || !ch){
                 ms.value = value
                
            }
          
            
        }
       
        
    }
    func addLocalSource(source: String, value: NSNumber, managedContext: NSManagedObjectContext){
        var ls:MeasurementLocalSource!
        var lss = self.localSources.filteredSetUsingPredicate(NSPredicate(format: "name = %@", source)!)
        if lss.count == 0{
            let entity =  NSEntityDescription.entityForName( "MeasurementLocalSource", inManagedObjectContext: managedContext)
            
            ls =  NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as MeasurementLocalSource
            ls.measurementValue = self
            ls.name = source
            ls.changed = false
            ls.value = value
            
        }
        else{
            ls = lss.allObjects.first as MeasurementLocalSource
           
            let ch:Bool! = ls.changed as Bool
            
            if ((source != GlobalConstants.LOCAL_SOURCE as String ) || !ch){
                ls.value = value
                
            }
            
            
        }
        
        
    }
    
    func updateDetailFromResp(md:JSONDictionary, managedContext:NSManagedObjectContext){
        var error: NSError?
        let total = md["total"] as JSONDictionary
        let local = md["local"] as JSONDictionary
        let me = md["my_measurements"] as JSONDictionary
        let sub_min = md["sub_ministries"] as [JSONDictionary]
        let team = md["team"] as [JSONDictionary]
        let self_assigned = md["self_assigned"] as [JSONDictionary]
        let local_breakdown = md["local_breakdown"] as JSONDictionary
        let self_breakdown = md["self_breakdown"] as JSONDictionary
        println(period)
        println(total[period] as NSNumber)
        self.total = total[period] as NSNumber
        self.local = local[period] as NSNumber
        self.me = me[period] as NSNumber
        
        //Get the Sub Ministry Values
        for sm in self.subMinValues{
            managedContext.deleteObject(sm as NSManagedObject)
        }
        for t in self.teamValues{
            managedContext.deleteObject(t as NSManagedObject)
        }
        for sa in self.selfAssigned{
            managedContext.deleteObject(sa as NSManagedObject)
        }
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        for t in team{
            let entity2 =  NSEntityDescription.entityForName( "MeasurementValueTeam", inManagedObjectContext: managedContext)
            var tm = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext:managedContext) as MeasurementValueTeam
            tm.assignment_id = t["assignment_id"] as String
            tm.first_name = t["first_name"] as String
            tm.last_name = t["last_name"] as String
            tm.team_role = t["team_role"] as String
            tm.total = t["total"] as NSNumber
            tm.measurementValue = self
          
        }
        for s in sub_min{
            let entity2 =  NSEntityDescription.entityForName( "MeasurementValueSubTeam", inManagedObjectContext: managedContext)
            var sm = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext:managedContext) as MeasurementValueSubTeam
            sm.ministry_id = s["ministry_id"] as String
            sm.total = s["total"] as NSNumber
            sm.name = s["name"] as String
            sm.measurmentValue = self
           
        }
        for t in self_assigned{
            let entity2 =  NSEntityDescription.entityForName( "MeasurementValueSelfAssigned", inManagedObjectContext: managedContext)
            var tm = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext:managedContext) as MeasurementValueSelfAssigned
            tm.assignment_id = t["assignment_id"] as String
            tm.first_name = t["first_name"] as String
            tm.last_name = t["last_name"] as String
            
            tm.total = t["total"] as NSNumber
            tm.measurementValue = self
            
            
        }
        
        
        //LocalBreakdown
        
        for (key, value) in local_breakdown{
            if key != "total" {
                self.addLocalSource(key, value: value as NSNumber, managedContext: managedContext)
            }
        }
        if local_breakdown[GlobalConstants.LOCAL_SOURCE] == nil{
            
             self.addLocalSource(GlobalConstants.LOCAL_SOURCE, value:0 , managedContext:managedContext)
            
        }
        
        //SelfBreakdown
      
        for (key, value) in self_breakdown{
            if key != "total" {
                self.addMeSource(key, value: value as NSNumber, managedContext: managedContext)
            }
        }
        if self_breakdown[GlobalConstants.LOCAL_SOURCE] == nil{
            
            self.addMeSource(GlobalConstants.LOCAL_SOURCE, value:0 , managedContext:managedContext)
            
        }


        //PRevious Totals
        var p = GlobalFunctions.prevPeriod(period)
        for i in 1...5{
            var mv:MeasurementValue!
            var mvs = self.measurement.measurementValue.filteredSetUsingPredicate(NSPredicate(format: "period = %@ && mcc= %@", p, mcc)!)
            if mvs.count == 0{
                let entity =  NSEntityDescription.entityForName( "MeasurementValue", inManagedObjectContext: managedContext)
                
                mv =  NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as MeasurementValue
                mv.measurement=self.measurement
                mv.period = p
                mv.mcc = mcc
            }
            else{
                mv = mvs.allObjects.first as MeasurementValue
                
            }
            mv.total = total[p] as NSNumber
            mv.local = local[p] as NSNumber
            mv.me = me[p] as NSNumber
            
            p = GlobalFunctions.prevPeriod(p)
        }
       

        
        
        
    }
    
    
}