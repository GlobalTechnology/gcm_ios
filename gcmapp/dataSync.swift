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
    
    //var managedContext: NSManagedObjectContext!
    var token:NSString!
    var saving:Bool = false
    // let tracker = GAI.sharedInstance().defaultTracker

    private let notificationManager = NotificationManager()  // manage notification

    override init(){
        super.init()
        
        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        self.managedContext = appDelegate.managedObjectContext!

        NSUserDefaults.standardUserDefaults().setObject(GlobalFunctions.currentPeriod(), forKey: "period")
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("mcc") != nil) {
            
        }
        else {
            
            NSUserDefaults.standardUserDefaults().setObject("GCM", forKey: "mcc")
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
      
        //observer_measurements
        notificationManager.registerObserver(GlobalConstants.kDidChangePeriod, forObject: nil) { note  in
            
            if let ministryID = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String {
                
                
                self.loadMeasurments(ministryID, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as! String)
                
            } else {
                
                //// TODO: what happens here?
                //println("Notification:kDidChangePeriod:");
                //println("... still don't have a ministry ID assigned");
            }
        }
        
        // observer Change Assignment
        
        notificationManager.registerObserver(GlobalConstants.kDidChangeAssignment, forObject: nil) { note  in
            //println("...caught kDidChangeAssignment")
            
             //println(note)
            
            let queue = NSOperationQueue()
            
            queue.addOperationWithBlock() {
                // do something in the background
                if let ministryID = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String {
                    //println("... kDidChangeAssignment:  ministryID[\(ministryID)] ")
                    //update team role
                    
                    let ass = Assignment.getAssignmentForMinistryId(ministryID) as Assignment?
                    var team_role:String = "self_assigned"
                    if ass != nil{
                        team_role = ass!.team_role
                    }
                    
                    NSUserDefaults.standardUserDefaults().setObject(team_role, forKey: "team_role")
                    
                    self.loadChurches(ministryID)
                    self.loadTraining(ministryID, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString)
                    self.loadMeasurments(ministryID, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as! String)
                    //load previous period too
                    self.loadMeasurments(ministryID, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString, period: GlobalFunctions.prevPeriod( NSUserDefaults.standardUserDefaults().objectForKey("period") as! String))
                    NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "last_refresh")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                } else {
                    
                    //// TODO: what should happen here?
                    //println("dataSync: kDidChangeAssignment ")
                    //println("... called when there was no ministry_id defined")
                    
                }
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    // when done, update your UI and/or model on the main queue
                }
            }
            
            
                  
        }
        
        //observer_mcc
        
        notificationManager.registerObserver(GlobalConstants.kDidChangeMcc, forObject: nil) { note  in
            
            
            
            let queue = NSOperationQueue()
            
            queue.addOperationWithBlock() {
                // do something in the background
                if let ministryID = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String {
                    
                    let currMcc = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString
                    
                    self.loadChurches(ministryID)
                    self.loadTraining(ministryID, mcc:currMcc )
                    self.loadMeasurments(ministryID, mcc: currMcc, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as! String)
                    NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "last_refresh")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                } else {
                    
                    //// TODO: so what should really happen if this was called?
                    //println("dataSync: Notification: kDidChangeMcc:")
                    //println("... attempted to update Mcc change when user doesn't have a ministry_id")
                    
                }
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    // when done, update your UI and/or model on the main queue
                }
            }
        }
        
        // observer_tc
        notificationManager.registerObserver(GlobalConstants.kDidChangeTrainingCompletion, forObject: nil) { note in
            self.updateTrainingCompletion()
        }
        
        //observer_mv
        notificationManager.registerObserver(GlobalConstants.kDidChangeMeasurementValues, forObject: nil) { note in
                
            if !self.saving{
                
            let queue = NSOperationQueue()
            queue.addOperationWithBlock() {
                // do something in the background
                self.saving=false
                self.updateMeasurements()
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    // when done, update your UI and/or model on the main queue
                }
            }
            
        }
        
        }
        
        //observer_ch
        notificationManager.registerObserver(GlobalConstants.kDidChangeChurch, forObject: nil) { note in
            self.updateChurch()
        }
        //observer_tr
        notificationManager.registerObserver(GlobalConstants.kDidChangeTraining, forObject: nil) { note in
            self.updateTraining()
        
        }
       
        //logout observer
        notificationManager.registerObserver(GlobalConstants.kLogout, forObject: nil){ note in
            
            self.logout()
        }
        //observer_reset
        notificationManager.registerObserver(GlobalConstants.kReset, forObject: nil){ note in
            self.reset()
        }
        
        //observer_join
        notificationManager.registerObserver(GlobalConstants.kShouldJoinMinistry, forObject: nil){ note in
            self.joinMinistry((note.userInfo as! JSONDictionary)["ministry_id"] as! String, sender: note.object as! NewMinistryTVC)
        }
        
        //observer_new_tc
        notificationManager.registerObserver(GlobalConstants.kShouldAddNewTrainingPhase, forObject: nil){ note in
            self.addTrainingStage((note.userInfo as! JSONDictionary)["createTrainingStage"] as! createTrainingStage,sender: note.object as! trainingViewController)
        }
        
        //observer_update_min
        notificationManager.registerObserver(GlobalConstants.kShouldUpdateMin, forObject: nil){ note in
       
            self.updateMinistry((note.userInfo as! JSONDictionary)["ministry"] as! Ministry)
        }
        
        // observer_saveUserPreferences
        notificationManager.registerObserver(GlobalConstants.kShouldSaveUserPreferences, forObject: nil){ note in
            
            var mapInfo : NSDictionary = note.userInfo as! JSONDictionary
            self.saveUser_preferences(mapInfo)
            
        }
        
        // observer_saveSupprotStaffUserPreferences
        notificationManager.registerObserver(GlobalConstants.kShouldSaveSupportStaffUserPreferences, forObject: nil){ note in
            
            var mapInfo : NSDictionary = note.userInfo as! JSONDictionary
            self.saveSupportStaff_User_preferences(mapInfo)
            
        }
        

        //observer_load_meas_det
        notificationManager.registerObserver(GlobalConstants.kShouldLoadMeasurmentDetail, forObject: nil){ note in
            self.loadMeasurmentDetails(note.userInfo?.values.first as! Measurements , ministryId: NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period")  as! String, sender: note.object as! measurementDetailViewController)
        }
        
        //observer login
        notificationManager.registerObserver(GlobalConstants.kLogin, forObject: nil){ note in
            
            if !(TheKeyOAuth2Client.sharedOAuth2Client().isAuthenticated() && TheKeyOAuth2Client.sharedOAuth2Client().guid() != nil){
                //println("... kLogin: .logout()")
                TheKeyOAuth2Client.sharedOAuth2Client().logout()
                return;
            }
            
        // On kLogin -> Authorize the client
            
        TheKeyOAuth2Client.sharedOAuth2Client().ticketForServiceURL(NSURL(string: GlobalConstants.SERVICE_API), complete: { (ticket: String?) -> Void in
                if ticket == nil {
                    //println("... ticketForService() : ticket == nil!")
                    //TheKeyOAuth2Client.sharedOAuth2Client().logout()
                    return
                }
                else{
                    if(NSUserDefaults.standardUserDefaults().boolForKey("hitOnlyOnce") as Bool == false){
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hitOnlyOnce")
                    }
                    else{
                        return
                    }
            }
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
                
                moc?.performBlockAndWait({ () -> Void in
                    
                    var s = API(st: ticket!){
                        (data: AnyObject?, error: NSError?) -> Void in
                        if data == nil{
                            return
                        }
                        var resp:JSONDictionary = data as! JSONDictionary
                        
                        if(resp["status"] as! String == "success"){
                            
                            
                            // println(resp)
                            
                            
                            var dic : JSONDictionary = resp["user_preferences"] as! JSONDictionary
                            
                            if dic.indexForKey("supported_staff") != nil {

                                // now val is not nil and the Optional has been unwrapped, so use it
                                
                                    if dic["supported_staff"]! as! String == "1" {
                                        
                                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SupprotedStaffSwichKey")
                                    }
                                    else{
                                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "SupprotedStaffSwichKey")
                                    }
                                    

                                }
                                
                            

                            
                            
                            //println("This is run on the main queue, after the previous code in outer block")
                            
                            self.token = resp["session_ticket"] as! String
                            
                            NSUserDefaults.standardUserDefaults().setObject(self.token, forKey: "token")
                            let notificationCenter = NSNotificationCenter.defaultCenter()
                            notificationCenter.postNotificationName(GlobalConstants.kShouldLoadUserPreferences, object: nil)  // call for get userpreference by justin
                            let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
                            NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kIsRefreshingToken)
                            
                            var error: NSError?
                            let allMinistries = moc!.executeFetchRequest(fetchRequest,error: &error) as! [Ministry]?
                            
                            var user = resp["user"] as! Dictionary<String, String>
                            
                            NSUserDefaults.standardUserDefaults().setObject(user["person_id"] , forKey: "person_id")
                            NSUserDefaults.standardUserDefaults().setObject(user["first_name"] , forKey: "first_name")
                            NSUserDefaults.standardUserDefaults().setObject(user["last_name"] , forKey: "last_name")
                            NSUserDefaults.standardUserDefaults().setObject(user["cas_username"] , forKey: "cas_username")
                            
                            
                            var has_current_ass_id = false  // do we have any assignments ?
                            
                            // if assignments were provided in the response
                            if let assignments=resp["assignments"] as? Array<JSONDictionary> {
                                
                                let current_ass_id = NSUserDefaults.standardUserDefaults().objectForKey("assignment_id") as! String?
                                //println(assignments.count)
                                for a:JSONDictionary in assignments{
                                    
                                    
                                    if(self.addAssignment(a , user: user,  allMinistries: (allMinistries)) == current_ass_id){
                                        has_current_ass_id  = true
                                        NSUserDefaults.standardUserDefaults().setObject(a["team_role"] as! String, forKey: "team_role")
                                        NSUserDefaults.standardUserDefaults().setObject(a["ministry_id"] as! String, forKey: "ministry_id")
                                        NSUserDefaults.standardUserDefaults().setObject(a["name"] as! String, forKey: "ministry_name")
                                    }
                                    
                                }
                                if !has_current_ass_id  {
                                    if  assignments.count > 0 {
                                        
                                        let this_ass = assignments.first!
                                        NSUserDefaults.standardUserDefaults().setObject(this_ass["team_role"] as! String, forKey: "team_role")
                                        NSUserDefaults.standardUserDefaults().setObject(this_ass["id"] as! String, forKey: "assignment_id")
                                        NSUserDefaults.standardUserDefaults().setObject(this_ass["ministry_id"] as! String, forKey: "ministry_id")
                                        NSUserDefaults.standardUserDefaults().setObject(this_ass["name"] as! String, forKey: "ministry_name")
                                        
                                    }
                                }
                                
                            } else {
                                
                                // TODO: what happens if user is not attached to any assignments?
                                //println(" *** Hey, you are not assigned to anything! *** ")
                                
                            } // end if assignments were provided
                            
                            NSUserDefaults.standardUserDefaults().synchronize()
                            // if we we have a saved ministry_id then initialize our
                            // churches, training and measurements
                            if let currMinistryID = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String? {
                                
                                //  let currMCC = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString
                                //
                                //let currPeriod = NSUserDefaults.standardUserDefaults().objectForKey("period") as! String
                                //   temp block
                                NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kDidChangeAssignment, object: nil)
                                // self.loadChurches(currMinistryID)
                                // self.loadTraining(currMinistryID, mcc:currMCC)
                                // self.loadMeasurments(currMinistryID, mcc: currMCC, period: currPeriod)
                            }
                            
                            // update our last refresh setting:
                            //NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "last_refresh")
                            //NSUserDefaults.standardUserDefaults().synchronize()
                            
                        } // end if response was a success
                        
                    }  // end API{}
                
                })
                
            })
            
        }
        
     // for refress All
       notificationManager.registerObserver(GlobalConstants.kShouldRefreshAll, forObject: nil) { note in
        
       
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            //println("This is run on the background queue")
            
            if self.token==nil{
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
                return;
            }
            
            if NSUserDefaults.standardUserDefaults().objectForKey("last_refresh") != nil{
                var last_update=NSUserDefaults.standardUserDefaults().objectForKey("last_refresh") as! NSDate
                if (-(last_update.timeIntervalSinceNow)  < (NSTimeInterval(GlobalConstants.RefreshInterval))){
                    return;
                }
            }
            
            var ministry_id = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String?
            if ministry_id != nil{
                
                
                self.updateChurch()
                self.updateMeasurements()
                self.updateTraining()
                self.updateTrainingCompletion()
                
                self.loadChurches(ministry_id!)
                self.loadTraining(ministry_id!, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString)
                self.loadMeasurments(ministry_id!, mcc: (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString, period: NSUserDefaults.standardUserDefaults().objectForKey("period") as! String)
                NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "last_refresh")
                NSUserDefaults.standardUserDefaults().synchronize()
                
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //main Queque

    })
})

    }
        
    } // end init and resisterd all observers
    
    func addAssignment(a:JSONDictionary, user:Dictionary<String, String>, allMinistries:[Ministry]?) -> String?{
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        var newList = allMinistries
        var error: NSError?
        let entity =  NSEntityDescription.entityForName( "Ministry", inManagedObjectContext: moc!)
        
        let this_min = allMinistries?.filter {$0.id == (a["ministry_id"] as! String)}
        var ministry:Ministry!
        
        if this_min?.count > 0{
            ministry=this_min?.first
        } else {
            
            ministry = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:moc!) as! Ministry
        }
        
        
        ministry.id=a["ministry_id"] as! String
        ministry.name = a["name"] as! String
        ministry.min_code = a["min_code"] as! String
        
        
        //refactor to use array
        
        let mccs:Array<String> = a["mccs"] as! Array<String>
        
        ministry.has_slm  =   contains(mccs , "slm")
        ministry.has_llm  = contains(mccs , "llm")
        ministry.has_gcm = contains(mccs , "gcm")
        ministry.has_ds  = contains(mccs , "ds")
        
        if a["location"] != nil{
            var loc = a["location"] as! JSONDictionary
            ministry.longitude = loc["longitude"] as! NSNumber
            
            ministry.latitude = loc["latitude"]  as! NSNumber
            
        }
        if a["location_zoom"] != nil{
            ministry.zoom = a["location_zoom"] as! NSNumber
        }
        
        newList!.append(ministry)
        
        if !moc!.save(&error) {
            //println("Could not save \(error), \(error?.userInfo)")
        }
        
        let entity_a =  NSEntityDescription.entityForName( "Assignment", inManagedObjectContext: moc!)
        var assignment:Assignment!
        //if (a["id"] != nil) {
        if ministry.assignments.count>0 {
            var this_ass :NSSet!
            if a["id"] != nil {
                this_ass = ministry.assignments.filteredSetUsingPredicate(NSPredicate(format: "id = %@", a["id"] as! String))
                if this_ass.allObjects.count > 0{
                    assignment=this_ass.allObjects.first as! Assignment
                } else {
                    assignment = NSManagedObject(entity: entity_a!, insertIntoManagedObjectContext:moc!) as! Assignment
                    assignment.id=(a["id"] as! String)
                }
            } else {
                assignment = ministry.assignments.allObjects.first as! Assignment
            }
        }else{
            
            assignment = NSManagedObject(entity: entity_a!, insertIntoManagedObjectContext:moc!) as! Assignment
            if a["id"] != nil {
                assignment.id=(a["id"] as! String)
            }
        }
        
        
        
        
        assignment.team_role=a["team_role"] as! String
        assignment.person_id = user["person_id"]!
        assignment.first_name = user["first_name"]!
        assignment.last_name = user["last_name"]!
        
        assignment.ministry = ministry
        
        appDelegate.saveContext()
        
