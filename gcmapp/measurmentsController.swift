//
//  measurmentsController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 09/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit
import CoreData
class measurmentsController: UITableViewController, NSFetchedResultsControllerDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    var mcc:String!
    var period:String!
    var self_assigned: Bool = true
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
  
    @IBOutlet weak var periodControl: UISegmentedControl!
    @IBAction func periodChanged(sender: UISegmentedControl) {
        switch periodControl.selectedSegmentIndex{
            case 0:
                period = GlobalFunctions.prevPeriod(period)
                NSUserDefaults.standardUserDefaults().setObject(period, forKey: "period")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.updatePeriodControl()
            case 2:
                period = GlobalFunctions.nextPeriod(period)
                NSUserDefaults.standardUserDefaults().setObject(period, forKey: "period")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.updatePeriodControl()
	
            default:
                break
        }
    }
    
    
    func updatePeriodControl(){
        
        let team_role =  NSUserDefaults.standardUserDefaults().objectForKey("team_role") as String
        
        self.self_assigned = team_role == "self_assigned"
        lblSubTitle.hidden = !self_assigned
        self.tableView.allowsSelection = !self_assigned
        mcc = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString
        lblTitle.text = (NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as String) + "(" + (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String) + ")"
        
        periodControl.setEnabled(period != GlobalFunctions.currentPeriod(), forSegmentAtIndex: 2)
        self.periodControl.setTitle(period, forSegmentAtIndex: 1)
         tableView.reloadData()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(GlobalConstants.kDidChangePeriod, object: nil)

    }
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: "column", cacheName: "meas")
        return fetchedResultController
    }
    
    func taskFetchRequest() -> NSFetchRequest {
        let ministryId=NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String
       
        
        let fetchRequest =  NSFetchRequest(entityName:"Measurements")
      /*  let pred1=NSPredicate(format: "ministry_id = %@", ministryId)
        let pred2=NSPredicate(format: "measurementValue.mcc = %@", mcc)
        let pred3=NSPredicate(format: "measurementValue.period = %@", "2014-11")*/
        
        
        
        
        
        // let pred = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType,  subpredicates: [pred1, pred2])
        
        
        fetchRequest.predicate = NSPredicate(format: "ministry_id = %@", ministryId) //NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [pred1!, pred2!, pred3!])
        
        let sortDescriptor1 = NSSortDescriptor(key: "column", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "sort_order", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        return fetchRequest
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.reloadData()
        let nc = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = nc.addObserverForName(GlobalConstants.kDidReceiveMeasurements, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            NSFetchedResultsController.deleteCacheWithName("meas")
            self.fetchedResultController.performFetch(nil)
            return
            
        }
        
       
       

    }
    
    func reloadData(){
       // fetchedResultController = NSFetchedResultsController()
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        fetchedResultController.performFetch(nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        period = (NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
        self.updatePeriodControl()

    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultController.sections!.count
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultController.sections![section].name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("lmiSummary2", forIndexPath: indexPath) as MeasurementSummaryCell
        let measurement:Measurements! = fetchedResultController.objectAtIndexPath(indexPath) as Measurements
     
        let this_meas_value:[MeasurementValue] =  (measurement.measurementValue.allObjects as [MeasurementValue]).filter {$0.period == self.period && $0.mcc == self.mcc}
        if this_meas_value.count>0{
            cell.lblDetail.text = this_meas_value.first?.total.stringValue
            
            if self_assigned{
                
                var mes =  (this_meas_value.first!.meSources.allObjects as [MeasurementMeSource]).filter {$0.name == GlobalConstants.LOCAL_SOURCE as String}
                if mes.count==0{
                    var error: NSError?
                    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext!
                    let entity =  NSEntityDescription.entityForName( "MeasurementMeSource", inManagedObjectContext: managedContext)
                    
                    var ms =  NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as MeasurementMeSource
                    ms.measurementValue = this_meas_value.first!
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
                
                cell.tbValue.text = cell.me.value.stringValue
            }
            
            
        }else{
            cell.lblDetail.text = "0"
            cell.tbValue.text = "0"
        }
        cell.lblDetail.hidden = self_assigned
        cell.tbValue.hidden = !self_assigned
        cell.accessoryType = self_assigned ? UITableViewCellAccessoryType.None : UITableViewCellAccessoryType.DisclosureIndicator
        
        cell.lblTitle.text = measurement.name
        cell.lblRow.text = measurement.section == "other" ? "" :  measurement.section.uppercaseString
        return cell
    }
    
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
        
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {

            return !self_assigned
       
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        
        if (segue.identifier == "showMeasurementDetail") {
            // pass data to next view
            let detail:measurementDetailViewController = segue.destinationViewController as measurementDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            detail.measurement = fetchedResultController.objectAtIndexPath(indexPath!) as Measurements
           
        }
        

    }

}
