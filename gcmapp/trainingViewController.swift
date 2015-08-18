//
//  trainingViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 08/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit
import CoreData

class trainingViewController: UITableViewController, UITableViewDelegate,UITextFieldDelegate {
    
    
    
    var data:JSONDictionary!
    var tc:[TrainingCompletion]!
    var changed:Bool = false
    var changed_tc:Bool = false
    var mapVC:  mapViewController!
    var read_only: Bool = true
    var created_id = String()

    
    
    @IBOutlet weak var name: UILabel!
    
    
    
    func SaveChanges() {
//        if read_only{
//            return;
//        }
        var error: NSError?
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        if(data["marker_type"] as! String == "new_training"){   //create new training
            let entity =  NSEntityDescription.entityForName( "Training", inManagedObjectContext: managedContext)
            var training = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext) as! Training
            training.changed=true
            training.name=data["name"] as! String
            training.type=data["type"] as! String
            println(training.type)
            training.longitude = data["longitude"] as! Float
            training.latitude = data["latitude"] as! Float
            training.id = -1  //indicates new church
            
            if let ministry_id = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String
            {
                 training.ministry_id = ministry_id
            }
            if let mcc = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as? String)

            {
                training.mcc =  mcc.lowercaseString
            }

            training.date = data["date"] as! String
            
            
            if let created_by = NSUserDefaults.standardUserDefaults().objectForKey("person_id") as? String
            {
                training.created_by = created_by
            }

            
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeTraining, object: nil)
             GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "training", action: "create", label: nil, value: nil).build()  as [NSObject: AnyObject])
        }
        else if self.changed {
            
            let fetchRequest = NSFetchRequest(entityName:"Training")
            fetchRequest.predicate = NSPredicate(format: "id = %@", data["id"] as! NSNumber)
            let training = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [Training]
            if training.count>0{
                training.first!.changed=true
                training.first!.name=data["name"] as! String
                training.first!.type=data["type"] as! String
                
            }
            
            
            
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            
            
            
            //broadcast for update
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeTraining, object: nil)
             GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "training", action: "update", label: nil, value: nil).build()  as [NSObject: AnyObject])
        }
        if changed_tc{
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeTrainingCompletion, object: nil)
             GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "training", action: "update", label: nil, value: nil).build()  as [NSObject: AnyObject])
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
        self.tableView.reloadData()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)

        // Do view setup here.
        if let nm = data["name"] as? String {
            name.text = nm
        }
        if let team_role  = NSUserDefaults.standardUserDefaults().objectForKey("team_role") as? String {
            
            self.read_only = !GlobalFunctions.contains(team_role, list: GlobalConstants.LEADERS_ONLY)
            
        }
        if let created_by = data["created_by"] as? String
        {
            created_id = created_by
        }

        let descriptor = NSSortDescriptor(key: "phase", ascending: true)
        
        tc = (data["stages"] as! NSSet).sortedArrayUsingDescriptors([descriptor]) as! [TrainingCompletion]
        // var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        //  tableView.addGestureRecognizer(tap)
        /* if data["marker_type"] as String == "new_training"{
        btnClose.titleLabel!.text = "Save"
        btnMove.hidden=true
        }*/
        
        
        
        
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        //tableView.endEditing(true)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let stage = tc[textField.tag ] as TrainingCompletion
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.backgroundContext!
        if stage.number_completed != (textField.text as NSString).integerValue
        {
            stage.number_completed = (textField.text as NSString).integerValue
            stage.changed = true
            self.changed = true
            
            var error: NSError?
            
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data["marker_type"] as! String == "new_training" ? 1 : 2
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            
            if data["marker_type"] as! String == "new_training" {
                
                return 3
            }
            else
            {
                
                if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String ==  data["ministry_id"] as? String && read_only == false){
                    
                    return 5
                    
                }
                
                return 3
                
            }

            
        }
        else{
            if data["stages"] == nil{
                return 1
            }
            else
            {
                return   tc.count + 1
            }
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1{
            return "Training Stages"
            
        }
        else{
            return ""
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()

        if indexPath.section == 1{
            
            if indexPath.row == tc.count {
                cell = tableView.dequeueReusableCellWithIdentifier("NewStageCell", forIndexPath: indexPath) as! UITableViewCell
                return cell
                
            }
            else {
                
                var cell = tableView.dequeueReusableCellWithIdentifier("TrainingCompCell", forIndexPath: indexPath) as! TrainingCompCell
                var stage = tc[indexPath.row] as TrainingCompletion
                cell.stage.text = stage.phase.stringValue
                cell.date.text  = stage.date
                cell.participants.text = stage.number_completed.stringValue
                cell.participants.delegate = self
                cell.participants.tag = indexPath.row
             
                return cell
            }
            
        }
        else if indexPath.section == 0 {
            
            println(data)
            
            switch(indexPath.row){
            case 0: // Back
                cell = tableView.dequeueReusableCellWithIdentifier("BackCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel!.text = data["marker_type"] as! String == "new_training" ? "Save" : "Back to Map"
               
            case 3: //Move
                
                if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false) {
                
                cell = tableView.dequeueReusableCellWithIdentifier("MoveCell", forIndexPath: indexPath) as! UITableViewCell
                    // cell.userInteractionEnabled = data["marker_type"] as! String != "new_training" && !read_only
                    // cell.textLabel!.enabled = data["marker_type"] as! String != "new_training" && !read_only
                cell.alpha=0.5
                    
                }
                
            case 4: //Delete
               
                // only for allowed member
                if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false) {
                    
                cell = tableView.dequeueReusableCellWithIdentifier("DeleteCell", forIndexPath: indexPath) as! UITableViewCell
                    // cell.userInteractionEnabled = data["marker_type"] as! String != "new_training" && !read_only
                    // cell.textLabel!.enabled = data["marker_type"] as! String != "new_training" && !read_only
                cell.alpha=0.5
                }

            case 1: //name
               
              
                if (data["marker_type"] as! String == "new_training") {
                    var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UIEditTextCell
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.isChurch=false
                    cell.training=self
                    cell.field_name="name"
                    cell.title.text = "Name"
                    cell.value.text = (data["name"] != nil) ? data["name"] as? String : ""
                    return cell
  
                }
                
                else if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false) {
                    
                var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UIEditTextCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.isChurch=false
                cell.training=self
                cell.field_name="name"
                cell.title.text = "Name"
                cell.value.text = (data["name"] != nil) ? data["name"] as? String : ""
                return cell

                
                }
                else{
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("ReadOnlyTrainingCell", forIndexPath: indexPath) as! UITableViewCell
                    
                    cell.textLabel!.text = "Name"
                    
                    cell.detailTextLabel!.text = (data["name"] != nil) ? data["name"] as? String : ""

                }
            case 2: //type
              
                 if (data["marker_type"] as! String == "new_training") {
                    
                    
                        cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as! UITableViewCell
                        cell.detailTextLabel!.text =  (data["type"] != nil) ? data["type"] as? String : ""
                 }
                    
                else if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false)  {
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as! UITableViewCell
                    cell.detailTextLabel!.text = (data["type"] != nil) ? data["type"] as? String : ""
                    
                }
                else {
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("ReadOnlyTrainingCell", forIndexPath: indexPath) as! UITableViewCell
                    
                    cell.textLabel!.text = "Type"
                    
                    cell.detailTextLabel!.text = (data["type"] != nil) ? data["type"] as? String : ""
             
                }
                
            default:
                break
                
            }
            
            
            
        }
        // var cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as! UITableViewCell
         return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.section == 0{
            self.tableView.resignFirstResponder()
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC)))
            switch(indexPath.row){
            case 0: // back
              
                self.dismissViewControllerAnimated(true, completion: nil)
                dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {self.SaveChanges()})
                break
                
            case 3: //move

               if (created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false)) && data["marker_type"] as! String != "new_training" {
                    
                    self.mapVC.makeSelectedMarkerDraggable()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {self.SaveChanges()})

                    
                }
                
                break
                
            case 4: //Delete
                
               if (created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false)) && data["marker_type"] as! String != "new_training" {
                    // self.mapVC.makeSelectedMarkerDraggable()
                    self.dismissViewControllerAnimated(true, completion: nil)
                
                    var training_id  = data["id"] as! Int
                    var latitude  =    data["latitude"] as! Double
                    var longitude  =   data["longitude"] as! Double

                    var traningInfoDic = NSDictionary(objectsAndKeys:data["id"]!,"training_id",data["latitude"]!,"lat",data["longitude"]!,"long",mapVC.mapView.camera.zoom,"zoom" )
                    
                    let notificationCenter = NSNotificationCenter.defaultCenter()
                    notificationCenter.postNotificationName(GlobalConstants.kShouldDeleteTraining, object: nil, userInfo: traningInfoDic as! JSONDictionary)
                
               }
                break
                
            case 2:
                
                self.performSegueWithIdentifier("ShowType", sender: self)
                break
                
            default:
                break
                
            }
            
        }
        else if indexPath.section==1{
            if indexPath.row == tc.count {
                //add new Training Stage.
                let notificationCenter = NSNotificationCenter.defaultCenter()
                var insert = createTrainingStage(training_id: data["id"] as! NSNumber, phase: tc.count + 1, date: GlobalFunctions.currentDate(), number_completed: 0)
                notificationCenter.postNotificationName(GlobalConstants.kShouldAddNewTrainingPhase, object: self, userInfo: ["createTrainingStage": insert])
               
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowType"{
            let tvc = segue.destinationViewController as! TrainingTypeTVC
            tvc.training = self
            
            
        }
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }
    
    
}
