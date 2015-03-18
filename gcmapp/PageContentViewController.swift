//
//  PageContentViewController.swift
//  gcmapp
//
//  Created by Mark Briggs on 3/7/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit
import CoreData
class PageContentViewController: UIViewController, UITextFieldDelegate {

    var measurement: Measurements?
    
    var pageIndex: Int?
    //var titleText : String!
    //var imageName : String!
    
    var measurementType : Int!
    
    var measurementDescription: String!

    //var totalValue: String!
    var localValue: String!
    var personValue: String!
    var subTotalValue: Int!
   
    var hack: Hack1ViewController!
    
    @IBOutlet var busySpinner: UIActivityIndicatorView!
    
    //@IBOutlet weak var measurementDescriptionLbl: UITextView!
    @IBOutlet weak var measurementDescriptionLbl: UILabel!
    //@IBOutlet weak var measurementValueLbl: UILabel!
    //@IBOutlet weak var totalValueBtn: UIButton!
    
    
    
    
    @IBAction func localChanged(sender: UITextField) {
        if sender.text != ""{
            saveLocal()
            
        }
    
    }
    @IBAction func personChanged(sender: UITextField){
        if sender.text != ""{
            savePerson()
        }
    }

    @IBOutlet weak var localValueBtn: UIButton!
    @IBOutlet weak var personValueBtn: UIButton!
    
    @IBOutlet weak var lblPersonValue: UITextField!
    
    @IBOutlet weak var lblLocalValue: UITextField!
    
    @IBAction func incrBtn(sender: UIButton) {
        var newValStr = ""
        
        if localPersonChooser.selectedSegmentIndex == 0 {
            if var i = lblLocalValue.text.toInt() {
                newValStr = String(++i)
            }
           
            lblLocalValue.text = newValStr
             saveLocal()
        } else {
            if var i = lblPersonValue.text.toInt() {
                newValStr = String(++i)
            }
           
            lblPersonValue.text = newValStr
            savePerson()
        }
    }
    
    @IBAction func decrBtn(sender: UIButton) {
        var newValStr = ""
        
        if localPersonChooser.selectedSegmentIndex == 0 {
            if var i = lblLocalValue.text.toInt() {
                newValStr = String(--i)
            }
             lblLocalValue.text = newValStr
            saveLocal()
        } else {
            if var i = lblPersonValue.text.toInt() {
                newValStr = String(--i)
            }
           // personValueBtn.setTitle(newValStr, forState: UIControlState.Normal)
             lblPersonValue.text = newValStr
            savePerson()
        }
    }
    
    
    func getLiveTotal() -> String{
        return String(self.subTotalValue + localValue.toInt()! + personValue.toInt()!)
    }
    
    func saveLocal(){
        if localValue != lblLocalValue.text{
            var values = self.measurement!.measurementValue
        
            var period = NSUserDefaults.standardUserDefaults().objectForKey("period") as String
            var periodVals = values.filteredSetUsingPredicate(NSPredicate(format: "period = %@", period)!)
            var valueForThisPeriod = periodVals.allObjects.first as MeasurementValue
            
            localValue = lblLocalValue.text
            hack.setTotal(self.measurementType)

            valueForThisPeriod.local = lblLocalValue.text.toInt()!
            valueForThisPeriod.changed = true
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            let managedContext = appDelegate.managedObjectContext!
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
        }
        
    }
    func savePerson(){
        if personValue != lblPersonValue.text{
            
            var values = self.measurement!.measurementValue
            
            var period = NSUserDefaults.standardUserDefaults().objectForKey("period") as String
            var periodVals = values.filteredSetUsingPredicate(NSPredicate(format: "period = %@", period)!)
            var valueForThisPeriod = periodVals.allObjects.first as MeasurementValue
            
            personValue = lblPersonValue.text
            hack.setTotal(self.measurementType)
            valueForThisPeriod.me = lblPersonValue.text.toInt()!
            valueForThisPeriod.changed = true
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            let managedContext = appDelegate.managedObjectContext!
            var error: NSError?
            
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
        }
    }
    
    
    
    @IBOutlet weak var localPersonChooser: UISegmentedControl!
    
    @IBOutlet weak var wbsCategory: UILabel!
    
    @IBAction func localPersonChooserChanged(sender: UISegmentedControl) {
        println("localPersonChooserChanged")
        if sender.selectedSegmentIndex == 0 {
            onLocalSelected()
            /*
            localValueBtn.hidden = false
            personValueBtn.hidden = true
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "LocalPersonChooserState")
            */
        } else {
            onPersonSelected()
            /*
            localValueBtn.hidden = true
            personValueBtn.hidden = false
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "LocalPersonChooserState")
            */
        }
    }
    
