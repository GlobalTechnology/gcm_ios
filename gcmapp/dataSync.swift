//
//  dataSync.swift
//  gcmapp
//
//  Created by Jon Vellacott on 02/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData
class dataSync: NSObject {
    
    var managedContext: NSManagedObjectContext!
    var token:NSString!
    
    override init(){
        super.init()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedContext = appDelegate.managedObjectContext!
        
        let nc = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        NSUserDefaults.standardUserDefaults().setObject(GlobalFunctions.currentPeriod(), forKey: "period")
        
        if NSUserDefaults.standardUserDefaults().objectForKey("mcc") == nil{
            NSUserDefaults.standardUserDefaults().setObject("GCM", forKey: "mcc")
            
            
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        var observer_measurements = nc.addObserverForName(GlobalConstants.kDidChangePeriod, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            self.loadMeasurments(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
        }
        var observer_assignnment = nc.addObserverForName(GlobalConstants.kDidChangeAssignment, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            self.loadChurches(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String)
            self.loadTraining(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString)
            self.loadMeasurments(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as String)        }
        var observer_mcc = nc.addObserverForName(GlobalConstants.kDidChangeMcc, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            self.loadChurches(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String)
            self.loadTraining(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString)
            self.loadMeasurments(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
        }
        
        var observer_tc = nc.addObserverForName(GlobalConstants.kDidChangeTrainingCompletion, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            self.updateTrainingCompletion()
        }
        var observer_mv = nc.addObserverForName(GlobalConstants.kDidChangeMeasurementValues, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            self.updateMeasurements()
        }
        
        
        var observer = nc.addObserverForName(GlobalConstants.kLogin, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            TheKeyOAuth2Client.sharedOAuth2Client().ticketForServiceURL(NSURL(string: GlobalConstants.SERVICE_API), complete: { (ticket: String?) -> Void in
                if ticket == nil {
                    return
                }
                var s = API(st: ticket!){
                    (data: AnyObject?, error: NSError?) -> Void in
                    var resp:JSONDictionary = data as JSONDictionary
                    
                    if(resp["status"] as String == "success"){
                        self.token = resp["session_ticket"] as String
                        
                        
                        let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
                        
                        var error: NSError?
                        let allMinistries = self.managedContext.executeFetchRequest(fetchRequest,error: &error) as [Ministry]?
                        
                        var user = resp["user"] as Dictionary<String, String>
                        
                        NSUserDefaults.standardUserDefaults().setObject(user["person_id"] , forKey: "person_id")
                        let assignments=resp["assignments"] as Array<JSONDictionary>
                        let current_ass_id = NSUserDefaults.standardUserDefaults().objectForKey("assignment_id") as String?
                        var has_current_ass_id = false
                        for a:JSONDictionary in assignments{
                            
                            
                            
                            let entity =  NSEntityDescription.entityForName( "Ministry", inManagedObjectContext: self.managedContext)
                            
                            let this_min = allMinistries?.filter {$0.id == (a["ministry_id"] as String)}
                            var ministry:Ministry!
                            
                            if this_min?.count > 0{
                                ministry=this_min?.first?
                            } else {
                                
                                ministry = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:self.managedContext) as Ministry
                            }
                            
                            
                            ministry.id=a["ministry_id"] as String
                            ministry.name = a["name"] as String
                            ministry.min_code = a["min_code"] as String
                            ministry.has_slm  = a["has_slm"] as Bool
                            ministry.has_llm  = a["has_llm"] as Bool
                            ministry.has_gcm = a["has_gcm"] as Bool
                            ministry.has_ds  = a["has_ds"] as Bool
                            
                            
                            
                            
                            
                            if !self.managedContext.save(&error) {
                                println("Could not save \(error), \(error?.userInfo)")
                            }
                            
                            let entity_a =  NSEntityDescription.entityForName( "Assignment", inManagedObjectContext: self.managedContext)
                            var assignment:Assignment!
                            
                            if ministry.assignments.count>0{
                                let this_ass = ministry.assignments.filteredSetUsingPredicate(NSPredicate(format: "id = %@", a["id"] as String)!)
                                if this_ass.allObjects.count > 0{
                                    assignment=this_ass.allObjects.first as Assignment
                                } else {
                                    assignment = NSManagedObject(entity: entity_a!, insertIntoManagedObjectContext:self.managedContext) as Assignment
                                }
                            }else{
                                assignment = NSManagedObject(entity: entity_a!, insertIntoManagedObjectContext:self.managedContext) as Assignment
                            }
                            
                            assignment.id=a["id"] as String
                            assignment.team_role=a["team_role"] as String
                            assignment.person_id = user["person_id"]!
                            assignment.first_name = user["first_name"]!
                            assignment.last_name = user["last_name"]!
                            
                            assignment.ministry = ministry
                            
                            
                            if assignment.id == current_ass_id{
                                has_current_ass_id = true
                            }
                            
                            
                            
                            
                            
                            if !self.managedContext.save(&error) {
                                println("Could not save \(error), \(error?.userInfo)")
                            }
                            
                            
                            
                            
                            
                            
                            
                        }
                        if !has_current_ass_id  {
                            if  assignments.count > 0 {
                                
                                let this_ass = assignments.first!
                                
                                NSUserDefaults.standardUserDefaults().setObject(this_ass["id"] as String, forKey: "assignment_id")
                                NSUserDefaults.standardUserDefaults().setObject(this_ass["ministry_id"] as String, forKey: "ministry_id")
                                NSUserDefaults.standardUserDefaults().setObject(this_ass["name"] as String, forKey: "ministry_name")
                                
                                
                            }
                        }
                        
                        
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    
                    
                    
                    
                    self.loadChurches(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String)
                    self.loadTraining(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString)
                    self.loadMeasurments(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
                    
                }
                
                
                
            })
            
        }
        
        
    }
    func loadMeasurments(ministryId: String, mcc: String, period: String ){
        if checkTokenAndConnection() == false{
            return;
        }
        
        
        API(token: self.token).getMeasurement(ministryId, mcc: mcc, period: period) { (data: AnyObject?,error: NSError?) -> Void in
            
            if data == nil {
                
                return;
            }
            
            let fetchRequest =  NSFetchRequest(entityName:"Measurements" )
            fetchRequest.predicate = NSPredicate(format: "ministry_id = %@", ministryId )
            
            var error: NSError?
            let meas = self.managedContext.executeFetchRequest(fetchRequest,error: &error) as [Measurements]?
            /* for m in meas!{
            self.managedContext.deleteObject(m)
            }*/
            
            for m in data as JSONArray{
                
                for (myKey,myValue) in m as JSONDictionary {
                    println("\(myKey) \t \(myValue)")
                }
                
                
                let entity =  NSEntityDescription.entityForName( "Measurements", inManagedObjectContext: self.managedContext)
                
                let this_meas = meas?.filter {$0.id == (m["measurement_id"] as String)}
                var measurement:Measurements!
                var getDetail:Bool = false
                
                
                if this_meas?.count > 0{
                    measurement=this_meas?.first?
                    let this_period_local = measurement.measurementValue.filteredSetUsingPredicate(NSPredicate(format: "period = %@", period)!)
                    if this_period_local.count>0{
                        
                        if (this_period_local.allObjects.first! as MeasurementValue).total != m["total"] as NSNumber{
                            getDetail = true
                        }
                       
                        
                    }
                    
                    
                } else {
                    
                    measurement = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:self.managedContext) as Measurements
                    getDetail = true
                }
                
                measurement.name = m["name"] as String
                measurement.id = m["measurement_id"] as String
                measurement.perm_link = m["perm_link"] as String
                measurement.section = m["section"] as String
                measurement.column = m["column"] as String
                measurement.ministry_id = ministryId
                if !self.managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
                if(getDetail){
                    self.getMeasurementDetail(measurement, measurementId: measurement.id, ministryId: ministryId, mcc: mcc, period: period)
                    
                }
                
                /*for pv in m["measurements"] as JSONArray{
                
                //Get Measurement Detail (async)
                
                
                
                
                
                
                
                
                
                
                
                
                
                if !self.managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
                }
                
                
                
                
                }*/
                
                
                
            }
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidReceiveMeasurements, object: nil)
            
            
        }
    }
    func getMeasurementDetail(measurement: Measurements,  measurementId: String, ministryId: String, mcc: String, period: String){
        if checkTokenAndConnection() == false{
            return;
        }
        
        API(token: self.token).getMeasurementDetail(measurementId, ministryId: ministryId, mcc: mcc, period: period){
            (data: AnyObject?,error: NSError?) -> Void in
            if data == nil {
                return
            }
            if let md = data as? JSONDictionary{
                var error: NSError?
                
                
                measurement.id_total = (md["measurement_type_ids"] as JSONDictionary)["total"] as String
                measurement.id_local = (md["measurement_type_ids"] as JSONDictionary)["local"] as String
                measurement.id_person = (md["measurement_type_ids"] as JSONDictionary)["person"] as String
                let total = md["total"] as JSONDictionary
                let local = md["local"] as JSONDictionary
                let me = md["my_measurements"] as JSONDictionary
                let sub_min = md["sub_ministries"] as [JSONDictionary]
                let team = md["team"] as [JSONDictionary]
                let self_assigned = md["self_assigned"] as [JSONDictionary]
                let local_breakdown = md["local_breakdown"] as JSONDictionary
                var this_period_value =  self.createPeriodValue(measurement, ministryId: ministryId, mcc: mcc, period: period, total: total[period] as NSNumber, local: local[period] as NSNumber, me: me[period] as NSNumber)
                
                
                //Get the Sub Ministry Values
                for sm in this_period_value.subMinValues{
                    self.managedContext.deleteObject(sm as NSManagedObject)
                }
                for t in this_period_value.teamValues{
                    self.managedContext.deleteObject(t as NSManagedObject)
                }
                for sa in this_period_value.selfAssigned{
                    self.managedContext.deleteObject(sa as NSManagedObject)
                }
                if !self.managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
                
                for t in team{
                    let entity2 =  NSEntityDescription.entityForName( "MeasurementValueTeam", inManagedObjectContext: self.managedContext)
                    var tm = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext:self.managedContext) as MeasurementValueTeam
                    tm.assignment_id = t["assignment_id"] as String
                    tm.first_name = t["first_name"] as String
                    tm.last_name = t["last_name"] as String
                    tm.team_role = t["team_role"] as String
                    tm.total = t["total"] as NSNumber
                    tm.measurementValue = this_period_value
                    if !self.managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                }
                for s in sub_min{
                    let entity2 =  NSEntityDescription.entityForName( "MeasurementValueSubTeam", inManagedObjectContext: self.managedContext)
                    var sm = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext:self.managedContext) as MeasurementValueSubTeam
                    sm.ministry_id = s["ministry_id"] as String
                    sm.total = s["total"] as NSNumber
                    sm.name = s["name"] as String
                    sm.measurmentValue = this_period_value
                    if !self.managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                }
                for t in self_assigned{
                    let entity2 =  NSEntityDescription.entityForName( "MeasurementValueSelfAssigned", inManagedObjectContext: self.managedContext)
                    var tm = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext:self.managedContext) as MeasurementValueSelfAssigned
                    tm.assignment_id = t["assignment_id"] as String
                    tm.first_name = t["first_name"] as String
                    tm.last_name = t["last_name"] as String
                    
                    tm.total = t["total"] as NSNumber
                    tm.measurementValue = this_period_value
                    if !self.managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    
                }
                var found:Bool = false
                for (key, value) in local_breakdown{
                    if(key == GlobalConstants.LOCAL_SOURCE){
                        found = true
                        //don't erase changed value
                        
                    }
                    if key != "total" {
                        let entity2 =  NSEntityDescription.entityForName( "MeasurementLocalSource", inManagedObjectContext: self.managedContext)
                        var lb = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext:self.managedContext) as MeasurementLocalSource
                        lb.name = key as String
                        lb.value = value as NSNumber
                        
                        lb.measurementValue = this_period_value
                        if !self.managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
                        }
                    }
                    
                }
                
