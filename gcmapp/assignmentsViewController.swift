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
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    
    func getFetchedResultController() -> NSFetchedResultsController {
         fetchedResultController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
        // fetchRequest.propertiesToFetch = ["id"]
        //  fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        // fetchRequest.returnsDistinctResults = true
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ministry/Team"
        tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)

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
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let ministry = fetchedResultController.objectAtIndexPath(indexPath) as! Ministry
        cell.textLabel!.text = ministry.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         let ministry = fetchedResultController.objectAtIndexPath(indexPath) as! Ministry
       
        var mapInfoDic: NSDictionary = NSDictionary(objectsAndKeys: ministry.valueForKey("id")!,"min_id",ministry.valueForKey("latitude")!,"lat",ministry.valueForKey("longitude")!,"long",ministry.valueForKey("zoom")!,"zoom" )
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlock ({
            
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(GlobalConstants.kShouldSaveUserPreferences, object: nil, userInfo: mapInfoDic as! JSONDictionary)
            
            NSUserDefaults.standardUserDefaults().synchronize()
            NSUserDefaults.standardUserDefaults().setObject(ministry.id, forKey: "ministry_id")
            NSUserDefaults.standardUserDefaults().setObject(ministry.name, forKey: "ministry_name")
            // Do heavy or time consuming work
            for a:Assignment in ministry.assignments.allObjects as! [Assignment]{
                
                if let p_id = NSUserDefaults.standardUserDefaults().objectForKey("person_id") as! String? {
                    
                    if a.person_id == p_id {
                        // if a.id != nil {
                        NSUserDefaults.standardUserDefaults().setObject(a.id, forKey: "assignment_id")
                        NSUserDefaults.standardUserDefaults().setObject(a.team_role, forKey: "team_role")
                        // } else {
                        //
                        //}
                        
                    }
                }
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kDidChangeAssignment, object: nil)
            }
        
            dispatch_async(dispatch_get_main_queue()){
                [weak self] in
                // Task 3: Return data and update on the main thread, all UI calls should be on the main thread
                if let weakSelf = self {
                    weakSelf.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        })
    }

  
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}
