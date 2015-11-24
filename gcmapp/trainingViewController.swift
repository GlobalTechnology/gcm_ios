//
//  trainingViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 08/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit
import CoreData

class trainingViewController: UITableViewController, UITableViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate{
    
    var isEmptyField = Bool()
    
    var data:JSONDictionary!
    var tc:[TrainingCompletion]!
    var changed:Bool = false
    var changed_tc:Bool = false
    var mapVC:  mapViewController!
    var read_only: Bool = true
    var created_id = String()
    var pickerContainer = UIView()
    var picker = UIDatePicker()
    var cells:NSArray = []
    
    @IBOutlet weak var name: UILabel!
    
    func SaveChanges() {
//        if read_only{
//            return;
//        }
        var error: NSError?
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        if(data["marker_type"] as! String == "new_training"){
            

                //create new training
                let entity =  NSEntityDescription.entityForName("Training", inManagedObjectContext: managedContext)
                var training = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext:managedContext) as! Training
                
                
                training.changed   =  true
                training.name      =  data["name"] as! String
                if(data["type"] as! String == "Other"){
                    training.type =  ""
                }
                else{
                    training.type =  data["type"] as! String
                }
            
                //println(training.type)
                training.longitude =  data["longitude"] as! Float
                training.latitude  =  data["latitude"] as! Float
                training.id        =  -1  //indicates new church
                data["marker_type"] = "training"
                data["id"] = -1
                //            data["marker_type"] = "new_training"
                //            data["name"] = ""
                //            data["type"] = ""
                data["date"] = GlobalFunctions.currentDate()
                //            data["id"] = -1
                data["created_by"] = NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String

                if let ministry_id = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String
                {
                    training.ministry_id = ministry_id
                    data["ministry_id"] = ministry_id
                }
            
                
                if let mcc = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as? String)
                {
                    training.mcc =  mcc.lowercaseString
                }
                
                
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy" //"yyyy-MM-dd"
            
            let strDate = dateFormatter.stringFromDate(datePickerCell.date)
            
            if let date = dateFormatter.dateFromString(strDate) {
                
                dateFormatter.dateFormat = "yyyy-MM-dd"
                training.date =  dateFormatter.stringFromDate (date)
                
                println(training.date) // no output
                data["date"] = training.date
                
                
            } else {
                
                //println("Error message") // "Error message"
            }
            
            
                if let created_by = NSUserDefaults.standardUserDefaults().objectForKey("person_id") as? String {
                    training.created_by = created_by
                }

                
//                if !managedContext.save(&error) {
//                    //println("Could not save \(error), \(error?.userInfo)")
//                }
            
                appDelegate.saveContext()
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kDidChangeTraining, object: nil)
            
                // GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "training", action: "create", label: nil, value: nil).build()  as [NSObject: AnyObject])
            // notificationCenter.postNotificationName(GlobalConstants.kShouldRefreshAll, object: nil)
            
//                NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kDrawTrainingPinKey, object: nil, userInfo: data as JSONDictionary)
            
            
//            }
        }
            
        else if self.changed {
            
            let fetchRequest = NSFetchRequest(entityName:"Training")
            fetchRequest.predicate = NSPredicate(format: "id = %@", data["id"] as! NSNumber)
            let training = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [Training]
            if training.count>0{
                training.first!.changed=true
                training.first!.name=data["name"] as! String
                training.first!.type=data["type"] as! String
                
                if(NSUserDefaults.standardUserDefaults().boolForKey("ChangeDateCell") == true){
                    
                NSUserDefaults.standardUserDefaults().removeObjectForKey("ChangeDateCell")
                    
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy" //"yyyy-MM-dd"
                
                let strDate = dateFormatter.stringFromDate(datePickerCell.date)
                
                if let date = dateFormatter.dateFromString(strDate) {
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    training.first!.date = dateFormatter.stringFromDate(date)
                    
                    data["date"] = dateFormatter.stringFromDate(date)

                } else {
                    
                    //println("Error message") // "Error message"
                }
            }
            
            }
            
            if !managedContext.save(&error) {
                //println("Could not save \(error), \(error?.userInfo)")
            }
            
            
            
            
            //broadcast for update
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeTraining, object: nil)
            
            //NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kUpdatePinInforamtionKey, object: nil, userInfo: data as JSONDictionary)

            //GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "training", action: "update", label: nil, value: nil).build()  as [NSObject: AnyObject])
        }
        
        if changed_tc{
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeTrainingCompletion, object: nil)
            
            NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kUpdatePinInforamtionKey, object: nil, userInfo: data as JSONDictionary)

            // GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "training", action: "update", label: nil, value: nil).build()  as [NSObject: AnyObject])
        }
    }
    
