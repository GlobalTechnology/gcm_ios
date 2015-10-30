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
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    var mcc:String!
    var period:String!
    var self_assigned: Bool = true
    private let notificationManager = NotificationManager()  // manage notification

    @IBOutlet var menuButton: UIBarButtonItem!

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
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kDidChangePeriod, object: nil)
            case 2:
                period = GlobalFunctions.nextPeriod(period)
                NSUserDefaults.standardUserDefaults().setObject(period, forKey: "period")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.updatePeriodControl()
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kDidChangePeriod, object: nil)
	
            default:
                break
        }
        
    }
    
    
    func updatePeriodControl(){
        
        // team_role might be undefined
        if let team_role =  NSUserDefaults.standardUserDefaults().objectForKey("team_role") as? String {
            self.self_assigned = team_role == "self_assigned"
        } else {
            self.self_assigned = true
        }
        
        lblSubTitle.hidden = !self_assigned
        self.tableView.allowsSelection = !self_assigned
        
        
        let currMcc = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String).lowercaseString
        mcc = currMcc
        
        
        // ministry_name might be undefined
        if let ministryName = NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as? String {
            lblTitle.text = (ministryName) + "(" + currMcc + ")"
        } else {
            lblTitle.text = "Self Assigned" + "(" + currMcc + ")"
        }
        
        periodControl.setEnabled(period != GlobalFunctions.currentPeriod(), forSegmentAtIndex: 2)
        self.periodControl.setTitle(period, forSegmentAtIndex: 1)
        tableView.reloadData()
        
    }
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: "column", cacheName: nil)
        return fetchedResultController
    }
    
    func taskFetchRequest() -> NSFetchRequest {
    
    //println(" ++++++ measurementsController.taskFetchRequest() ++++++++")
        
        // It is possible for the current user to not have a ministry_id defined 
        // so check first:
        if let ministryId=NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String? {
            
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
            
        } else {
  
            // so ... return a blank NSFetchRequest??
            let fetchRequest =  NSFetchRequest(entityName:"Measurements")

            fetchRequest.predicate = NSPredicate(format: "ministry_id = -1")
            
            let sortDescriptor1 = NSSortDescriptor(key: "column", ascending: true)
            let sortDescriptor2 = NSSortDescriptor(key: "sort_order", ascending: true)
            
            fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
            return  fetchRequest
        }
    }
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "last_refresh")
        NSUserDefaults.standardUserDefaults().synchronize()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        // notificationCenter.postNotificationName(GlobalConstants.kShouldRefreshAll, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
       
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        
        
        self.reloadData()
      
        notificationManager.registerObserver(GlobalConstants.kDidReceiveMeasurements , forObject: nil) { note in
        
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
            
            /*NSFetchedResultsController.deleteCacheWithName("meas")
             var error: NSError?
           
            if !self.fetchedResultController.performFetch(&error) {
                //println("Could not fetch \(error), \(error?.userInfo)")
            }
            */
            
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
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        // notificationCenter.postNotificationName(GlobalConstants.kShouldRefreshAll, object: nil)
        period = (NSUserDefaults.standardUserDefaults().objectForKey("period") as! String)
        self.updatePeriodControl()
        
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: "Measurements")
//        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])

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
        var cell = tableView.dequeueReusableCellWithIdentifier("lmiSummary2", forIndexPath: indexPath) as! MeasurementSummaryCell
        
        if fetchedResultController.fetchedObjects?.count == 0{
            return cell
        }
        let measurement:Measurements! = fetchedResultController.objectAtIndexPath(indexPath) as! Measurements
     
        let this_meas_value:[MeasurementValue] =  (measurement.measurementValue.allObjects as! [MeasurementValue]).filter {$0.period == self.period && $0.mcc == self.mcc}
        if this_meas_value.count>0{
            cell.lblDetail.text = this_meas_value.first?.total.stringValue
            
            if self_assigned{
                
                var mes =  (this_meas_value.first!.meSources.allObjects as! [MeasurementMeSource]).filter {$0.name == GlobalConstants.LOCAL_SOURCE as String}
                if mes.count==0{
                    var error: NSError?
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext!
                    let entity =  NSEntityDescription.entityForName( "MeasurementMeSource", inManagedObjectContext: managedContext)
                    
                    var ms =  NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as! MeasurementMeSource
                    ms.measurementValue = this_meas_value.first!
                    ms.name = GlobalConstants.LOCAL_SOURCE
                    ms.changed = false
                    ms.value = 0
                    if !managedContext.save(&error) {
                        //println("Could not save \(error), \(error?.userInfo)")
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
    
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
        
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {

            return !self_assigned
       
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        
        if (segue.identifier == "showMeasurementDetail") {
            // pass data to next view
            let detail:measurementDetailViewController = segue.destinationViewController as! measurementDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            detail.measurement = fetchedResultController.objectAtIndexPath(indexPath!) as! Measurements
           
        }
        

    }

}
