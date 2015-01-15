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
       
        var search_this_period = (measurement.measurementValue.allObjects.filter {$0.period == self.period})
        if search_this_period.count>0{
            self.this_period_values = search_this_period[0] as MeasurementValue
        }
        else{
            self.this_period_values = nil
        }

        
    }
    
    func backButtonClicked(sender: AnyObject){
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
                cell.editValue.text = self.this_period_values.me.stringValue
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