//
//  ParentTVC.swift
//  gcmapp
//
//  Created by Jon Vellacott on 29/01/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit
import CoreData
class ParentTVC: UITableViewController, NSFetchedResultsControllerDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    var this_church_id: NSNumber!
    var parent_church_id: NSNumber?
    var church:ChurchTVC!
   
    
       func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest =  NSFetchRequest(entityName:"Church" )

        fetchRequest.predicate = NSPredicate(format: "id != %@", this_church_id )
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        fetchedResultController.performFetch(nil)
        
        //tableView.selectRowAtIndexPath(self.selected_index_path, animated: false, scrollPosition: UITableViewScrollPosition.None)
        
        var selected_parent =  fetchedResultController.fetchedObjects?.filter{($0 as Church).id == (self.parent_church_id)} as [Church]
        
        
     //   println(fetchedResultController.indexPathForObject(selected_parent.first!))
        tableView.scrollToRowAtIndexPath(fetchedResultController.indexPathForObject(selected_parent.first!)!, atScrollPosition: UITableViewScrollPosition.None, animated: true)
      // tableView.selectRowAtIndexPath(fetchedResultController.indexPathForObject(selected_parent.first!), animated: false, scrollPosition: UITableViewScrollPosition.None)
        //tableView.reloadData()
    }
    

 
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections![0].numberOfObjects!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let church = fetchedResultController.objectAtIndexPath(indexPath) as Church
        
        //cell.selected=(church.id == self.parent_church_id)
        if(church.id == self.parent_church_id){
       
             var cell = tableView.dequeueReusableCellWithIdentifier("ParentSelectedCell", forIndexPath: indexPath) as UITableViewCell
           cell.selected = true
            cell.textLabel!.text = church.name

            return cell
            //cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
          //  cell.backgroundColor = UIColor(red: 123.0/255.0, green: 156.0/255.0, blue: 210.0/255.0, alpha: 1.0)
       
        }
        else{
             var cell = tableView.dequeueReusableCellWithIdentifier("ParentListCell", forIndexPath: indexPath) as UITableViewCell
            cell.selected = false
            cell.textLabel!.text = church.name

            return cell
            //cell.backgroundColor = UIColor.clearColor()
        }
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selected = fetchedResultController.objectAtIndexPath(indexPath) as Church
        if(selected.id != parent_church_id){
            church.data["parent_id"] = selected.id
            church.data["parent_name"] = selected.name
            church.changed = true
             church.tableView.reloadData()
        }
       
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