//>---------------------------------------------------------------------------------------------------
// Author Name      :   Caleb Kapil
// Date             :   Jan, 7 2015
// Input Parameters :   strTitle - alertbox tilte, Message - alert box message
// Purpose          :   For go to home class.
//>----------------------------------------------------------------------------------------------------
func callAlertView(strTitle :String,Message :String)
{
    var alert = UIAlertController(title: strTitle, message: Message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
        switch action.style{
        case .Default:
            println("default")
            
        case .Cancel:
            println("cancel")
            
        case .Destructive:
            println("destructive")
        }
    }))
    
    self.presentViewController(alert, animated: true, completion: nil)
}
    
override func viewDidAppear(animated: Bool) {
    
    super.viewDidAppear(true)
    // self.navigationController!.delegate = self;
    
    self.tableView.reloadData()
}
    
     func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        
        
        // var type_cell=tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))!
        // type_cell.detailTextLabel!.text = (data["type"] != nil) ? data["type"] as? String : " "
        self.tableView.reloadData()

    }
    
    
    let datePickerCell = DatePickerCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEmptyField = false

        tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.navigationController?.delegate = self

        // The DatePickerCell.
        
        // Cells is a 2D array containing sections and rows.
        cells = [[datePickerCell]]
        // Do view setup here.
        if let nm = data["name"] as? String {
            name.text = nm
        }
        
        if let team_role  = NSUserDefaults.standardUserDefaults().objectForKey("team_role") as? String {
            self.read_only = !GlobalFunctions.contains(team_role, list: GlobalConstants.LEADERS_ONLY)
        }
        
        if let created_by = data["created_by"] as? String{
            created_id = created_by
        }
        else{
            created_id = NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowType"{
            let tvc = segue.destinationViewController as! TrainingTypeTVC
            tvc.training = self
        }
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        //tableView.endEditing(true)
    }
    
    // MARK:- UITableView delegate method
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data["marker_type"] as! String == "new_training" ? 1 : 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        dispatch_async(dispatch_get_main_queue(), {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        })

        if section == 0{
            
            if data["marker_type"] as! String == "new_training" {
                
                return 5
            }
            else
            {
                if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String ==  data["ministry_id"] as? String && read_only == false){
                    
                    return 7
                }
                
                return 5
            }
        }
        else{
            
            if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String ==  data["ministry_id"] as? String && read_only == false) {
            
            if data["stages"] == nil{
                return 1
            }
            else
            {
                return   tc.count + 1
            }
            
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
            if (created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false)) && data["marker_type"] as! String != "new_training"
            
            {
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
            else{
                var stage = tc[indexPath.row] as TrainingCompletion
                
                cell = tableView.dequeueReusableCellWithIdentifier("ReadOnlyTrainingCell", forIndexPath: indexPath) as! UITableViewCell

                cell.textLabel?.text = "\(indexPath.row + 1)  \(stage.date)   participants:"
                cell.detailTextLabel!.text = stage.number_completed.stringValue
            }
        }
        else if indexPath.section == 0 {
            
            
            switch(indexPath.row){
            case 0: // Back
                cell = tableView.dequeueReusableCellWithIdentifier("BackCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel!.text = data["marker_type"] as! String == "new_training" ? "Save" : "Back to Map"
               
            case 5: //Move
                
                if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false) {
                
                cell = tableView.dequeueReusableCellWithIdentifier("MoveCell", forIndexPath: indexPath) as! UITableViewCell
                    // cell.userInteractionEnabled = data["marker_type"] as! String != "new_training" && !read_only
                    // cell.textLabel!.enabled = data["marker_type"] as! String != "new_training" && !read_only
                cell.alpha=0.5
                    
                }
                
            case 6: //Delete
               
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
                    cell.isChurch   =   false
                    cell.training   =   self
                    cell.field_name =   "name"
                    cell.title.text =   "Name"
                    cell.value.text =   (data["name"] != nil) ? data["name"] as? String : ""
                    cell.value.delegate = self
                    cell.value.tag  =   -1

                    return cell
  
                }
                
                else if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false) {
                    
                    var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UIEditTextCell
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.isChurch   =   false
                    cell.training   =   self
                    cell.field_name =   "name"
                    cell.title.text = "Name"
                    cell.value.text = (data["name"] != nil) ? data["name"] as? String : ""
                    cell.value.delegate = self

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
                    
                    println(data)
                        cell.detailTextLabel!.text =  (data["type"] != nil) ? data["type"] as? String : " "
                 }
                    
                else if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false)  {
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as! UITableViewCell
                    
                    cell.detailTextLabel!.text = (data["type"] != nil) ? data["type"] as? String : " "
                    
//                    self.tableView.beginUpdates()
//                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Automatic)
//
//                    self.tableView.endUpdates()
                    
                }
                else {
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("ReadOnlyTrainingCell", forIndexPath: indexPath) as! UITableViewCell
                    
                    cell.textLabel!.text = "Type"
                    
                    cell.detailTextLabel!.text = (data["type"] != nil) ? data["type"] as? String : " "
             
                }
                
            case 3: //date
                
                if (data["marker_type"] as! String == "new_training") {
//                    var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UIEditTextCell
//                    cell.selectionStyle = UITableViewCellSelectionStyle.None
//                    cell.isChurch=false
//                    cell.training=self
//                    cell.field_name="date"
//                    cell.title.text = "Date"
//                    cell.value.text = (data["date"] != nil) ? data["date"] as? String : ""
//                    cell.value.tag = 3
//                    
//                    
//                    return cell
                    
                 
                
                   return cells[0][0] as! UITableViewCell
                }
                    
                else if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false) {
//                    
//                    var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UIEditTextCell
//                    cell.selectionStyle = UITableViewCellSelectionStyle.None
//                    cell.isChurch=false
//                    cell.training=self
//                    cell.field_name="date"
//                    cell.title.text = "Date"
//                    cell.value.text = (data["date"] != nil) ? data["date"] as? String : ""
//                    return cell
                    
                    
                     return cells[0][0] as! UITableViewCell
                    
                }
                else{
                    
//                    cell = tableView.dequeueReusableCellWithIdentifier("ReadOnlyTrainingCell", forIndexPath: indexPath) as! UITableViewCell
//                    
//                    cell.textLabel!.text = "date"
//                    
//                    cell.detailTextLabel!.text = (data["date"] != nil) ? data["date"] as? String : ""
                    
                    return cells[0][0] as! UITableViewCell

                    
                }

            case 4:
                
                cell = tableView.dequeueReusableCellWithIdentifier("ReadOnlyTrainingCell", forIndexPath: indexPath) as! UITableViewCell
                
                cell.textLabel!.text = "Mcc"
                
                cell.detailTextLabel!.text = NSUserDefaults.standardUserDefaults().objectForKey("mcc") as? String
                
            default:
                break
                
            }
            
            
            
        }
        // var cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as! UITableViewCell
         return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Get the correct height if the cell is a DatePickerCell.
        
        if (indexPath.section == 0 && indexPath.row == 3) {
        
        var cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
            if (cell.isKindOfClass(DatePickerCell)) {
                return (cell as! DatePickerCell).datePickerHeight()
            }
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        self.view.endEditing(true)

        if indexPath.section == 0{
            self.tableView.resignFirstResponder()
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC)))
            switch(indexPath.row){
            case 0: // back

                println(data)
                if data["name"] as? String == "" {
                    isEmptyField = true
                }
                
                if data["type"] as? String == ""{
                    isEmptyField = true
                }
                
                if(isEmptyField == false){
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {self.SaveChanges()})
                }
                else
                {
                    isEmptyField = false
                    
                    let alertView = UIAlertView(title:"", message: "Please Fill All field.", delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                }
              
                
                break
                
            case 5: //move

               if (created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false)) && data["marker_type"] as! String != "new_training" {
                    
                    self.mapVC.makeSelectedMarkerDraggable()
                    self.dismissViewControllerAnimated(true, completion: nil)
               
                
                }
                
                break
                
            case 6: //Delete
                
                var alertController = UIAlertController(title: "", message: "Are you sure you want to delete this training?", preferredStyle: .Alert)
                
                // Create the actions
                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    
                    NSLog("OK Pressed")
                    
                    
                    
                    if (self.created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  self.data["ministry_id"] as! String && self.read_only == false)) && self.data["marker_type"] as! String != "new_training" {
                        // self.mapVC.makeSelectedMarkerDraggable()
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                        var training_id  = self.data["id"] as! Int
                        var latitude  =    self.data["latitude"] as! Double
                        var longitude  =   self.data["longitude"] as! Double
                        
                        var traningInfoDic = NSDictionary(objectsAndKeys:self.data["id"]!,"training_id",self.data["latitude"]!,"lat",self.data["longitude"]!,"long",self.mapVC.mapView.camera.zoom,"zoom" )
                        // dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {self.SaveChanges()})
                        
                        let notificationCenter = NSNotificationCenter.defaultCenter()
                        notificationCenter.postNotificationName(GlobalConstants.kShouldDeleteTraining, object: nil, userInfo: traningInfoDic as! JSONDictionary)
                    }
                    
                }
                var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    
                    self.tableView.reloadData()
                    NSLog("Cancel Pressed")
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
                
   
                
                break
                
            case 2:
                
                if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false) {
                    
                    self.performSegueWithIdentifier("ShowType", sender: self)
                }
                break
                
            case 3:
                if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false) {
                    
                        self.changed = true

                        var cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
                        if (cell.isKindOfClass(DatePickerCell)) {
                            var datePickerTableViewCell = cell as! DatePickerCell
                            datePickerTableViewCell.selectedInTableView(tableView)
                            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                        }
                    }
                break
                
            default:
                break
                
            }
            
           
            
            
        }
        else if indexPath.section==1{
            if txtFldActive == true{
                return
            }
            
            if indexPath.row == tc.count {
                
                let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.Indeterminate
                loadingNotification.color = UIColor(red:0.0/255.0,green:128.0/255.0,blue:64.0/255.0,alpha:1.0)
                
                //add new Training Stage.
                let notificationCenter = NSNotificationCenter.defaultCenter()
                var insert = createTrainingStage(training_id: data["id"] as! NSNumber, phase: tc.count + 1, date: GlobalFunctions.currentDate(), number_completed: 0)
                notificationCenter.postNotificationName(GlobalConstants.kShouldAddNewTrainingPhase, object: self, userInfo: ["createTrainingStage": insert])
               
            }
        }
    }
    
    // MARK:- UITextField delegate method

//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        
//    if(textField.text.isEmpty)
//    {
//        self.callAlertView("", Message: "Please enter name.")
//    }
//
//        
//        textField.resignFirstResponder()
//        
//        
//        return true
//    }
    
 var txtFldActive = Bool()
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        txtFldActive = true
        return true
    }
    
func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
        if(textField.tag == -1)
        {
            return true
        }
        else{
        
        let maxLength = 4
        let currentString: NSString = textField.text
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
}
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.changed = true

        if(textField.tag == -1)
        {
            data["name"] = textField.text as NSString
        }
        else{
                let stage = tc[textField.tag] as TrainingCompletion
        
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
                let managedContext = appDelegate.backgroundContext!
                if stage.number_completed != (textField.text as NSString).integerValue
                {
                    stage.number_completed = (textField.text as NSString).integerValue
                    stage.changed = true
        
                    var error: NSError?
        
                    if !managedContext.save(&error) {
                        //println("Could not save \(error), \(error?.userInfo)")
                    }
                    
                }
        }
        
        txtFldActive = false
    }
}
