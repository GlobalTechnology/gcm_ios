//
//  assignmentsViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 04/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit
import CoreData
class assignmentsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    
    func getFetchedResultController() -> NSFetchedResultsController {
         fetchedResultController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        fetchedResultController.performFetch(nil)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
         return 1
    }

 
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections![0].numberOfObjects!
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let ministry = fetchedResultController.objectAtIndexPath(indexPath) as Ministry
        cell.textLabel!.text = ministry.name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         let ministry = fetchedResultController.objectAtIndexPath(indexPath) as Ministry
        
       
        for a:Assignment in ministry.assignments.allObjects as [Assignment]{
            if a.person_id == NSUserDefaults.standardUserDefaults().objectForKey("person_id") as String?{
               // if a.id != nil {
                    NSUserDefaults.standardUserDefaults().setObject(a.id, forKey: "assignment_id")
                    
               // } else {
               //
                //}
                
            }
            
            
            
            
        }
        
        NSUserDefaults.standardUserDefaults().setObject(ministry.id, forKey: "ministry_id")
        NSUserDefaults.standardUserDefaults().setObject(ministry.name, forKey: "ministry_name")
  

        NSUserDefaults.standardUserDefaults().synchronize()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(GlobalConstants.kDidChangeAssignment, object: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)

    }


    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }
}
