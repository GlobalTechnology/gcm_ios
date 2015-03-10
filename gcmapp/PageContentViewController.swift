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
    
    
    //@IBOutlet weak var measurementDescriptionLbl: UITextView!
    @IBOutlet weak var measurementDescriptionLbl: UILabel!
    //@IBOutlet weak var measurementValueLbl: UILabel!
    @IBOutlet weak var measurementValueBtn: UIButton!

    
    @IBOutlet weak var wbsCategory: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        let nc = NSNotificationCenter.defaultCenter()
        let myQueue = NSOperationQueue.mainQueue()
        var observer = nc.addObserverForName(GlobalConstants.kDidReceiveMeasurements, object: nil, queue: myQueue) {(notification:NSNotification!) in
         
            let fetchRequest =  NSFetchRequest(entityName:"MeasurementValue")
            
            var period = NSUserDefaults.standardUserDefaults().objectForKey("period") as String
            // where ministry_id = X
            if self.measurement!.id_total == nil{
                println("error: \(self.measurement!.name)")
                return;
            } else {
                println("total: \(self.measurement!.id_total!)")
                fetchRequest.predicate = NSPredicate(format: "measurement.id_total = %@ && period = %@", self.measurement!.id_total!, period)
            }
            
            
            
            
            
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            //self.managedContext = appDelegate.managedObjectContext!
            
            // sort by sort order
            //   column = [Faith, Fruit, Outcomes]
            
            // now run the fetchRequest (Query)
            var error: NSError?
            let results = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest,error: &error) as [MeasurementValue]?

            if results!.count > 0 {
                self.measurementValue = results?.first?.total.stringValue
                self.measurementValueBtn.setTitle(self.measurementValue, forState: UIControlState.Normal)
            }
            
        }

        
        
        measurementDescriptionLbl.text = measurementDescription
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
