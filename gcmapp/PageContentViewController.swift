//
//  PageContentViewController.swift
//  gcmapp
//
//  Created by Mark Briggs on 3/7/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit
import CoreData
class PageContentViewController: UIViewController {

    var measurement: Measurements?
    
    var pageIndex: Int?
    //var titleText : String!
    //var imageName : String!
    
    var measurementType : Int!
    
    var measurementDescription: String!
    //var measurementValue: Int!
    var measurementValue: String!
    
    @IBOutlet var busySpinner: UIActivityIndicatorView!
    
    //@IBOutlet weak var measurementDescriptionLbl: UITextView!
    @IBOutlet weak var measurementDescriptionLbl: UILabel!
    //@IBOutlet weak var measurementValueLbl: UILabel!
    @IBOutlet weak var measurementValueBtn: UIButton!

    
    @IBOutlet weak var wbsCategory: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.busySpinner.hidesWhenStopped = true
        
        
        let nc = NSNotificationCenter.defaultCenter()
        let myQueue = NSOperationQueue.mainQueue()
        var observer = nc.addObserverForName(GlobalConstants.kDidReceiveMeasurements, object: nil, queue: myQueue) {(notification:NSNotification!) in
         
            let fetchRequest =  NSFetchRequest(entityName:"MeasurementValue")
            
            var period = NSUserDefaults.standardUserDefaults().objectForKey("period") as String
            // where ministry_id = X
            if self.measurement!.id_total == nil{
                println("error: \(self.measurement!.name)")
                return;
            }
            
            
//println("id_total: \(self.measurement!.id_total!)")
            fetchRequest.predicate = NSPredicate(format: "measurement.id_total = %@ && period = %@", self.measurement!.id_total!, period)
            
            
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            // now run the fetchRequest (Query)
            var error: NSError?
            let results = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest,error: &error) as [MeasurementValue]?

            if results!.count > 0 {
                self.measurementValue = results?.first?.total.stringValue
            } else {
                
                println("... no values for current period: \(period)")
                self.measurementValue = "??"
            }
            
            self.measurementValueBtn.setTitle(self.measurementValue, forState: UIControlState.Normal)
            
        }
        
        
        // Show Busy Indicator when a Request has been started ...
        var observer_request_begin = nc.addObserverForName(GlobalConstants.kDidBeginMeasurementRequest, object: nil, queue: myQueue) {(notification:NSNotification!) in
println(" .... kDidBeginRequest : caught")
            self.busySpinner.startAnimating()
//            self.measurementValueBtn.setTitle("", forState:UIControlState.Normal)
        }
        
        
        // Stop Busy Indicator when a Request has Ended
        var observer_request_end = nc.addObserverForName(GlobalConstants.kDidEndMeasurementRequest, object: nil, queue: myQueue) {(notification:NSNotification!) in
println("... kDidEndRequest : caught")
            self.busySpinner.stopAnimating()
//            self.measurementValueBtn.setTitle(self.measurementValue, forState: UIControlState.Normal)
        }

        
        
        
        // load our Description Label == name
        measurementDescriptionLbl.text = self.measurement!.name
        
        // get the value for the current period
        var values = self.measurement!.measurementValue
        
        var period = NSUserDefaults.standardUserDefaults().objectForKey("period") as String
        var periodVals = values.filteredSetUsingPredicate(NSPredicate(format: "period = %@", period)!)
        var valueForThisPeriod = periodVals.allObjects.first as MeasurementValue
        
        println("s:\(valueForThisPeriod.total.stringValue)")
        self.measurementValue = valueForThisPeriod.total.stringValue
        
        
        //measurementValueLbl.text = measurementValue
        //measurementValueBtn.titleLabel!.text = measurementValue
        measurementValueBtn.setTitle(measurementValue, forState: UIControlState.Normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showMeasurementDetail") {
            // pass data to next view
            let detail:measurementDetailViewController = segue.destinationViewController as measurementDetailViewController
            //let indexPath = self.tableView.indexPathForSelectedRow()
            //detail.measurement = fetchedResultController.objectAtIndexPath(indexPath!) as Measurements
            detail.measurement = self.measurement!
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
