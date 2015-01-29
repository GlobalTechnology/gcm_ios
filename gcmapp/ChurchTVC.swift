//
//  ChurchTVC.swift
//  gcmapp
//
//  Created by Jon Vellacott on 28/01/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit
import CoreData
class ChurchTVC: UITableViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var Icon: UIImageView!
    var data:JSONDictionary!
    
    var changed:Bool = false
    var mapVC:  mapViewController!
    
    @IBAction func btnClose(sender: UIButton) {
        //Save Church
        self.SaveChanges()
        mapVC.redrawMap()
        

        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnMove(sender: UIButton) {
        //find church and make it
        self.SaveChanges()
        self.mapVC.makeSelectedMarkerDraggable()
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    @IBAction func btnSetParent(sender: UIButton) {
    }
    
    
    func SaveChanges() {
        if(changed){
            let fetchRequest = NSFetchRequest(entityName:"Church")
            
            var error: NSError?
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            let managedContext = appDelegate.managedObjectContext!
            fetchRequest.predicate = NSPredicate(format: "id = %@", data["id"] as NSNumber)
            let church = managedContext.executeFetchRequest(fetchRequest, error: &error) as [Church]
            if church.count>0{
                church.first!.changed=true
                church.first!.name=data["name"] as String
                church.first!.contact_name=data["contact_name"] as String
                church.first!.contact_email=data["contact_email"] as String
                church.first!.size=data["size"] as NSNumber
                church.first!.development=data["development"] as NSNumber
                church.first!.security=data["security"] as NSNumber
                if data["parent_id"] != nil {
                    
                    if( (church.first!.parent_id != data["parent_id"] as NSNumber)){
                        
                        //parent_id has changed
                        //lookup parent...
                        let fetchRequest2 = NSFetchRequest(entityName:"Church")
                        fetchRequest2.predicate = NSPredicate(format: "id = %@", data["parent_id"] as NSNumber)
                        let parent = managedContext.executeFetchRequest(fetchRequest2, error: &error) as [Church]
                        if parent.count>0{
                            church.first!.parent = parent.first!
                            church.first!.parent_id = data["parent_id"] as NSNumber
                        }
                        
                        
                        
                        
                    }
                    
                }
                
            }
            
            
            
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(GlobalConstants.kDidChangeChurch, object: nil)
        
    }
    
}

override func viewDidLoad() {
    super.viewDidLoad()
    
    
    name.text = data["name"] as? String
    Icon.image = UIImage(named: mapViewController.getIconNameForChurch(data["development"] as NSNumber))
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
    return 1
}

override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 7
}


override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    // Configure the cell...
    switch (indexPath.row){
    case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as UIEditTextCell
        cell.title.text = "Name"
        cell.value.text = data["name"] as? String
        cell.field_name = "name"
        cell.church=self
        return cell
    case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as UIEditTextCell
        cell.title.text = "Contact Name"
        cell.value.text = data["contact_name"] as? String
        cell.field_name = "contact_name"
        cell.church=self
        return cell
    case 2:
        let cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as UIEditTextCell
        cell.title.text = "Contact Email"
        cell.value.text = data["contact_email"] as? String
        cell.field_name = "contact_email"
        cell.church=self
        return cell
    case 3:
        let cell = tableView.dequeueReusableCellWithIdentifier("EditNumberCell", forIndexPath: indexPath) as UIEditTextCell
        cell.title.text = "Size"
        cell.value.text = (data["size"] as NSNumber).stringValue
        cell.field_name = "size"
        cell.church=self
        return cell
    case 4:
        let cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as UITableViewCell
        // cell.textLabel!.text = "Type"
        cell.detailTextLabel!.text = GlobalFunctions.getNameForDevelopment((data["development"] as NSNumber))
        
        return cell
    case 5:
        let cell = tableView.dequeueReusableCellWithIdentifier("SecurityCell", forIndexPath: indexPath) as UITableViewCell
        // cell.textLabel!.text = "Size"
        cell.detailTextLabel!.text = GlobalFunctions.getNameForSecurity((data["security"] as NSNumber))
        return cell
    case 6:
        let cell = tableView.dequeueReusableCellWithIdentifier("ParentCell", forIndexPath: indexPath) as UITableViewCell
        // cell.textLabel!.text = "Size"
        if (data["parent_name"] != nil){
            cell.detailTextLabel!.text = (data["parent_name"]as String)
            
        }
        else{
            cell.detailTextLabel!.text = ""
            
        }
        return cell
        
    default:
        var cell = tableView.dequeueReusableCellWithIdentifier("EditTextCell", forIndexPath: indexPath) as UITableViewCell
        return cell
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


// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    switch segue.identifier!{
    case "ShowDevelopment":
        let tvc = segue.destinationViewController as DevelopmentTVC
        tvc.church = self
        break
    case "ShowSecurity":
        let tvc = segue.destinationViewController as SecurityTVC
        tvc.church = self
    case "ShowParent":
        let tvc = segue.destinationViewController as ParentTVC
        tvc.church = self
        tvc.parent_church_id = data["parent_id"]as NSNumber?
        tvc.this_church_id = data["id"] as NSNumber
        break
    default:
        break
    }
    
    
    
    
}


}
