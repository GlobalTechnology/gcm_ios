//
//  ChurchTVC.swift
//  gcmapp
//
//  Created by Jon Vellacott on 28/01/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit
import CoreData

class ChurchTVC: UITableViewController,UINavigationControllerDelegate {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var Icon: UIImageView!
    var data:JSONDictionary!
    
    var isEmptyField = Bool()
    
    var changed:Bool = false
    var mapVC:  mapViewController!
    var read_only: Bool = true
    var created_id = String()
    
    @IBAction func btnSetParent(sender: UIButton) {
        
    }
    
    @IBAction func btnSaveTap(sender: AnyObject) {
        self.view.endEditing(true)

        if (data["name"] as? String ==  ""){
           return self.callAlertView("", Message: "Please enter name.")
        }
        else if (data["contact_mobile"] as? String ==  nil || data["contact_mobile"] as? String ==  ""){
           return self.callAlertView("", Message: "Please enter phone no.")
        }
        else{
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC)))

            self.navigationController?.popViewControllerAnimated(true)
            
            dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {self.SaveChanges()})
        }
    }
    
    func SaveChanges() {
        
        var error: NSError?
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        if(data["marker_type"] as! String == "new_church"){   //create new church
            let entity =  NSEntityDescription.entityForName("Church", inManagedObjectContext: managedContext)
            var church = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext) as! Church
            church.changed=true
            data["marker_type"] = "church"
            data["created_by"] = NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String
            data["id"] = -1
            if let name = data["name"] as? String {
                
                church.name = name
            }
            if let contact_name = data["contact_name"] as? String {
                
                church.contact_name = contact_name
            }
            
            if let contact_email = data["contact_email"] as? String {
                
                church.contact_email = contact_email
            }
            
            if let contact_mobile = data["contact_mobile"] as? String {
                
                church.contact_mobile = contact_mobile
            }
            if let size = data["size"] as? NSNumber {
                
                church.size = size
            }
            if let development = data["development"] as? NSNumber {
                
                church.development = development
            }
            if let security = data["security"] as? NSNumber {
                
                church.security = security
            }
            if let longitude = data["longitude"] as? Float {
                
                church.longitude = longitude
            }
            if let latitude = data["latitude"] as? Float {
                
                church.latitude = latitude
            }
            
            church.id = -1  //indicates new church
            
            if let ministry_id = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String {
                
                church.ministry_id = ministry_id
            }
            
            
            if let created_by = NSUserDefaults.standardUserDefaults().objectForKey("person_id") as? String
            {
                church.created_by = created_by
            }
            
            
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            //  notificationCenter.postNotificationName(GlobalConstants.kShouldRefreshAll, object: nil)
            
            //NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kDrawChurchPinKey, object: nil, userInfo: data as JSONDictionary)
            
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeChurch, object: nil)
            
            
            
            // GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "church", action: "create", label: nil, value: nil).build()  as [NSObject: AnyObject])
        }
        else if(changed){
            let fetchRequest = NSFetchRequest(entityName:"Church")
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", data["id"] as! NSNumber)
            let church = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [Church]
            if church.count>0{
                
                //println(data)
                church.first!.changed=true
                church.first!.name=data["name"] as! String
                church.first!.contact_name=data["contact_name"] as! String
                church.first!.contact_email=data["contact_email"] as! String
                church.first!.contact_mobile=data["contact_mobile"] as! String
                
                church.first!.size=data["size"] as! NSNumber
                church.first!.development=data["development"] as! NSNumber
                church.first!.security=data["security"] as! NSNumber
                if data["parent_id"] != nil {
                    
                    if( (church.first!.parent_id != data["parent_id"] as! NSNumber)){
                        
                        //parent_id has changed
                        //lookup parent...
                        let fetchRequest2 = NSFetchRequest(entityName:"Church")
                        fetchRequest2.predicate = NSPredicate(format: "id = %@", data["parent_id"] as! NSNumber)
                        let parent = managedContext.executeFetchRequest(fetchRequest2, error: &error) as! [Church]
                        if parent.count>0{
                            church.first!.parent = parent.first!
                            church.first!.parent_id = data["parent_id"] as! NSNumber
                        }
                    }
                }
            }
            
            if !managedContext.save(&error) {
                //println("Could not save \(error), \(error?.userInfo)")
            }
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeChurch, object: nil)
            
            //NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.kUpdatePinInforamtionKey, object: nil, userInfo: data as JSONDictionary)
            
            //GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "church", action: "update", label: nil, value: nil).build()  as [NSObject: AnyObject])
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEmptyField = false
        
        tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        
        if let team_role  = NSUserDefaults.standardUserDefaults().objectForKey("team_role") as? String {
            
            self.read_only = !GlobalFunctions.contains(team_role, list: GlobalConstants.LEADERS_ONLY)
            
        }
        
        if let created_by = data["created_by"] as? String
        {
            created_id = created_by
        }
        
        name.text = data["name"] as? String
        Icon.image = UIImage(named: mapViewController.getIconNameForChurch(data["development"] as! NSNumber))
        
        /*if data["marker_type"] as String == "new_church"{
        btnClose.titleLabel!.text = "Save"
        btnMove.hidden=true
        }*/
        //contactName.text = data["contactName"] as? String
        //contactEmail.text = data["contactEmail"] as? String
        //churchSize.text = (data["size"] as NSNumber).stringValue
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        
        if data["marker_type"] as! String == "new_church" {
            return 1
        }
        else{
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0{
            return data["marker_type"] as! String == "new_church" ? 7 : 8
        }
        else{
            // return (data["marker_type"] as! String == "new_church") ? 1 : 3 //!read_only ? 3 : 3
            if data["marker_type"] as! String == "new_church" {
                
                return 0
            }
            else
            {
                
                if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String ==  data["ministry_id"] as? String && read_only == false){
                    
                    return 2
                    
                }
                
                return 1
                
            }
            
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            // Configure the cell...
            
            if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || ((NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String ==  data["ministry_id"] as? String && read_only == false)) || data["marker_type"] as! String == "new_church"{
                
                switch (indexPath.row){
                case 0:
                    let cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UIEditTextCell
                    cell.title.text = "Name"
                    cell.value.tag = 0
                    cell.value.text = data["name"] as? String
                    cell.field_name = "name"
                    cell.church=self
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UIEditTextCell
                    cell.title.text = "Contact Name"
                    cell.value.tag = 1
                    cell.value.text = data["contact_name"] as? String
                    cell.field_name = "contact_name"
                    cell.church=self
                    return cell
                case 2:
                    let cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UIEditTextCell
                    cell.title.text = "Contact Email"
                    cell.value.tag = 2
                    cell.value.text = data["contact_email"] as? String
                    cell.field_name = "contact_email"
                    cell.church=self
                    return cell
                case 3:
                    let cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UIEditTextCell
                    cell.title.text = "Contact Mobile"
                    cell.value.tag = 3
                    cell.value.text = data["contact_mobile"] as? String
                    cell.field_name = "contact_mobile"
                    cell.church=self
                    return cell
                case 4:
                    let cell = tableView.dequeueReusableCellWithIdentifier("EditNumberCell", forIndexPath: indexPath) as! UIEditTextCell
                    cell.title.text = "Size"
                    cell.value.tag = 4
                    cell.value.text = (data["size"] as! NSNumber).stringValue
                    cell.field_name = "size"
                    cell.church=self
                    return cell
                case 5:
                    let cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as! UITableViewCell
                    // cell.textLabel!.text = "Type"
                    cell.detailTextLabel!.text = GlobalFunctions.getNameForDevelopment((data["development"] as! NSNumber))
                    
                    return cell
                case 6:
                    let cell = tableView.dequeueReusableCellWithIdentifier("SecurityCell", forIndexPath: indexPath) as! UITableViewCell
                    cell.textLabel!.text = "Security"
                    cell.detailTextLabel!.text = GlobalFunctions.getNameForSecurity((data["security"] as! NSNumber))
                    return cell
                case 7:
                    let cell = tableView.dequeueReusableCellWithIdentifier("ParentCell", forIndexPath: indexPath) as! UITableViewCell
                    // cell.textLabel!.text = "Size"
                    if (data["parent_name"] != nil){
                        cell.detailTextLabel!.text = (data["parent_name"] as! String)
                        
                    }
                    else{
                        cell.detailTextLabel!.text = ""
                        
                    }
                    return cell
                    
                default:
                    var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UITableViewCell
                    return cell
                }
                
                
            }
                
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ReadOnlyCell", forIndexPath: indexPath) as! UITableViewCell
                switch (indexPath.row){
                case 0:
                    cell.textLabel!.text = "Name"
                    cell.detailTextLabel!.text = data["name"] as? String
                    break
                case 1:
                    cell.textLabel!.text = "Contact Name"
                    cell.detailTextLabel!.text = data["contact_name"] as? String
                    break
                case 2:
                    cell.textLabel!.text = "Contact Email"
                    cell.detailTextLabel!.text = data["contact_email"] as? String
                    break
                case 3:
                    cell.textLabel!.text = "Contact Mobile"
                    cell.detailTextLabel!.text = data["contact_mobile"] as? String
                    break
                case 4:
                    cell.textLabel!.text = "Size"
                    cell.detailTextLabel!.text = (data["size"] as! NSNumber).stringValue
                    break
                case 5:
                    cell.textLabel!.text = "Type"
                    cell.detailTextLabel!.text = GlobalFunctions.getNameForDevelopment((data["development"] as! NSNumber))
                    break
                case 6:
                    cell.textLabel!.text = "Size"
                    cell.detailTextLabel!.text = GlobalFunctions.getNameForSecurity((data["security"] as! NSNumber))
                    break
                case 7:
                    cell.textLabel!.text = "Parent"
                    if (data["parent_name"] != nil){
                        cell.detailTextLabel!.text = (data["parent_name"]as! String)
                        
                    }
                    else{
                        cell.detailTextLabel!.text = ""
                        
                    }
                    return cell
                    
                default:
                    var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UITableViewCell
                    return cell
                }
                
                return cell
                
            }
            
            
            
        }
        else {
            
            
            //println(data)
            
            var cell = UITableViewCell()
            
            switch(indexPath.row){
                
                
            case 0:
                
                if (data["marker_type"] as! String == "new_church"){
                    
                }
                else{
                    
                    if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false){
                        cell = tableView.dequeueReusableCellWithIdentifier("MoveCell", forIndexPath: indexPath) as! UITableViewCell
                        
                    }
                    
                }
                
                
                
            case 1:
                
                var cell = UITableViewCell()
                
                if (data["marker_type"] as! String == "new_church"){
                    
                }
                else {
                    
                    
                    if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false){
                        cell = tableView.dequeueReusableCellWithIdentifier("DeleteCell", forIndexPath: indexPath) as! UITableViewCell
                        
                    }
                    
                }
                
            default:
                var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as! UITableViewCell
                
                
            }
            
            return cell
        }
        
        
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.view.endEditing(true)
        
        if indexPath.section == 1{
            
            self.tableView.resignFirstResponder()
            
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC)))
            
            switch(indexPath.row){
            case 0: // move
                
                
                if created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  data["ministry_id"] as! String && read_only == false) {
                    
                    self.mapVC.makeSelectedMarkerDraggable()
                    self.navigationController?.popViewControllerAnimated(true)
                    
                }
                
                break
            case 1: // delete
                
                self.tableView.reloadRowsAtIndexPaths(
                    [indexPath],
                    withRowAnimation:UITableViewRowAnimation.None)
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated:false)
                
                
                var alertController = UIAlertController(title: "", message: "Are you sure you want to delete this church?", preferredStyle: .Alert)
                
                // Create the actions
                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    
                    NSLog("OK Pressed")
                    
                    
                    if(self.data["marker_type"] as! String != "new_church"){
                        
                        if self.created_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as? String || (NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String ==  self.data["ministry_id"] as! String && self.read_only == false){
                            
                            self.navigationController?.popViewControllerAnimated(true)
                            
                            let notificationCenter = NSNotificationCenter.defaultCenter()
                            notificationCenter.postNotificationName(GlobalConstants.kShouldDeleteChurch, object: nil, userInfo: self.data as JSONDictionary)
                            
                        }
                        
                    }
                    
                }
                var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    
                    NSLog("Cancel Pressed")
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
                
                break
            
            default:
                break
                
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    // MARK:- UITextField delegate method
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 4
        let currentString: NSString = textField.text
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        switch segue.identifier!{
        case "ShowDevelopment":
            let tvc = segue.destinationViewController as! DevelopmentTVC
            tvc.church = self
            break
        case "ShowSecurity":
            let tvc = segue.destinationViewController as! SecurityTVC
            tvc.church = self
        case "ShowParent":
            let tvc = segue.destinationViewController as! ParentTVC
            tvc.church = self
            tvc.parent_church_id = data["parent_id"] as! NSNumber?
            tvc.this_church_id = data["id"] as! NSNumber
            break
        default:
            break
        }
    }
}
