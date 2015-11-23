//
//  mccViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 05/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit
import CoreData

class mccViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MccCell", forIndexPath: indexPath) as! UITableViewCell
        
        switch(indexPath.row){
        case 0:
            cell.detailTextLabel?.text = "SLM"
            cell.textLabel!.text = "Student Led"
        case 1:
            cell.detailTextLabel?.text = "LLM"
            cell.textLabel!.text = "Leader Led"
        case 2:
            cell.detailTextLabel?.text = "GCM"
            cell.textLabel!.text = "Global Church Movements"
        case 3:
            cell.detailTextLabel?.text = "DS"
            cell.textLabel!.text = "Digital Strategies"
        default:
            cell.detailTextLabel?.text = ""
            cell.textLabel!.text = ""
        }
        var error: NSError?
        
        
        if let ministryID = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String {
            
            let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
            fetchRequest.predicate=NSPredicate(format: "id = %@", ministryID )
            let fetchedResults =  managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [Ministry]
            if fetchedResults.count > 0{
                if let ministry:Ministry = fetchedResults.first {
                    
                    switch(indexPath.row){
                    case 0:
                        cell.userInteractionEnabled = (ministry.has_slm as Bool)
                        cell.textLabel!.textColor = (ministry.has_slm as Bool) ? UIColor.blackColor() :  UIColor.lightGrayColor()
                   
                    case 1:
                        cell.userInteractionEnabled = (ministry.has_llm as Bool)
                        cell.textLabel!.textColor = (ministry.has_llm as Bool) ? UIColor.blackColor() :  UIColor.lightGrayColor()
                    case 2:
                        cell.userInteractionEnabled = (ministry.has_gcm as Bool)
                        cell.textLabel!.textColor = (ministry.has_gcm as Bool) ? UIColor.blackColor() :  UIColor.lightGrayColor()
                    case 3:
                        cell.userInteractionEnabled = (ministry.has_ds as Bool)
                        cell.textLabel!.textColor = (ministry.has_ds as Bool) ? UIColor.blackColor() :  UIColor.lightGrayColor()
                    default:
                        cell.userInteractionEnabled = false
                        cell.textLabel!.textColor = UIColor.lightGrayColor()
                    }
                    
                }
                
            } // end if fetchedResults
        }  else {
            
            //// TODO: what should happen when we don't have a ministry ID?
            //println("mccViewController.tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:):")
            //println("... called when we don't have a ministry_id set.  Why?")
        }
        
        return cell
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var error: NSError?
        self.title = "MCC"
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var mcc:String!
        var mcc_name:String!
        switch(indexPath.row){
        case 0:
            mcc = "SLM"
            mcc_name = "Student Led"
        case 1:
            mcc = "LLM"
            mcc_name = "Leader Led"
        case 2:
            mcc = "GCM"
            mcc_name = "Global Church Movements"
        case 3:
            mcc = "DS"
            mcc_name = "Digital Strategies"
        default:
            mcc = ""
            mcc_name = ""
        }
        
        
        NSUserDefaults.standardUserDefaults().setObject(mcc, forKey: "mcc")
        NSUserDefaults.standardUserDefaults().setObject(mcc_name, forKey: "mcc_name")
        
        NSUserDefaults.standardUserDefaults().synchronize()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(GlobalConstants.kDidChangeMcc, object: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
        
        NSNotificationCenter.defaultCenter().postNotificationName("showLoaderInSetting", object: nil)
    }
}