//        if !moc!.save(&error) {
//            //println("Could not save \(error), \(error?.userInfo)")
//        }
        
        //}
        
        //if assignment.id == current_ass_id{
        //    has_current_ass_id = true
        //}
        
       
        if a["sub_ministries"] != nil {
        for row in a["sub_ministries"] as! Array<JSONDictionary> {
        
            // self.addAssignment(row, user: user, allMinistries: newList)
            
        }
        }
       
        
        if (a["id"] != nil) {
            return assignment.id
        } else {
            return nil
        }
    }
    
    func loadMeasurmentDetails(measurement: Measurements, ministryId: String, mcc: String, period: String, sender: measurementDetailViewController ){
        if checkTokenAndConnection() == false{
            return;
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({
            
        
            // Do heavy or time consuming work
        
            if measurement.id == nil {
                
                
                var alertController = UIAlertController(title: "", message: "No chart data available.", preferredStyle: .Alert)
                
                // Create the actions
                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    
                    sender.dismissViewControllerAnimated(true, completion: nil)
                }
                
                // Add the actions
                alertController.addAction(okAction)
                
                // Present the controller
                sender.presentViewController(alertController, animated: true, completion: nil)
                
                
                //println("error: \(self.measurement!.name)")
                return;
            }
            
                API(token: self.token! as String).getMeasurementDetail(measurement.id!, ministryId: ministryId, mcc: mcc, period: period){
                    (data: AnyObject?,error: NSError?) -> Void in
                    if data == nil {
                        return
                    }
                    if let md = data as? JSONDictionary{
                        measurement.updateMeasurementDetailFromResponse(md, ministry_id: ministryId, period: period, mcc: mcc, managedContext: moc!)
                        
                        //let notificationCenter = NSNotificationCenter.defaultCenter()
                        
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "reloadMeasurementDetailTblOnce")
                        
                        dispatch_async(dispatch_get_main_queue()){
                                sender.tableView.reloadData()
                                sender.activity.hidden = true
                            }
                        
                        //notificationCenter.postNotificationName(GlobalConstants.kDidReceiveMeasurements, object: nil)
                        
                        
                    }
                }
        
        })
     

    }
    
    func loadMeasurments(ministryId: String, mcc: String, period: String ){
        if checkTokenAndConnection() == false{
            return;
        }
        
            // signal we are beginning a request:
            NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kDidBeginMeasurementRequest, object: nil)
            
            if !GlobalFunctions.contains( NSUserDefaults.standardUserDefaults().objectForKey("team_role") as! String, list: GlobalConstants.NOT_BLOCKED){
                return
            }
            
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({
            
            // Do heavy or time consuming work
            
            API(token: self.token! as String).getMeasurement(ministryId, mcc: mcc, period: period) { (data: AnyObject?,error: NSError?) -> Void in
                
                if data == nil {
                    
                    // signal our Request Ended
                    NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kDidEndMeasurementRequest, object: nil)
                    
                    return;
                }
                
                
                let fetchRequest =  NSFetchRequest(entityName:"Measurements" )
                fetchRequest.predicate = NSPredicate(format: "ministry_id = %@", ministryId )
                
                var error: NSError?
                let meas = moc!.executeFetchRequest(fetchRequest,error: &error) as! [Measurements]?
                /* for m in meas!{
                self.managedContext.deleteObject(m)
                }*/
                
                for m in data as! JSONArray{
                    
                    for (myKey,myValue) in m as! JSONDictionary {
                        //println("\(myKey) \t \(myValue)")
                    }
                    
                    
                    //println( m["name"])
                    
                    
                    
                    let entity =  NSEntityDescription.entityForName( "Measurements", inManagedObjectContext: moc!)
                    
                    let this_meas = meas?.filter {$0.perm_link == (m["perm_link"] as! String)}
                    var measurement:Measurements!
                    var getDetail:Bool = false
                    
                    
                    if this_meas?.count > 0{
                        measurement=this_meas?.first
                        
                        
                    } else {
                        
                        measurement = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:moc!) as! Measurements
                        getDetail = true
                    }
                    
                    var should_update_detail:Bool = measurement.updateMeasurementFromResponse(m as! JSONDictionary, ministry_id: ministryId, period: period,mcc: mcc, managedContext: moc!)
                    
                    
                    //                    if should_update_detail && false {
                    //                        dispatch_async(self.myQueue,{
                    //                            API(token: self.token).getMeasurementDetail(measurement.id, ministryId: ministryId, mcc: mcc, period: period){
                    //                                (data: AnyObject?,error: NSError?) -> Void in
                    //                                if data == nil {
                    //                                    return
                    //                                }
                    //                                if let md = data as? JSONDictionary{
                    //                                    dispatch_async(dispatch_get_main_queue(),{
                    //                                        measurement.updateMeasurementDetailFromResponse(md, ministry_id: ministryId, period: period, mcc: mcc, managedContext: self.managedContext)
                    //
                    //                                        let notificationCenter = NSNotificationCenter.defaultCenter()
                    //                                        notificationCenter.postNotificationName(GlobalConstants.kDidReceiveMeasurements, object: nil)
                    //                                    });
                    //                                }
                    //                            }
                    //                        });
                    //                    }
                    
                    
                }
                
                // signal our Request Ended
                NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kDidEndMeasurementRequest, object: nil)
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kDidReceiveMeasurements, object: nil)
            }

        })
        
        
       
    
    }
    
    func loadTraining(ministryId: String, mcc: String){
        
        if checkTokenAndConnection() == false{
            return;
        }
        
        if !GlobalFunctions.contains( NSUserDefaults.standardUserDefaults().objectForKey("team_role") as! String, list: GlobalConstants.MEMBERS_ONLY){
            return
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({

            // Do heavy or time consuming work
            API(token: self.token! as String).getTraining(ministryId, mcc: mcc){
                (data: AnyObject?,error: NSError?) -> Void in
                if data == nil {
                    return
                }
                
                
                let fetchRequest =  NSFetchRequest(entityName:"Training" )
                fetchRequest.predicate=NSPredicate(format: "ministry_id = %@ AND mcc = %@", ministryId, mcc )
                //fetchRequest.predicate=NSPredicate(format: "ministry_id = %@", ministryId)
                
                
                var error: NSError?
                let allTraining = moc!.executeFetchRequest(fetchRequest,error: &error) as! [Training]
                
                for t in data as! JSONArray{
                    //BEGIN: Add or update
                    ////println(t);
                    // var tmp = t["latitude"]
                    // //println(tmp)
                    
                    
                    let this_t = allTraining.filter {$0.id == (t["id"] as! NSNumber)}
                    var training:Training!
                    
                    if this_t.count > 0{
                        training=this_t.first
                        
                    } else {
                        let entity =  NSEntityDescription.entityForName( "Training", inManagedObjectContext: moc!)
                        training = NSManagedObject(entity: entity!,
                            insertIntoManagedObjectContext:moc!) as! Training
                    }
                    //END: ADD or Update
                    if !(training.changed as Bool) { // don't update if we have a pending change...
                        training.id = t["id"] as! NSNumber
                        training.ministry_id = t["ministry_id"] as! String
                        training.name = t["name"] as! String
                        if t["date"] as! String? != NSNull(){
                            training.date  = t["date"] as! String
                        }
                        if !(t["type"]  is NSNull){
                            training.type = t["type"] as! String
                        }
                        else{
                            training.type=" "
                        }
                        
                        if !(t["latitude"]   is NSNull)   {
                            
                            training.latitude   = t["latitude"] as! Float
                        }
                        if !(t["longitude"]   is NSNull) {
                            training.longitude = t["longitude"] as! Float
                        }
                        training.ministry_id = ministryId
                        training.mcc=mcc
                    }
                    
                    if t["gcm_training_completions"] as! Array<JSONDictionary>? != nil{
                        if ((t["gcm_training_completions"] as! Array<JSONDictionary>).count > 0){
                            let allTC = training.stages.allObjects as! [TrainingCompletion]
                            
                            for tc in t["gcm_training_completions"] as! Array<JSONDictionary>{
                                
                                //BEGIN: Add or update
                                var training_comp:TrainingCompletion!
                                let this_tc = allTC.filter {$0.id == (tc["id"] as! NSNumber)}
                                if this_tc.count > 0{
                                    training_comp=this_tc.first
                                    
                                } else {
                                    let entity2 =  NSEntityDescription.entityForName( "TrainingCompletion", inManagedObjectContext: moc!)
                                    training_comp = NSManagedObject(entity: entity2!,
                                        insertIntoManagedObjectContext:moc!) as! TrainingCompletion
                                }
                                //END: Add or Update
                                if !(training_comp.changed as Bool) { //don't update if we have a pending value
                                    training_comp.id = tc["id"] as! NSNumber
                                    training_comp.phase = tc["phase"] as! NSNumber
                                    training_comp.number_completed = tc["number_completed"] as! NSNumber
                                    if(tc["date"] as! String? != nil){
                                        training_comp.date = tc["date"] as! String
                                    }
                                    training_comp.training = training
                                    
                                }
                            }
                        }
                    }
                }
//                if !moc!.save(&error) {
//                    //println("Could not save \(error), \(error?.userInfo)")
//                }
                
                appDelegate.saveContext()
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kDidReceiveTraining, object: nil)
                
                
            }
            
        })
        
    
    }
    
    func loadChurches(ministryId: String) {
        if self.checkTokenAndConnection() == false{
            return;
        }
        
        if !GlobalFunctions.contains( NSUserDefaults.standardUserDefaults().objectForKey("team_role") as! String, list: GlobalConstants.NOT_BLOCKED){
            return
        }
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({

       
            // Do heavy or time consuming work
            API(token: self.token! as String).getChurches(ministryId){
                (data: AnyObject?,error: NSError?) -> Void in
                
                if data != nil {
                    let fetchRequest =  NSFetchRequest(entityName:"Church" )
                    fetchRequest.predicate=NSPredicate(format: "ministry_id = %@" , ministryId)
                    
                    var error: NSError?
                    let churches = moc!.executeFetchRequest(fetchRequest,error: &error) as! [Church]
                    
                    var relationships = Dictionary<NSNumber, NSNumber>()
                    
                    for c in data as! JSONArray{
                        //BEGIN: Add or update
                        
                        ////println(c["id"])
                        
                        let this_ch = churches.filter {$0.id == (c["id"] as! NSNumber)}
                        var church:Church!
                        
                        if this_ch.count > 0{
                            church=this_ch.first
                            
                        } else {
                            let entity =  NSEntityDescription.entityForName( "Church", inManagedObjectContext: appDelegate.backgroundContext!)
                            church = NSManagedObject(entity: entity!,
                                insertIntoManagedObjectContext:moc!) as! Church
                        }
                        
                        //END: Add or update
                        if !(church.changed as Bool) {//don't update if we have a pending change
                            
                            church.id = c["id"] as! NSNumber
                            church.name = c["name"] as! String
                            church.development = c["development"] as! NSNumber
                            church.size = c["size"] as! NSNumber
                            if c["latitude"] != nil && c["longitude"]  != nil {
                                
                                //println("lat:")
                                //println(c["latitude"])
                                //println("long:")
                                //println(c["longitude"])
                                if c["latitude"] as? NSNull  != NSNull() {
                                    church.latitude = c["latitude"] as! Float
                                } else {
                                    //println("*** church without a lat: \(church.name)")
                                }
                                if c["longitude"] as? NSNull != NSNull() {
                                    church.longitude = c["longitude"] as! Float
                                } else {
                                    //println("*** church without a long: \(church.name)")
                                }
                            }
                            
                            //church.security = c["security"] as NSNumber
                            church.contact_name = c["contact_name"] as! String
                            church.contact_email = c["contact_email"] as! String
                            church.contact_mobile = c["contact_mobile"] as! String
                            church.ministry_id = c["ministry_id"] as! String
                            if (c["parents"] as! Array<NSNumber>).count  > 0 {
                                church.parent_id = (c["parents"] as! Array<NSNumber>)[0]
                                relationships[church.parent_id] = church.id
                            }
                            
                            church.jf_contrib = c["jf_contrib"] as! Bool
                            
                            
                            // if(contains(c.allKeys as [String],"parent_id")) {church.setValue(c["parent_id"], forKey: "parent_id")}
                            
                            
                            
                            
                            var error2: NSError?
//                            if !moc!.save(&error2) {
//                                //println("Could not save \(error2), \(error2?.userInfo)")
//                            }
                            
                            appDelegate.saveContext()
                        }
                        
                    }
                    
                    //   for c in data as! JSONArray{
                    
                    
                    var moc1: NSManagedObjectContext? = appDelegate.managedObjectContext
                    
                    moc1?.performBlock ({
                        
                        let fetchedResults2 = moc1!.executeFetchRequest(fetchRequest,error: &error) as! [Church]?
                        if let churches = fetchedResults2 {
                            for r in relationships{
                                let c1 = churches.filter{$0.id == r.0} as [Church]
                                let c2 = churches.filter{$0.id == r.1} as [Church]
                                if c1.count>0 && c2.count>0{
                                    c2[0].parent=c1[0]
                                }
                            }
                        }
                        
                        
                        appDelegate.saveContext()
                    })
                    // }

                    let notificationCenter = NSNotificationCenter.defaultCenter()
                    notificationCenter.postNotificationName(GlobalConstants.kDidReceiveChurches, object: nil)
                    
                }
                
                
            }
         
        //   api.st = service_ticket
    
            
        })
        
    }
    
    func checkTokenAndConnection() -> Bool {
        
        switch (self.token != nil && self.token != "", Reachability.isConnectedToNetwork()){
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
    
    func saveContext() {
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        appDelegate.saveContext()
        
      
//        var error: NSError? = nil
//        managedContext.save(&error)

      
        
    }
    
    func updateChurch(){
        if self.checkTokenAndConnection() == false{
            return;
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({
            
        
            var error: NSError?
            let frChurch =  NSFetchRequest(entityName:"Church" )
            let pred = NSPredicate(format: "changed == true" )
            frChurch.predicate=pred
            let ch_changed = moc!.executeFetchRequest(frChurch,error: &error) as! [Church]
            for ch in ch_changed{
                
                if ch.id == -1{
                    API(token: self.token! as String).addChurch(ch){
                        (data: AnyObject?,error: NSError?) -> Void in
                        if data != nil{
                            ch.changed=false
                            ch.id=(data as! JSONDictionary)["id"]  as! NSNumber
                            var error: NSError?
                            if !moc!.save(&error) {
                                //println("Could not save \(error), \(error?.userInfo)")
                            }
                            
                        }
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("callRedrawMethod", object: nil)
                    }
                }
                else{
                    API(token: self.token! as String).saveChurch(ch){
                        (data: AnyObject?,error: NSError?) -> Void in
                        if data != nil{
                            if (data as! Bool){
                                ch.changed=false
                                var error: NSError?
                                if !moc!.save(&error) {
                                    //println("Could not save \(error), \(error?.userInfo)")
                                }
                                
                            }
                        }
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("callRedrawMethod", object: nil)

                    }
                }
                
            }
     
            
        })
        
   
        
        
    }
    
    func updateTraining(){
        if self.checkTokenAndConnection() == false{
            return;
        }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        //NSManagedObjectContext(concurrencyType:  NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        
        
        moc?.performBlock ({
        
            var error: NSError?
            let frTraining =  NSFetchRequest(entityName:"Training" )
            let pred = NSPredicate(format: "changed == true" )
            frTraining.predicate=pred
            let tr_changed = moc!.executeFetchRequest(frTraining,error: &error) as! [Training]
            println(tr_changed)
            for tr in tr_changed{
                if tr.id == -1{
                    
                    println(self.token!)
                    println(tr)

                    API(token: self.token! as String).addTraining(tr){
                        (data: AnyObject?,error: NSError?) -> Void in
                        
                        
                        
                        if data != nil{
                            tr.changed=false
                            tr.id=(data as! JSONDictionary)["id"]  as! NSNumber
                            //println("saved: \(tr.id)")
                            var error: NSError?
                            if !moc!.save(&error) {
                                //println("Could not save \(error), \(error?.userInfo)")
                            }

                            
                        }
                        
                       
                            NSNotificationCenter.defaultCenter().postNotificationName("callRedrawMethod", object: nil)
                       
                    }
                }
                else{
                    
                    API(token: self.token! as String).saveTraining(tr){(data: AnyObject?,error: NSError?) -> Void in
                        if data != nil{
                            if (data as! Bool){
                                tr.changed=false
                                var error: NSError?
                                if !moc!.save(&error) {
                                    //println("Could not save \(error), \(error?.userInfo)")
                                }
                                
                                
                            }
                        }
                    
                        
                            NSNotificationCenter.defaultCenter().postNotificationName("callRedrawMethod", object: nil)
                        
                    
                    }
                }
            }
            
            
            
           
        })
        
        
 
       
        
    }
    
    func updateTrainingCompletion(){
        if self.checkTokenAndConnection() == false{
            return;
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({
            
            var error: NSError?
            let frTrainingCompletion =  NSFetchRequest(entityName:"TrainingCompletion" )
            let pred = NSPredicate(format: "changed == true" )
            frTrainingCompletion.predicate=pred
            let tc_changed = moc!.executeFetchRequest(frTrainingCompletion,error: &error) as! [TrainingCompletion]
            for tc in tc_changed{
                API(token: self.token! as String).saveTrainingCompletion(tc){
                    (data: AnyObject?,error: NSError?) -> Void in
                    if data != nil{
 
                        
                        if (data as! Bool){
                            tc.changed=false
                            var error: NSError?
                            if !moc!.save(&error) {
                                //println("Could not save \(error), \(error?.userInfo)")
                            }
                        }
                    }
                }
            }

        })
        
        
    }
    
    func updateMeasurements(){
        if self.checkTokenAndConnection() == false{
            return;
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({

            // Do heavy or time consuming work
            
            var error: NSError?
            //var mcc:String = NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String
            //Get My Staff Measurements that have changed
            let frMeasurementValue =  NSFetchRequest(entityName:"MeasurementValue" )
            let pred = NSPredicate(format: "changed_me == true || changed_local == true" )
            frMeasurementValue.predicate=pred
            let mv_changed = moc!.executeFetchRequest(frMeasurementValue,error: &error) as! [MeasurementValue]
            var update_values: Array<Measurement> = []
            for mv  in mv_changed {
                
                //need to check the team role...
                if mv.changed_me.boolValue{
                    //lookup the AssignmentId
                    let frAssignment =  NSFetchRequest(entityName:"Assignment" )
                    frAssignment.predicate=NSPredicate(format: "ministry.id == %@ && person_id == %@", mv.measurement.ministry_id, NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String )
                    let this_ass = moc!.executeFetchRequest(frAssignment,error: &error) as! [Assignment]
                    if this_ass.count>0 {
                        //println(mv.measurement.id_person)
                        update_values.append(Measurement(measurement_type_id: mv.measurement.id_person, related_entity_id: this_ass.first!.id! , period: mv.period, mcc: mv.mcc + "_" + GlobalConstants.LOCAL_SOURCE, value: mv.me))
                    }
                    
                    
                    
                }
                
                if mv.changed_local.boolValue{
                    
//                    println(mv.measurement.id_local)
//                    println(mv.measurement.ministry_id)
//                    println(mv.period)
//                    println(mv.mcc + "_" + GlobalConstants.LOCAL_SOURCE)
//                    println(mv.local)

                    update_values.append(Measurement(measurement_type_id: mv.measurement.id_local, related_entity_id: mv.measurement.ministry_id  , period: mv.period, mcc: mv.mcc + "_" + GlobalConstants.LOCAL_SOURCE, value: mv.local))
                }
                
                
            }
            
            
            
            if(update_values.count > 0){
                
                API(token: self.token! as String).saveMeasurement(update_values ){
                    (data: AnyObject?,error: NSError?) -> Void in
                    if data != nil{
                        
                        if (data as! Bool){
                            //   tc.changed=false
                            for mv in mv_changed{
                                mv.changed_me = false
                                mv.changed_local = false
                                
                            }
                            
                                var error: NSError?
                                if !moc!.save(&error) {
                                    //println("Could not save \(error), \(error?.userInfo)")
                                }
                            
                            //now update the measurements
                            self.loadMeasurments( NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String, mcc:  (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString, period: (NSUserDefaults.standardUserDefaults().objectForKey("period") as! String))
                            
                            
                            
                        }
                    }
                }
                
            }
            
        
       
        })
   
       
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
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({
            
            
            API(token: self.token! as String).addTrainingCompletion(insert){
                (data: AnyObject?,error: NSError?) -> Void in
                if data != nil{
                    
                    let tc:JSONDictionary = data as! JSONDictionary
                    var error: NSError?
                    //get Training
                    let fr =  NSFetchRequest(entityName:"Training" )
                    fr.predicate = NSPredicate(format: "id == %@", insert.training_id )
                    
                    let tr = moc!.executeFetchRequest(fr,error: &error) as! [Training]
                    if tr.count>0{
                        
                        let allTC = tr.first!.stages.allObjects as! [TrainingCompletion]
                        
                        var training_comp:TrainingCompletion!
                        let this_tc = allTC.filter {$0.id == (tc["id"] as! NSNumber)}
                        if this_tc.count > 0{
                            training_comp=this_tc.first
                            
                        } else {
                            
                            
                            let entity2 =  NSEntityDescription.entityForName( "TrainingCompletion", inManagedObjectContext: moc!)
                            training_comp = NSManagedObject(entity: entity2!,
                                insertIntoManagedObjectContext:moc!) as! TrainingCompletion
                            
                        }
                        
                        //END: Add or Update
                        training_comp.id = tc["id"] as! NSNumber
                        training_comp.phase = tc["phase"] as! NSNumber
                        training_comp.number_completed = tc["number_completed"] as! NSNumber
                        if(tc["date"] as! String? != nil){
                            training_comp.date = tc["date"] as! String
                        }
                        training_comp.training = tr.first!
                        
                        var error: NSError?
                        if !moc!.save(&error) {
                            //println("Could not save \(error), \(error?.userInfo)")
                        }
                        
                        sender.tc.append(training_comp)
                        sender.tableView.reloadData()
                        let notificationCenter = NSNotificationCenter.defaultCenter()
                        notificationCenter.postNotificationName(GlobalConstants.kDidReceiveTraining, object: nil)
                        
                    }
                    
                }
            }
        
        
        })
        
        
        
    }
    
    func updateMinistry(ministry: Ministry){
        
        API(token: token! as String).updateMinistry(ministry){
            (data: AnyObject?,error: NSError?) -> Void in
            //Nothing to do...
            
        }
        
    }
    
    //>---------------------------------------------------------------------------------------------------
    // Author Name      :   Justin Mohit
    // Date             :   Aug, 2 2015
    // Input Parameters :   N/A.
    // Purpose          :   Post user_preferences.
    //>---------------------------------------------------------------------------------------------------
    
    func saveUser_preferences(mapInfo: NSDictionary){
        
        if let t = token {
            
            if let ministry_id : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String? {
                
                API(token: t as String).saveUser_preferences(mapInfo){
                    (data: AnyObject?,error: NSError?) -> Void in
                    //Nothing to do...
                }
            }
            
            
        }
        
        
    }
    
    //>---------------------------------------------------------------------------------------------------
    // Author Name      :   Justin Mohit
    // Date             :   Aug, 2 2015
    // Input Parameters :   N/A.
    // Purpose          :   Post SupportStaff user_preferences.
    //>---------------------------------------------------------------------------------------------------
    
    func saveSupportStaff_User_preferences(mapInfo: NSDictionary){
        
        API(token: token! as String).save_StaffSupprot_User_preferences(mapInfo){
            (data: AnyObject?,error: NSError?) -> Void in
            //Nothing to do...
        }
        
    }
    
    func joinMinistry(ministry_id: String, sender: NewMinistryTVC){
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({
            // Do heavy or time consuming work
            API(token: self.token! as String).addAssignment( NSUserDefaults.standardUserDefaults().objectForKey("cas_username") as! String , ministry_id: ministry_id, team_role: "self_assigned"){
                (data: AnyObject?,error: NSError?) -> Void in
                if data != nil{
                    let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
                    
                    var error: NSError?
                    let allMinistries = moc!.executeFetchRequest(fetchRequest,error: &error) as! [Ministry]?
                    
                    var user = Dictionary<String, String>()
                    user["person_id"] = NSUserDefaults.standardUserDefaults().objectForKey("person_id") as? String
                    user["first_name"] = NSUserDefaults.standardUserDefaults().objectForKey("first_name") as? String
                    user["last_name"] = NSUserDefaults.standardUserDefaults().objectForKey("last_name") as? String
                    self.addAssignment(data as! JSONDictionary, user: user, allMinistries: allMinistries)
                    
                    NSUserDefaults.standardUserDefaults().setObject(ministry_id, forKey: "ministry_id")
                    
                    // broadcast kChangedAssignment to make sure our settings and system are updated
                    // with this newly joined Ministry!
                    //println("... dataSync.joinMinistry() --> kDidChangeAssignment")
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.postNotificationName(GlobalConstants.kDidChangeAssignment, object: nil)
                }
                
            }

           
            
        })

               //sender.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reset(){
        
        self.token = nil
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var managedContext = appDelegate.managedObjectContext!
            var error: NSError?
            let entityList=["MCC", "Assignment", "Ministry", "Church", "TrainingCompletion", "Training","MeasurementLocalSource", "MeasurementValueSubTeam", "MeasurementValueSelfAssigned", "MeasurementValueTeam", "MeasurementValue", "Measurements"]

            for e in entityList{
                let fr =  NSFetchRequest(entityName:e)
                fr.includesPropertyValues = false

                let items = managedContext.executeFetchRequest(fr,error: &error) as! Array<NSManagedObject>
                for obj in items {
                    
                    managedContext.deleteObject(obj)
                }
                
            }
          
            if managedContext.save(&error) {
                //println("Could not delete objects \(error), \(error?.userInfo)")
            }
            
            
            self.resetDefaults()  // reset all user defaults
            // self.resetDataBase()  // reset all entity in DB
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            
            if self.token != nil{
                //notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
                TheKeyOAuth2Client.sharedOAuth2Client().logout()

            }
            else{
                
                 NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kLogoutNotification, object: nil) // pop to login view
                TheKeyOAuth2Client.sharedOAuth2Client().logout()
              
            }
       
    }
    
    // Justin mohit
    
    func resetDataBase() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var managedContext = appDelegate.managedObjectContext!
        managedContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)

        if let psc = managedContext.persistentStoreCoordinator{
            
            if let store = psc.persistentStores.last as? NSPersistentStore{
                
                let storeUrl = psc.URLForPersistentStore(store)
                
                managedContext.performBlockAndWait(){
                    
                    managedContext.reset()
                    
                    var error:NSError?
                    if psc.removePersistentStore(store, error: &error){
                        NSFileManager.defaultManager().removeItemAtURL(storeUrl, error: &error)
                        psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: nil, error: &error)
                    }
                }
            }
        }
        
        
    }  // not using this time
    
    // justin Mohit
    
    func resetDefaults() {
        
        var appDomain : String = NSBundle.mainBundle().bundleIdentifier!
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        
      
    }
    
    func logout(){
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "hitOnlyOnce")

        API(token: self.token! as String).deleteToken()  {
            
            (data: AnyObject?,error: NSError?) -> Void in
            if data != nil {
           
              AppDelegate().saveContext()
            }
        }
         self.reset()
        //  self.tracker.send(GAIDictionaryBuilder.createEventWithCategory( "auth", action: "logout", label: nil, value: nil).build()  as [NSObject: AnyObject])
        //Delete everything in the database
        
    }
    
}