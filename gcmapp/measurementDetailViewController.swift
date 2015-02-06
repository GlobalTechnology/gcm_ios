//
//  measurementDetailViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 09/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit

import CoreData

class measurementDetailViewController: UITableViewController {
 
    @IBOutlet weak var navBar: UINavigationBar!
    var measurement:Measurements!
    var this_period_values: MeasurementValue!
    @IBOutlet weak var NavItem: UINavigationItem!
    
    @IBOutlet weak var graph: GraphView!
    var period:String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
    }
   
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.NavItem.title = measurement.name
        self.NavItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("backButtonClicked:"))
        self.NavItem.hidesBackButton = false
        self.graph.values = measurement.measurementValue.allObjects as Array<MeasurementValue>
        
        period = (NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
       var mcc = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString
        println(mcc)
        var search_this_period = (measurement.measurementValue.allObjects as [MeasurementValue]).filter {$0.period == self.period as String && $0.mcc == mcc}
        if search_this_period.count>0{
            self.this_period_values = search_this_period[0] as MeasurementValue
        }
        else{
            self.this_period_values = nil
        }
        

        self.tableView.reloadData()
    }
    
    func backButtonClicked(sender: AnyObject){
         var error: NSError?
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        
        let managedContext = appDelegate.managedObjectContext!
        if !managedContext.save(&error) {
        println("Could not save \(error), \(error?.userInfo)")
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(GlobalConstants.kDidChangeMeasurementValues, object: nil)
        
     
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
        
    }
    
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
        case 0:
            return (NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as String) + "(Local)"
        case 1:
            return "Team Members"
        case 2:
            return "Sub-Team/Ministries"
        default:
            return ""
        }

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            
            return this_period_values.localSources.count
        case 1:
            
            return this_period_values.teamValues.count + 1
        case 2:
            return  this_period_values.subMinValues.count
        default:
            return 0
        }
        
   
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section){
        case 0:
            var localValue = self.this_period_values.localSources.allObjects[indexPath.row] as MeasurementLocalSource
            
            if localValue.name == GlobalConstants.LOCAL_SOURCE{
                var cell = tableView.dequeueReusableCellWithIdentifier("measDetailEditCell", forIndexPath: indexPath) as MeasDetailEditCell
                cell.lblTitle.text = "Local"
                cell.isLocalSource = true
                cell.mls = localValue	
                cell.editValue.text = localValue.value.stringValue
                return cell
               
            }
            else{
                var cell = tableView.dequeueReusableCellWithIdentifier("measDetailCell", forIndexPath: indexPath) as UITableViewCell
                cell.textLabel!.text = localValue.name
                cell.detailTextLabel?.text  = localValue.value.stringValue
                return cell

            }
         
        case 1:
            if indexPath.row == 0{
                var cell = tableView.dequeueReusableCellWithIdentifier("measDetailEditCell", forIndexPath: indexPath) as MeasDetailEditCell
                cell.lblTitle.text = "You"
                var mes =  (this_period_values.meSources.allObjects as [MeasurementMeSource]).filter {$0.name == GlobalConstants.LOCAL_SOURCE as String}
                if mes.count==0{
                    var error: NSError?
                    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext!
                    let entity =  NSEntityDescription.entityForName( "MeasurementMeSource", inManagedObjectContext: managedContext)
                    
                    var ms =  NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as MeasurementMeSource
                    ms.measurementValue = this_period_values
                    ms.name = GlobalConstants.LOCAL_SOURCE
                    ms.changed = false
                    ms.value = 0
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    cell.me = ms
                }
                else{
                    cell.me = mes.first!
                }
                cell.editValue.text = cell.me.value.stringValue
                cell.isLocalSource = false
                
                return cell
            }
            else{
                var cell = tableView.dequeueReusableCellWithIdentifier("measDetailCell", forIndexPath: indexPath) as UITableViewCell
                let tm = (self.this_period_values.teamValues.allObjects[indexPath.row-1] as MeasurementValueTeam)
                cell.textLabel!.text = tm.first_name + " " + tm.last_name
                cell.detailTextLabel?.text  = tm.total.stringValue
                return cell

            }
            
        case 2:
            var cell = tableView.dequeueReusableCellWithIdentifier("measDetailCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel!.text = (self.this_period_values.subMinValues.allObjects[indexPath.row] as MeasurementValueSubTeam).name
            cell.detailTextLabel?.text  = (self.this_period_values.subMinValues.allObjects[indexPath.row] as MeasurementValueSubTeam).total.stringValue
            return cell
        default:
            var cell = tableView.dequeueReusableCellWithIdentifier("measDetailCell", forIndexPath: indexPath) as UITableViewCell
            return cell
        }
    }
}
