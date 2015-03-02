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
    let myQueue = NSOperationQueue()
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
        var observer_measurements = nc.addObserverForName(GlobalConstants.kDidChangePeriod, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.loadMeasurments(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
        }
        var observer_assignnment = nc.addObserverForName(GlobalConstants.kDidChangeAssignment, object: nil, queue: myQueue) {(notification:NSNotification!) in
            
            //update team role
            let ass = Assignment.getAssignmentForMinistryId(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String) as Assignment?
            var team_role:String = "self_assigned"
            if ass != nil{
                team_role = ass!.team_role
            }
            
            NSUserDefaults.standardUserDefaults().setObject(team_role, forKey: "team_role")
            
            self.loadChurches(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String)
            self.loadTraining(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString)
            self.loadMeasurments(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
             NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "last_refresh")
             NSUserDefaults.standardUserDefaults().synchronize()
        }
       
        var observer_mcc = nc.addObserverForName(GlobalConstants.kDidChangeMcc, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.loadChurches(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String)
            self.loadTraining(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString)
            self.loadMeasurments(NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
             NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "last_refresh")
             NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        
        
        var observer_tc = nc.addObserverForName(GlobalConstants.kDidChangeTrainingCompletion, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.updateTrainingCompletion()
        }
        var observer_mv = nc.addObserverForName(GlobalConstants.kDidChangeMeasurementValues, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.updateMeasurements()
        }
        var observer_ch = nc.addObserverForName(GlobalConstants.kDidChangeChurch, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.updateChurch()
        }
        var observer_tr = nc.addObserverForName(GlobalConstants.kDidChangeTraining, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.updateTraining()
        }
        var observer_logout = nc.addObserverForName(GlobalConstants.kLogout, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.logout()
        }
        var observer_reset = nc.addObserverForName(GlobalConstants.kReset, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.reset()
        }
        var observer_join = nc.addObserverForName(GlobalConstants.kShouldJoinMinistry, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.joinMinistry((notification.userInfo as JSONDictionary)["ministry_id"] as String, sender: notification.object as NewMinistryTVC)
        }
        var observer_new_tc = nc.addObserverForName(GlobalConstants.kShouldAddNewTrainingPhase, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.addTrainingStage((notification.userInfo as JSONDictionary)["createTrainingStage"] as createTrainingStage,sender: notification.object as trainingViewController)
        }
        var observer_update_min = nc.addObserverForName(GlobalConstants.kShouldUpdateMin, object: nil, queue: myQueue) {(notification:NSNotification!) in
            self.updateMinistry((notification.userInfo as JSONDictionary)["ministry"] as Ministry)
        }
        
        var observer = nc.addObserverForName(GlobalConstants.kLogin, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            if !(TheKeyOAuth2Client.sharedOAuth2Client().isAuthenticated() && TheKeyOAuth2Client.sharedOAuth2Client().guid() != nil){
            
                TheKeyOAuth2Client.sharedOAuth2Client().logout()
            }
            
            
            
            TheKeyOAuth2Client.sharedOAuth2Client().ticketForServiceURL(NSURL(string: GlobalConstants.SERVICE_API), complete: { (ticket: String?) -> Void in
                if ticket == nil {
                    return
                }
                
                var s = API(st: ticket!){
                    (data: AnyObject?, error: NSError?) -> Void in
                    if data == nil{
                        return
                    }

                    var resp:JSONDictionary = data as JSONDictionary
                    
                    if(resp["status"] as String == "success"){
                        self.token = resp["session_ticket"] as String
                        
                        NSUserDefaults.standardUserDefaults().setObject(self.token, forKey: "token")
                        let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kIsRefreshingToken)
                        
                        var error: NSError?
                        let allMinistries = self.managedContext.executeFetchRequest(fetchRequest,error: &error) as [Ministry]?
                        
                        var user = resp["user"] as Dictionary<String, String>
                        
                        NSUserDefaults.standardUserDefaults().setObject(user["person_id"] , forKey: "person_id")
                        NSUserDefaults.standardUserDefaults().setObject(user["first_name"] , forKey: "first_name")
                        NSUserDefaults.standardUserDefaults().setObject(user["last_name"] , forKey: "last_name")
                        NSUserDefaults.standardUserDefaults().setObject(user["cas_username"] , forKey: "cas_username")
                        
                        let assignments=resp["assignments"] as Array<JSONDictionary>
                        let current_ass_id = NSUserDefaults.standardUserDefaults().objectForKey("assignment_id") as String?
                        var has_current_ass_id = false
                        for a:JSONDictionary in assignments{
                            
                            
                            
                            if(self.addAssignment(a , user: user,  allMinistries: (allMinistries)) == current_ass_id){
                                has_current_ass_id  = true
                                NSUserDefaults.standardUserDefaults().setObject(a["team_role"] as String, forKey: "team_role")
                                NSUserDefaults.standardUserDefaults().setObject(a["ministry_id"] as String, forKey: "ministry_id")
                                NSUserDefaults.standardUserDefaults().setObject(a["name"] as String, forKey: "ministry_name")
                            }
                            
                            
                            
                            
                            
                            
                        }
                        if !has_current_ass_id  {
                            if  assignments.count > 0 {
                                
                                let this_ass = assignments.first!
                                
                                
                                
                                
                                
                                NSUserDefaults.standardUserDefaults().setObject(this_ass["team_role"] as String, forKey: "team_role")
                                
                                
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
                     NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "last_refresh")
                     NSUserDefaults.standardUserDefaults().synchronize()
                    
                }
                
                
                
            })
            
        }
        var observer_refresh = nc.addObserverForName(GlobalConstants.kShouldRefreshAll, object: nil, queue: myQueue) {(notification:NSNotification!) in
            if self.token==nil{
                let notificationCenter = NSNotificationCenter.defaultCenter()
               // notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
                return;
            }
            if NSUserDefaults.standardUserDefaults().objectForKey("last_refresh") != nil{
                var last_update=NSUserDefaults.standardUserDefaults().objectForKey("last_refresh") as NSDate
                if (-(last_update.timeIntervalSinceNow)  < (NSTimeInterval(GlobalConstants.RefreshInterval))){
                    return;
                }
                		
                
            }
            var ministry_id = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String?
            if ministry_id != nil{
                
            
            self.updateChurch()
            self.updateMeasurements()
            self.updateTraining()
            self.updateTrainingCompletion()
            
            
            self.loadChurches(ministry_id!)
            self.loadTraining(ministry_id!, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString)
            self.loadMeasurments(ministry_id!, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "last_refresh")
            NSUserDefaults.standardUserDefaults().synchronize()
            }
            
        }

        
        
    }
    func addAssignment(a:JSONDictionary, user:Dictionary<String, String>, allMinistries:[Ministry]?) -> String{
        
        var error: NSError?
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
        
        if a["location"] != nil{
            var loc = a["location"] as JSONDictionary
            ministry.longitude = loc["longitude"] as NSNumber
            
            ministry.latitude = loc["latitude"]  as NSNumber
            
        }
        if a["location_zoom"] != nil{
            ministry.zoom = a["location_zoom"] as NSNumber
        }
        
        
        
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
        
        
        
        
        
        
        
        
        if !self.managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        //if assignment.id == current_ass_id{
        //    has_current_ass_id = true
        //}
        return assignment.id
    }
    
    
    func loadMeasurments(ministryId: String, mcc: String, period: String ){
        if checkTokenAndConnection() == false{
            return;
        }
     
        if !GlobalFunctions.contains( NSUserDefaults.standardUserDefaults().objectForKey("team_role") as String, list: GlobalConstants.NOT_BLOCKED){
            return
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
                
                /*for (myKey,myValue) in m as JSONDictionary {
                    println("\(myKey) \t \(myValue)")
                }*/
                
                
              println( m["name"])
                
                
                
                let entity =  NSEntityDescription.entityForName( "Measurements", inManagedObjectContext: self.managedContext)
                
                let this_meas = meas?.filter {$0.id == (m["measurement_id"] as String)}
                var measurement:Measurements!
                var getDetail:Bool = false
                
                
                if this_meas?.count > 0{
                    measurement=this_meas?.first?
                    
                    
                } else {
                    
                    measurement = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:self.managedContext) as Measurements
                    getDetail = true
                }
                
                var should_update_detail:Bool = measurement.updateMeasurementFromResponse(m as JSONDictionary, ministry_id: ministryId, period: period,mcc: mcc, managedContext: self.managedContext)
                
                
                if should_update_detail{
                    API(token: self.token).getMeasurementDetail(measurement.id, ministryId: ministryId, mcc: mcc, period: period){
                        (data: AnyObject?,error: NSError?) -> Void in
                        if data == nil {
                            return
                        }
                        if let md = data as? JSONDictionary{
                            measurement.updateMeasurementDetailFromResponse(md, ministry_id: ministryId, period: period, mcc: mcc, managedContext: self.managedContext)
                            
                            let notificationCenter = NSNotificationCenter.defaultCenter()
                            notificationCenter.postNotificationName(GlobalConstants.kDidReceiveMeasurements, object: nil)
                        }
                    }
                }
                
                
            }
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidReceiveMeasurements, object: nil)
            
            
        }
    }
    
    
    func loadTraining(ministryId: String, mcc: String){
        if checkTokenAndConnection() == false{
            return;
        }
        if !GlobalFunctions.contains( NSUserDefaults.standardUserDefaults().objectForKey("team_role") as String, list: GlobalConstants.MEMBERS_ONLY){
            return
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
                //println(t);
                // var tmp = t["latitude"]
                // println(tmp)
                
                
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
                    if t["date"] as String? != NSNull(){
                        training.date  = t["date"] as String
                    }
                    if !(t["type"]  is NSNull){
                        training.type = t["type"] as String
                    }
                    else{
                        training.type=""
                    }
                    
                    if !(t["latitude"]   is NSNull)   {
                        
                        training.latitude   = t["latitude"] as Float
                    }
                    if !(t["longitude"]   is NSNull) {
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
        
        if !GlobalFunctions.contains( NSUserDefaults.standardUserDefaults().objectForKey("team_role") as String, list: GlobalConstants.NOT_BLOCKED){
            return
        }
        
        //   api.st = service_ticket
        API(token: self.token).getChurches(ministryId){
            (data: AnyObject?,error: NSError?) -> Void in
            
            if data != nil {
            
            let fetchRequest =  NSFetchRequest(entityName:"Church" )
            fetchRequest.predicate=NSPredicate(format: "ministry_id = %@" , ministryId)
            
            var error: NSError?
            let churches = self.managedContext.executeFetchRequest(fetchRequest,error: &error) as [Church]
            
            
            
            
            var relationships = Dictionary<NSNumber, NSNumber>()
            
            for c in data as JSONArray{
                //BEGIN: Add or update
                
                //println(c["id"])
                
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
                    if c["latitude"] != nil && c["longitude"]  != nil{
                        church.latitude = c["latitude"] as Float
                        church.longitude = c["longitude"] as Float
                    }
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
        
        
    }
    func checkTokenAndConnection() -> Bool {
        
        switch (self.token? != nil && self.token != "", Reachability.isConnectedToNetwork()){
        case (false, false):
            return  false //Offline
            
        case (true,false):
            return  false //Offline, but has token
            
        case (false, true):
            if !(TheKeyOAuth2Client.sharedOAuth2Client().isAuthenticated() && TheKeyOAuth2Client.sharedOAuth2Client().guid() != nil){
                
                TheKeyOAuth2Client.sharedOAuth2Client().logout()
            }

          //  let notificationCenter = NSNotificationCenter.defaultCenter()
           // notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
            return false //Conntect, but not logged in will reauthenticate (which will refetch - so return false)
        case (true, true):
            return true
        default:
            return false
        }
        
    }
    
    
    func updateChurch(){
        if self.checkTokenAndConnection() == false{
            return;
        }
        var error: NSError?
        let frChurch =  NSFetchRequest(entityName:"Church" )
        let pred = NSPredicate(format: "changed == true" )
        frChurch.predicate=pred
        let ch_changed = self.managedContext.executeFetchRequest(frChurch,error: &error) as [Church]
        for ch in ch_changed{
            
            if ch.id == -1{
                API(token: self.token).addChurch(ch){
                    (data: AnyObject?,error: NSError?) -> Void in
                    if data != nil{
                        ch.changed=false
                        ch.id=(data as JSONDictionary)["id"]  as NSNumber
                        println("saved: \(ch.id)")
                        var error: NSError?
                        if !self.managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
                        }
                        
                    }
                }
                
                
            }
            else{
                API(token: self.token).saveChurch(ch){
                    (data: AnyObject?,error: NSError?) -> Void in
                    if data != nil{
                        if (data as Bool){
                            ch.changed=false
                            var error: NSError?
                            if !self.managedContext.save(&error) {
                                println("Could not save \(error), \(error?.userInfo)")
                            }
                        }
                    }
                }
            }
            
        }
        
        
    }
    
    func updateTraining(){
        if self.checkTokenAndConnection() == false{
            return;
        }
        var error: NSError?
        let frTraining =  NSFetchRequest(entityName:"Training" )
        let pred = NSPredicate(format: "changed == true" )
        frTraining.predicate=pred
        let tr_changed = self.managedContext.executeFetchRequest(frTraining,error: &error) as [Training]
        for tr in tr_changed{
            if tr.id == -1{
                API(token: self.token).addTraining(tr){
                    (data: AnyObject?,error: NSError?) -> Void in
                    if data != nil{
                        tr.changed=false
                        tr.id=(data as JSONDictionary)["id"]  as NSNumber
                        println("saved: \(tr.id)")
                        var error: NSError?
                        if !self.managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
                        }
                        
                    }
                }
                
                
            }
            else{
                
                API(token: self.token).saveTraining(tr){(data: AnyObject?,error: NSError?) -> Void in
                    if data != nil{
                        if (data as Bool){
                            tr.changed=false
                            var error: NSError?
                            if !self.managedContext.save(&error) {
                                println("Could not save \(error), \(error?.userInfo)")
                            }
                        }
                    }
                }
            }
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
        //var mcc:String = NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String
        //Get My Staff Measurements that have changed
        let frMeasurementValue =  NSFetchRequest(entityName:"MeasurementMeSource" )
        let pred = NSPredicate(format: "changed == true" )
        frMeasurementValue.predicate=pred
        let mv_changed = self.managedContext.executeFetchRequest(frMeasurementValue,error: &error) as [MeasurementMeSource]
        var update_values: Array<Measurement> = []
        for mv in mv_changed{
            update_values.append(Measurement(measurement_type_id: mv.measurementValue.measurement.id_person, related_entity_id: NSUserDefaults.standardUserDefaults().objectForKey("assignment_id") as String , period: mv.measurementValue.period, mcc: mv.measurementValue.mcc + "_" + GlobalConstants.LOCAL_SOURCE, value: mv.value))
        }
        
        
        //Get local source measurmenets that I have changed
        let frMeasurementLocalValue =  NSFetchRequest(entityName:"MeasurementLocalSource" )
        frMeasurementLocalValue.predicate=pred
        let mlv_changed = self.managedContext.executeFetchRequest(frMeasurementLocalValue,error: &error) as [MeasurementLocalSource]
        
        for mlv in mlv_changed{
            println(mlv.measurementValue.measurement.id_local)
            println(mlv.measurementValue.period)
            println(mlv.measurementValue.mcc)
            
            update_values.append(Measurement(measurement_type_id: mlv.measurementValue.measurement.id_local, related_entity_id: NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String  , period: mlv.measurementValue.period, mcc: mlv.measurementValue.mcc + "_" + GlobalConstants.LOCAL_SOURCE, value: mlv.value))
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
                        //now update the measurements
                        self.loadMeasurments( NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String, mcc:  (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString, period: (NSUserDefaults.standardUserDefaults().objectForKey("period") as String))
                        
                        
                        
                    }
                }
            }
        }
        
        
    }
    
    /*func savePendingTransactions( ){
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
    
    
    
    }*/
    
    func addTrainingStage(insert:createTrainingStage, sender: trainingViewController){
        API(token: token).addTrainingCompletion(insert){
            (data: AnyObject?,error: NSError?) -> Void in
            if data != nil{
                let tc:JSONDictionary = data as JSONDictionary
                var error: NSError?
                //get Training
                let fr =  NSFetchRequest(entityName:"Training" )
                fr.predicate = NSPredicate(format: "id == %@", insert.training_id )
               
                let tr = self.managedContext.executeFetchRequest(fr,error: &error) as [Training]
                if tr.count>0{
                    
                    let allTC = tr.first!.stages.allObjects as [TrainingCompletion]
                    
                    var training_comp:TrainingCompletion!
                    let this_tc = allTC.filter {$0.id == (tc["Id"] as NSNumber)}
                    if this_tc.count > 0{
                        training_comp=this_tc.first?
                        
                    } else {
                        let entity2 =  NSEntityDescription.entityForName( "TrainingCompletion", inManagedObjectContext: self.managedContext)
                        training_comp = NSManagedObject(entity: entity2!,
                            insertIntoManagedObjectContext:self.managedContext) as TrainingCompletion
                    }
                    //END: Add or Update
                        training_comp.id = tc["Id"] as NSNumber
                        training_comp.phase = tc["phase"] as NSNumber
                        training_comp.number_completed = tc["number_completed"] as NSNumber
                        if(tc["date"] as String? != nil){
                            training_comp.date = tc["date"] as String
                        }
                        training_comp.training = tr.first!
                        
                    
                    if !self.managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    sender.tc.append(training_comp)
                    sender.tableView.reloadData()
                    let notificationCenter = NSNotificationCenter.defaultCenter()
                    notificationCenter.postNotificationName(GlobalConstants.kDidReceiveTraining, object: nil)
                   
                }
                
                
                
                
                
                
               
            }
        }
    }
    
    
    func updateMinistry(ministry: Ministry){
        
            API(token: token).updateMinistry(ministry){
                (data: AnyObject?,error: NSError?) -> Void in
                //Nothing to do...
                
            }

        

    }
    
    func joinMinistry(ministry_id: String, sender: NewMinistryTVC){
        println(ministry_id)
        API(token: token).addAssignment( NSUserDefaults.standardUserDefaults().objectForKey("cas_username") as String , ministry_id: ministry_id, team_role: "self_assigned"){
            (data: AnyObject?,error: NSError?) -> Void in
            if data != nil{
                let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
                
                var error: NSError?
                let allMinistries = self.managedContext.executeFetchRequest(fetchRequest,error: &error) as [Ministry]?
                
                var user = Dictionary<String, String>()
                user["person_id"] = NSUserDefaults.standardUserDefaults().objectForKey("person_id") as? String
                user["first_name"] = NSUserDefaults.standardUserDefaults().objectForKey("first_name") as? String
                user["last_name"] = NSUserDefaults.standardUserDefaults().objectForKey("last_name") as? String
                self.addAssignment(data as JSONDictionary, user: user, allMinistries: allMinistries)
            }
            
        }
        //sender.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reset(){
        var error: NSError?
        let entityList=["MCC", "Assignment", "Ministry", "Church", "TrainingCompletion", "Training","MeasurementLocalSource", "MeasurementValueSubTeam", "MeasurementValueSelfAssigned", "MeasurementValueTeam", "MeasurementValue", "Measurements"]
        for e in entityList{
            let fr =  NSFetchRequest(entityName:e)
            let items = self.managedContext.executeFetchRequest(fr,error: &error) as Array<NSManagedObject>
            for obj in items {
                
                self.managedContext.deleteObject(obj)
            }
            
        }
        if !self.managedContext.save(&error) {
            println("Could not delete objects \(error), \(error?.userInfo)")
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        
        if self.token != nil{
             notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
        }
        else{
            TheKeyOAuth2Client.sharedOAuth2Client().logout()

            
          //  notificationCenter.postNotificationName(GlobalConstants.kDidReceiveChurches, object: nil)
           
          //  notificationCenter.postNotificationName(GlobalConstants.kDidReceiveMeasurements, object: nil)
        }
        
    }
    func logout(){
       
        API(token: self.token).deleteToken()
       
        self.token = nil
        
        //Delete everything in the database
        reset()
    }
}