    func onLocalSelected() {
        localValueBtn.hidden = false
        personValueBtn.hidden = true
        lblPersonValue.hidden = true
        lblLocalValue.hidden = false
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "LocalPersonChooserState")
    }
    
    func onPersonSelected() {
        localValueBtn.hidden = true
        personValueBtn.hidden = false
        lblPersonValue.hidden = false
        lblLocalValue.hidden = true
        NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "LocalPersonChooserState")
    }
    
    @IBAction func onLocalValueBtnClicked(sender: UIButton) {
        
        println("onLocalValueBtnClicked")
    }
    
    @IBAction func onPersonValueBtnClicked(sender: UIButton) {
        println("onPersonValueBtnClicked")
    }
    
    func dismissKeyboard(){
        lblLocalValue.resignFirstResponder()
        lblPersonValue.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.busySpinner.hidesWhenStopped = true
        
        personValueBtn.hidden = true
        lblPersonValue.delegate = self
        lblLocalValue.delegate = self
        
        var tap = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
       
        self.view.addGestureRecognizer(tap)
        
        
        let nc = NSNotificationCenter.defaultCenter()
        let myQueue = NSOperationQueue()
        var observer = nc.addObserverForName(GlobalConstants.kDidReceiveMeasurements, object: nil, queue: myQueue) {(notification:NSNotification!) in
         
            let fetchRequest =  NSFetchRequest(entityName:"MeasurementValue")
            
            var period = NSUserDefaults.standardUserDefaults().objectForKey("period") as String
            // where ministry_id = X
            if self.measurement!.id_total == nil {
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
              
                self.localValue = results?.first?.local.stringValue
                self.personValue = results?.first?.me.stringValue
                  //self.totalValue = String((results?.first?.subtotal.integerValue as Int!) + (results?.first?.local.integerValue as Int!) + (results?.first?.me.integerValue as Int!))
                self.subTotalValue = results?.first?.subtotal.integerValue
            } else {
                
                println("... no values for current period: \(period)")
                //self.totalValue = "??"
            }
            
           // self.totalValueBtn.setTitle(self.totalValue, forState: UIControlState.Normal)
           // self.localValueBtn.setTitle(self.localValue, forState: UIControlState.Normal)
//            /self.personValueBtn.setTitle(self.personValue, forState: UIControlState.Normal)
            self.lblPersonValue.text = self.personValue
            self.lblLocalValue.text = self.localValue
        }
        
        // ==== local/person Chooser
        
        // Font
        /*
        let font = UIFont(name: "Roboto-Regular", size: 20.0)
        var attributes = Dictionary<String, UIFont>()
        attributes[NSFontAttributeName] = font
        self.periodControl.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        var f = self.periodControl.frame
        self.periodControl.frame = CGRectMake(f.origin.x, f.origin.y, f.width, 40.0)
        */
        
        
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
        //self.totalValue = valueForThisPeriod.total.stringValue
        self.localValue = valueForThisPeriod.local.stringValue
        self.personValue = valueForThisPeriod.me.stringValue
        self.subTotalValue  = valueForThisPeriod.subtotal.integerValue
        //measurementValueLbl.text = measurementValue
        //measurementValueBtn.titleLabel!.text = measurementValue
        //totalValueBtn.setTitle(totalValue, forState: UIControlState.Normal)
        //localValueBtn.setTitle(localValue, forState: UIControlState.Normal)
       // personValueBtn.setTitle(personValue, forState: UIControlState.Normal)
         self.lblPersonValue.text = personValue
        self.lblLocalValue.text = self.localValue
    }
    
    override func viewWillAppear(animated: Bool) {
        println("viewWillAppear")
        let state = NSUserDefaults.standardUserDefaults().integerForKey("LocalPersonChooserState")

        selectLocalPersonProgrammatically(state)
        
        /*
        localPersonChooser.selectedSegmentIndex = state

        if state == 0 {
            self.onLocalSelected()
        } else {
            self.onPersonSelected()
        }
        */
    }
    
    func selectLocalPersonProgrammatically(state:Int) {
        localPersonChooser.selectedSegmentIndex = state
        
        if state == 0 {
            self.onLocalSelected()
        } else {
            self.onPersonSelected()
        }
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
   
    
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//    {
//        println(textField.text)
//        if textField == lblLocalValue && textField.text != ""{
//            saveLocal()
//        }
//        return true
//    }
    
    /*
    func getLocalPersonChooserState() -> Int {
        return localPersonChooser.selectedSegmentIndex  // 0=>LOCAL, 1=>PERSON
    }
    */
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