                if !found{
                    //dont erase changed value
                    
                    let entity2 =  NSEntityDescription.entityForName( "MeasurementLocalSource", inManagedObjectContext: self.managedContext)
                    var lb = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext:self.managedContext) as MeasurementLocalSource
                    lb.name = GlobalConstants.LOCAL_SOURCE
                    lb.value = 0
                    
                    lb.measurementValue = this_period_value
                    if !self.managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    
                }
                
                
                //get other period values for past 6 months (for graph)
                var p = GlobalFunctions.prevPeriod(period)
                for i in 1...5{
                    var period_value = self.createPeriodValue(measurement,  ministryId: ministryId, mcc: mcc, period: p, total: total[p] as NSNumber, local: local[p] as NSNumber, me: me[p] as NSNumber)
                    
                    p = GlobalFunctions.prevPeriod(p)
                }
                if !self.managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
                
            }
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidReceiveMeasurements, object: nil)
        }
        
    }
    
    
    func createPeriodValue(measurement: Measurements, ministryId: String, mcc: String, period: String, total: NSNumber, local: NSNumber, me: NSNumber) -> MeasurementValue{
        var error: NSError?
        //Don't erase changed value...
        
        
        if measurement.measurementValue.allObjects.count>0 {
            let this_meas_value =  (measurement.measurementValue.allObjects as [MeasurementValue]).filter {$0.period == period && $0.mcc==mcc}
            if this_meas_value.count>0{
                managedContext.deleteObject(this_meas_value.first!)
                
                if !self.managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
            }
            
        }
        
        
        let entity2 =  NSEntityDescription.entityForName( "MeasurementValue", inManagedObjectContext: self.managedContext)
        var period_value:MeasurementValue! = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext:self.managedContext) as MeasurementValue
        
        
        period_value.mcc = mcc
        period_value.period = period
        period_value.total = total
        if local.stringValue == ""{
            period_value.local=0
        }
        else{
            period_value.local = local
        }
        
        
        
        
        if(!period_value.changed.boolValue){
            period_value.me = me
        }
        
        
        period_value.measurement = measurement
        if !self.managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        return period_value
    }
    
    func loadTraining(ministryId: String, mcc: String){
        if checkTokenAndConnection() == false{
            return;
        }
        API(token: self.token).getTraining(ministryId, mcc: mcc){
            (data: AnyObject?,error: NSError?) -> Void in
            if data == nil {
                return
            }
            
            
            let fetchRequest =  NSFetchRequest(entityName:"Training" )
            fetchRequest.predicate=NSPredicate(format: "ministry_id = %@ AND mcc = %@", ministryId, mcc )
            //fetchRequest.predicate=NSPredicate(format: "ministry_id = %@", ministryId)
            
            
            var error: NSError?
            let allTraining = self.managedContext.executeFetchRequest(fetchRequest,error: &error) as [Training]
            
            for t in data as JSONArray{
                //BEGIN: Add or update
                let this_t = allTraining.filter {$0.id == (t["id"] as NSNumber)}
                var training:Training!
                
                if this_t.count > 0{
                    training=this_t.first?
                    
                } else {
                    let entity =  NSEntityDescription.entityForName( "Training", inManagedObjectContext: self.managedContext)
                    training = NSManagedObject(entity: entity!,
                        insertIntoManagedObjectContext:self.managedContext) as Training
                }
                //END: ADD or Update
                if !(training.changed as Bool) { // don't update if we have a pending change...
                    training.id = t["id"] as NSNumber
                    training.ministry_id = t["ministry_id"] as String
                    training.name = t["name"] as String
                    if t["date"] as String? != nil{
                        training.date  = t["date"] as String
                    }
                    if t["type"] as String? != nil{
                        training.type = t["type"] as String
                    }
                    
                    if t["latitude"] as Float? != nil{
                        training.latitude   = t["latitude"] as Float
                    }
                    if t["longitude"] as Float? != nil{
                        training.longitude = t["longitude"] as Float
                    }
                    training.ministry_id = ministryId
                    training.mcc=mcc
                }
                
                if t["gcm_training_completions"] as Array<JSONDictionary>? != nil{
                    if ((t["gcm_training_completions"] as Array<JSONDictionary>).count > 0){
                        let allTC = training.stages.allObjects as [TrainingCompletion]
                        
                        
                        
                        for tc in t["gcm_training_completions"] as Array<JSONDictionary>{
                            
                            //BEGIN: Add or update
                            var training_comp:TrainingCompletion!
                            let this_tc = allTC.filter {$0.id == (tc["id"] as NSNumber)}
                            if this_tc.count > 0{
                                training_comp=this_tc.first?
                                
                            } else {
                                let entity2 =  NSEntityDescription.entityForName( "TrainingCompletion", inManagedObjectContext: self.managedContext)
                                training_comp = NSManagedObject(entity: entity2!,
                                    insertIntoManagedObjectContext:self.managedContext) as TrainingCompletion
                            }
                            //END: Add or Update
                            if !(training_comp.changed as Bool) { //don't update if we have a pending value
                                training_comp.id = tc["id"] as NSNumber
                                training_comp.phase = tc["phase"] as NSNumber
                                training_comp.number_completed = tc["number_completed"] as NSNumber
                                if(tc["date"] as String? != nil){
                                    training_comp.date = tc["date"] as String
                                }
                                training_comp.training = training
                                
                            }
                        }
                    }
                }
                
            }
            if !self.managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidReceiveTraining, object: nil)
        }
        
    }
    
    func loadChurches(ministryId: String) {
        if self.checkTokenAndConnection() == false{
            return;
        }
        //   api.st = service_ticket
        API(token: self.token).getChurches(ministryId){
            (data: AnyObject?,error: NSError?) -> Void in
            
            
            
            let fetchRequest =  NSFetchRequest(entityName:"Church" )
            fetchRequest.predicate=NSPredicate(format: "ministry_id = %@" , ministryId)
            
            var error: NSError?
            let churches = self.managedContext.executeFetchRequest(fetchRequest,error: &error) as [Church]
            
            
            
            
            var relationships = Dictionary<NSNumber, NSNumber>()
            
            for c in data as JSONArray{
                //BEGIN: Add or update
                
                let this_ch = churches.filter {$0.id == (c["id"] as NSNumber)}
                var church:Church!
                
                if this_ch.count > 0{
                    church=this_ch.first?
                    
                } else {
                    let entity =  NSEntityDescription.entityForName( "Church", inManagedObjectContext: self.managedContext)
                    church = NSManagedObject(entity: entity!,
                        insertIntoManagedObjectContext:self.managedContext) as Church
                }
                //END: Add or update
                if !(church.changed as Bool) {//don't update if we have a pending change
                    
                    
                    
                    
                    church.id = c["id"] as NSNumber
                    church.name = c["name"] as String
                    church.development = c["development"] as NSNumber
                    church.size = c["size"] as NSNumber
                    church.latitude = c["latitude"] as Float
                    church.longitude = c["longitude"] as Float
                    church.security = c["security"] as NSNumber
                    church.contact_name = c["contact_name"] as String
                    church.contact_email = c["contact_email"] as String
                    church.ministry_id = c["ministry_id"] as String
                    if (c["parents"] as Array<NSNumber>).count  > 0 {
                        church.parent_id = (c["parents"] as Array<NSNumber>)[0]
                        relationships[church.parent_id] = church.id
                    }
                    
                    church.jf_contrib = c["jf_contrib"] as Bool
                    
                    
                    // if(contains(c.allKeys as [String],"parent_id")) {church.setValue(c["parent_id"], forKey: "parent_id")}
                    
                    
                    
                    
                    
                    
                    
                    if !self.managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    
                }
                
            }
            
            
            let fetchedResults2 = self.managedContext.executeFetchRequest(fetchRequest,error: &error) as [Church]?
            if let churches = fetchedResults2 {
                for r in relationships{
                    let c1 = churches.filter{$0.id == r.0} as [Church]
                    let c2 = churches.filter{$0.id == r.1} as [Church]
                    if c1.count>0 && c2.count>0{
                        c2[0].parent=c1[0]
                    }
                    
                }
                
                
            }
            
            
            if !self.managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidReceiveChurches, object: nil)
            
            
            
        }
        
        
    }
    func checkTokenAndConnection() -> Bool {
        
        switch (self.token? != nil, Reachability.isConnectedToNetwork()){
        case (false, false):
            return  false //Offline
            
        case (true,false):
            return  false //Offline, but has token
            
        case (false, true):
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
            return false //Conntect, but not logged in will reauthenticate (which will refetch - so return false)
        case (true, true):
            return true
        default:
            return false
        }
        
    }
    
    
    func updateTrainingCompletion(){
        if self.checkTokenAndConnection() == false{
            return;
        }
        var error: NSError?
        let frTrainingCompletion =  NSFetchRequest(entityName:"TrainingCompletion" )
        let pred = NSPredicate(format: "changed == true" )
        frTrainingCompletion.predicate=pred
        let tc_changed = self.managedContext.executeFetchRequest(frTrainingCompletion,error: &error) as [TrainingCompletion]
        for tc in tc_changed{
            API(token: self.token).saveTrainingCompletion(tc){
                (data: AnyObject?,error: NSError?) -> Void in
                if data != nil{
                    if (data as Bool){
                        tc.changed=false
                        var error: NSError?
                        if !self.managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
                        }
                    }
                }
            }
        }
        
        
    }
    func updateMeasurements(){
        if self.checkTokenAndConnection() == false{
            return;
        }
        
        var error: NSError?
        
        //Get My Staff Measurements that have changed
        let frMeasurementValue =  NSFetchRequest(entityName:"MeasurementValue" )
        let pred = NSPredicate(format: "changed == true" )
        frMeasurementValue.predicate=pred
        let mv_changed = self.managedContext.executeFetchRequest(frMeasurementValue,error: &error) as [MeasurementValue]
        var update_values: Array<Measurement> = []
        for mv in mv_changed{
            update_values.append(Measurement(measurement_type_id: mv.measurement.id_person, related_entity_id: NSUserDefaults.standardUserDefaults().objectForKey("assignment_id") as String , period: mv.period, mcc: mv.mcc, value: mv.me))
        }
        
        
        //Get local source measurmenets that I have changed
        let frMeasurementLocalValue =  NSFetchRequest(entityName:"MeasurementLocalSource" )
        frMeasurementLocalValue.predicate=pred
        let mlv_changed = self.managedContext.executeFetchRequest(frMeasurementLocalValue,error: &error) as [MeasurementLocalSource]
        
        for mlv in mlv_changed{
            println(mlv.measurementValue.measurement.id_local)
            println(mlv.measurementValue.period)
            println(mlv.measurementValue.mcc)
            
            update_values.append(Measurement(measurement_type_id: mlv.measurementValue.measurement.id_local, related_entity_id: NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String  , period: mlv.measurementValue.period, mcc: mlv.measurementValue.mcc + "_gcmapp", value: mlv.value))
        }
        if(update_values.count > 0){
            
            API(token: self.token).saveMeasurement(update_values ){
                (data: AnyObject?,error: NSError?) -> Void in
                if data != nil{
                    if (data as Bool){
                        //   tc.changed=false
                        for mv in mv_changed{
                            mv.changed = false
                            
                        }
                        for mv in mlv_changed{
                            mv.changed = false
                            
                        }
                        var error: NSError?
                        if !self.managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
                        }
                    }
                }
            }
        }
        
        
    }
    
    func savePendingTransactions( ){
        var error: NSError?
        let frTraining =  NSFetchRequest(entityName:"Training")
        let frTrainingCompletion =  NSFetchRequest(entityName:"TrainingCompletion" )
        let frChurch =  NSFetchRequest(entityName:"Church" )
        let frMeasurementValue =  NSFetchRequest(entityName:"MeasurementValue" )
        let frMeasurementLocalSource =  NSFetchRequest(entityName:"MeasurementLocalSource" )
        
        let pred = NSPredicate(format: "changed == true" )
        frTraining.predicate=pred
        frTrainingCompletion.predicate=pred
        frChurch.predicate=pred
        frMeasurementValue.predicate = pred
        frMeasurementLocalSource.predicate = pred
        
        let t = self.managedContext.executeFetchRequest(frTraining,error: &error) as [Training]
        let tc = self.managedContext.executeFetchRequest(frTrainingCompletion,error: &error) as [TrainingCompletion]
        let c = self.managedContext.executeFetchRequest(frChurch,error: &error) as [Church]
        let mv = self.managedContext.executeFetchRequest(frMeasurementValue,error: &error) as [MeasurementValue]
        let mls = self.managedContext.executeFetchRequest(frMeasurementLocalSource,error: &error) as [MeasurementLocalSource]
        
        for church in c{
            
            
            //if id is nil, it is a new row so create
            
            
            //else update
            
            
            //if successfull, set changed = false and run callback
            
        }
        
        
        
    }
    
    
    
}