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
    
    
    
    @IBOutlet weak var name: UILabel!
    
   
    
    func SaveChanges() {
        if read_only{
            return;
        }
        var error: NSError?
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        if(data["marker_type"] as String == "new_training"){   //create new training
            let entity =  NSEntityDescription.entityForName( "Training", inManagedObjectContext: managedContext)
            var training = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext) as Training
            training.changed=true
            training.name=data["name"] as String
            training.type=data["type"] as String
            println(training.type)
            training.longitude = data["longitude"] as Float
            training.latitude = data["latitude"] as Float
            training.id = -1  //indicates new church
            training.ministry_id = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String
            training.mcc = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString
            training.date = data["date"] as String
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeTraining, object: nil)
            
        }
        else if self.changed {
            let fetchRequest = NSFetchRequest(entityName:"Training")
            
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", data["id"] as NSNumber)
            let training = managedContext.executeFetchRequest(fetchRequest, error: &error) as [Training]
            if training.count>0{
                training.first!.changed=true
                training.first!.name=data["name"] as String
                training.first!.type=data["type"] as String
                
            }
            
            
            
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            
            
            
            //broadcast for update
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeTraining, object: nil)
            
        }
        if changed_tc{
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeTrainingCompletion, object: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if(data["name"] != nil){
            name.text = data["name"] as? String
        }
        let team_role =  NSUserDefaults.standardUserDefaults().objectForKey("team_role") as String
        
        self.read_only = !GlobalFunctions.contains(team_role, list: GlobalConstants.LEADERS_ONLY)
        
        
        let descriptor = NSSortDescriptor(key: "phase", ascending: true)
        
        tc = (data["stages"] as NSSet).sortedArrayUsingDescriptors([descriptor]) as [TrainingCompletion]
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
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
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
        return data["marker_type"] as String == "new_training" ? 1 : 2
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 4
        }
        else{
            if data["stages"] == nil{
                return 0
            }
            else
            {
                return   tc.count
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
        
        if indexPath.section == 1{
            var cell = tableView.dequeueReusableCellWithIdentifier("TrainingCompCell", forIndexPath: indexPath) as TrainingCompCell
            
            var stage = tc[indexPath.row] as TrainingCompletion
            cell.stage.text = stage.phase.stringValue
            cell.date.text  = stage.date
            cell.participants.text = stage.number_completed.stringValue
            cell.participants.delegate = self
            cell.participants.tag = indexPath.row
            
            
            
            
            
            return cell
            
        }
        else if indexPath.section == 0{
            switch(indexPath.row){
            case 0: // Back
                let cell = tableView.dequeueReusableCellWithIdentifier("BackCell", forIndexPath: indexPath) as UITableViewCell
                cell.textLabel!.text = data["marker_type"] as String == "new_training" ? "Save" : "Back to Map"
                return cell
            case 1: //Move
                let cell = tableView.dequeueReusableCellWithIdentifier("MoveCell", forIndexPath: indexPath) as UITableViewCell
                cell.userInteractionEnabled = data["marker_type"] as String != "new_training" && !read_only
                cell.textLabel!.enabled = data["marker_type"] as String != "new_training" && !read_only
                cell.alpha=0.5
                
                return cell
            case 2: //name
                if read_only{
                    var cell = tableView.dequeueReusableCellWithIdentifier("ReadOnlyTrainingCell", forIndexPath: indexPath) as UITableViewCell
                    
                    cell.textLabel!.text = "Name"
                    
                    cell.detailTextLabel!.text = (data["name"] != nil) ? data["name"] as? String : ""
                    return cell

                }
                else{
                
                var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as UIEditTextCell
                cell.isChurch=false
                cell.training=self
                cell.field_name="name"
                cell.title.text = "Name"
                
                cell.value.text = (data["name"] != nil) ? data["name"] as? String : ""
                return cell
                }
            case 3: //type
                if read_only{
                    var cell = tableView.dequeueReusableCellWithIdentifier("ReadOnlyTrainingCell", forIndexPath: indexPath) as UITableViewCell
                    
                    cell.textLabel!.text = "Type"
                    
                    cell.detailTextLabel!.text = (data["type"] != nil) ? data["type"] as? String : ""
                    return cell
                    
                }
                else{
                var cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as UITableViewCell
                cell.detailTextLabel!.text = (data["type"] != nil) ? data["type"] as? String : ""
                return cell
                }
                
            default:
                break
                
            }
            
            
            
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as UITableViewCell
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            switch(indexPath.row){
            case 0: // back
                self.SaveChanges()
                mapVC.redrawMap()
                self.dismissViewControllerAnimated(true, completion: nil)
                
                break
            case 1: //move
                if(data["marker_type"] as String != "new_training"){
                    self.SaveChanges()
                    self.mapVC.makeSelectedMarkerDraggable()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                break
            case 3:
                 self.performSegueWithIdentifier("ShowType", sender: self)
                break
                
            default:
                break
                
            }
        }

}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowType"{
            let tvc = segue.destinationViewController as TrainingTypeTVC
            tvc.training = self
           

        }
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }
    

}
