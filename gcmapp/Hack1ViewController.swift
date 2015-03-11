//
//  Hack1ViewController.swift
//  gcmapp
//
//  Created by Mark Briggs on 3/7/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit
import CoreData

class Hack1ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    @IBOutlet weak var appBanner: UIImageView!
    @IBOutlet weak var ministryNameLabel: UILabel!
    @IBOutlet weak var periodControl: UISegmentedControl!
    

    //
    // The Measurement Row Views
    //

    @IBOutlet weak var measurementsViewFaith: UIView!
    @IBOutlet weak var measurementsViewFruit: UIView!
    @IBOutlet weak var measurementsViewOutcomes: UIView!
    
    
    //
    // The Height Constraint on the measurement rows
    //  - we will animate those sections using the height constraints
    //
    @IBOutlet weak var measurementsViewFaithHeight: NSLayoutConstraint!
    @IBOutlet weak var measurementsViewFruitHeight: NSLayoutConstraint!
    @IBOutlet weak var measurementsViewOutcomesHeight: NSLayoutConstraint!
    
    
    //
    // The Button Headers for the sections
    //
    @IBOutlet weak var faithHeader: UIButton!
    @IBOutlet weak var fruitHeader: UIButton!
    @IBOutlet weak var outcomesHeader: UIButton!
    
    
    //
    // Measurement Category Definitions
    //
    let FAITH = 0
    let FRUIT = 1
    let OUTCOMES = 2
    
    
    //  track which measurement row is currently displayed
    var currentlyOpenMeasurementCategory = 0

    
    //
    //  measurementsXXX : Arrays of Measurements divided by column
    //
    var measurementsFaith : [Measurements] = []
    var measurementsFruit : [Measurements] = []
    var measurementsOutcomes : [Measurements] = []
    
    
    // needed for CoreData and db access
    var managedContext: NSManagedObjectContext!
    
    
    //
    //  These are the Measurement Row Sliders
    //
    var pageViewControllerFaith : UIPageViewController!
    var pageViewControllerFruit : UIPageViewController!
    var pageViewControllerOutcomes : UIPageViewController!

    var period:String!

    
    
    func animateTransition( transitionContext: UIViewControllerContextTransitioning) {
        
        
    }
    
    
    func transitionDuration( transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
       return NSTimeInterval( )
    }
    
    /*
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    */
    
    /*
    override func shouldAutorotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) -> Bool {
    if (toInterfaceOrientation == UIInterfaceOrientation.Portrait) {
    return true
    } else {
    return false
    }
    }
    */

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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        if let ministryId=NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String? {
        
        } else {
        
            GlobalFunctions.joinMinistry(self)
            
            //// TODO: what happens here?
            println("Hack1ViewController.viewDidLoad():");
            println("... still don't have a ministry ID assigned");
            
        }

    
        //periodControl.tintColor = UIColor.clearColor()
        
        
        /*
        let nc = NSNotificationCenter.defaultCenter()
        let myQueue = NSOperationQueue()
        var observer = nc.addObserverForName(GlobalConstants.kDidReceiveMeasurements, object: nil, queue: myQueue) {(notification:NSNotification!) in
            
            self.loadData()
        }
        */
        
        
        /*
        for (NSString* family in [UIFont familyNames])
        {
            NSLog(@"%@", family);
            
            for (NSString* name in [UIFont fontNamesForFamilyName: family])
            {
                NSLog(@"  %@", name);
            }
        }
        */
        /*
        for family:String in UIFont.familyNames() {
            
        }
        */
        
        //self.periodControl.setTitle("Mar 2014", forSegmentAtIndex: 1)
        
        // ==== Segmented Control ====
        
        // Font
        let font = UIFont.boldSystemFontOfSize(20.0)
        var attributes = Dictionary<String, UIFont>()
        attributes[NSFontAttributeName] = font
        self.periodControl.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        var f = self.periodControl.frame
        self.periodControl.frame = CGRectMake(f.origin.x, f.origin.y, f.width, 40.0)
        
        /*
        [segmentControl setDividerImage:dividerimg
            forLeftSegmentState:UIControlStateNormal
            rightSegmentState:UIControlStateNormal
            barMetrics:UIBarMetricsDefault];
        */
        
        // Bar lines
        self.periodControl.setDividerImage(UIImage(named: "clearPixel"), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        
        // Bar border
        //self.periodControl.backgroundColor = UIColor.redColor()
        self.periodControl.setBackgroundImage(UIImage(named: "clearPixel"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)

        
        // Press color
        //(self.periodControl.subviews) as UIView)
        
        // Border color
        //self.periodControl.layer.borderWidth = 5
        //self.periodControl.layer.borderColor = UIColor.clearColor()
        
        // Left & Right chevron
        self.periodControl.setImage(UIImage(named: "date-control"), forSegmentAtIndex: 0)
        self.periodControl.setImage(UIImage(named: "date-control-right"), forSegmentAtIndex: 2)
        
        
        //// setup the coreData managedContext
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedContext = appDelegate.managedObjectContext!
        
        
        //// move the button header labels over
        faithHeader.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
        fruitHeader.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
        outcomesHeader.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
        
        
        //// Load our Data from the DB:
        ////   - this will initialize the 3 measurement arrays 
        ////   - do this before creating the pageViewControllerForCategory() fn below
        self.loadData()
        
        
        //// Faith
        pageViewControllerFaith = self.pageViewControllerForCategory(FAITH, view:measurementsViewFaith)
        
        
        //// Fruit 
        ////  - initially hidden
        pageViewControllerFruit = self.pageViewControllerForCategory(FRUIT, view:measurementsViewFruit)
        measurementsViewFruitHeight.constant = 0
        measurementsViewFruit.hidden = true
        
        
        //// Outcomes
        ////  - initially hidden
        pageViewControllerOutcomes = self.pageViewControllerForCategory(OUTCOMES, view:measurementsViewOutcomes)
        measurementsViewOutcomesHeight.constant = 0
        measurementsViewOutcomes.hidden = true
        
        
        // make sure the FAITH measurements are shown:
        currentlyOpenMeasurementCategory = FAITH
        openView(FAITH)
        
        
        
        
        
        
        let nc = NSNotificationCenter.defaultCenter()
        let myQueue = NSOperationQueue()
        var observer = nc.addObserverForName(GlobalConstants.kDidReceiveMeasurements, object: nil, queue: myQueue) {(notification:NSNotification!) in

            let count = self.measurementsFaith.count
            
            self.loadData()
            
            
            // if we were in a case where the existing page was displayed with 0 measurements in a section:
            if (count == 0) {
                
                // we need to rebuild the pageViewControllers:
                self.pageViewControllerFaith.removeFromParentViewController()
                self.pageViewControllerFaith = self.pageViewControllerForCategory(self.FAITH, view:self.measurementsViewFaith)
                
                self.pageViewControllerFruit = self.pageViewControllerForCategory(self.FRUIT, view:self.measurementsViewFruit)
                self.pageViewControllerOutcomes = self.pageViewControllerForCategory(self.OUTCOMES, view:self.measurementsViewOutcomes)
            }
            
            return
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // check to see if we have an active ministry_id
        if let ministryId=NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String? {
            
            
            period = (NSUserDefaults.standardUserDefaults().objectForKey("period") as String)
            updatePeriodControl()

            
            // if we don't have any data then request more info
            if (self.measurementsFaith.count < 1) {
                println("HackViewController: viewWillAppear() ")
                println("... no data so post: kDidChagePeriod")
                // (make them think we changed a period to update data)
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kDidChangePeriod, object: nil)
            }
            
            
        } else {
            
            GlobalFunctions.joinMinistry(self)
            
            //// TODO: what happens here?
            println("Hack1ViewController.viewWillAppear():");
            println("... still don't have a ministry ID assigned");
            
        }

    }
    
    
   /*
    * pageViewControllerForCategory( view: )
    *
    * Return a side scrolling UIPageViewController to manage the 
    * array of Measurements specified for category.
    *
    * view: is the UIViewController this PageViewController is held inside
    */
    func pageViewControllerForCategory( category : Int, view: UIView ) -> UIPageViewController {
        
        // make an instance of our storyboard "PageViewController"
        let pvc = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as UIPageViewController
        
        // lock in us as the dataSource for our pageViewController
        
        pvc.dataSource = self
        
        // create an initial instace
        if let pageContentViewController = self.viewControllerAtIndex(0, measurementType: category) {
            pvc.setViewControllers([pageContentViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            
            // make sure all the bounds/views are properly set
            pvc.view.frame = view.bounds
            self.addChildViewController(pvc)
            view.addSubview(pvc.view)
            pvc.didMoveToParentViewController(self)
        }
        
        
        return pvc
    }
    
    
    
    /*
     * loadData
     * 
     * Load all the Measurements from the local Data Storage
     * according to the stored "ministry_id"
     */
    func loadData() -> Void {
        
        // reset our measurement arrays to empty
        self.measurementsFaith = []
        self.measurementsFruit = []
        self.measurementsOutcomes = []
        
        
        if let ministryId=NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String? {
            
            //
            // get Ministry and display Name
            //
            
            let currMcc = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString
            
            
            // ministry_name might be undefined
            var minName : String
            if let ministryName = NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as? String {
                minName = (ministryName) + "(" + currMcc + ")"
            } else {
                minName = "Self Assigned" + "(" + currMcc + ")"
            }
           
            println("*** ministry name: \(minName)")
            ministryNameLabel.text = minName
            
            
            //
            // setup Measurements
            //
            if let measurements = self.measurementsForMinistryID(ministryId)  {
 
                // add each measurement to the right array
                for m in measurements {
                    
//                    var values = m.measurementValue
//                    
//                    var period = NSUserDefaults.standardUserDefaults().objectForKey("period") as String
//                    var periodVals = values.filteredSetUsingPredicate(NSPredicate(format: "period = %@", period)!)
//                    var valueForThisPeriod = periodVals.allObjects.first as MeasurementValue
//
//                    println("mName: \(m.name), mValue: \(valueForThisPeriod.total.stringValue)")
                    
                    

                    switch (m.column.lowercaseString) {
                        case "faith":
                            self.measurementsFaith.append(m)
                        case "fruit":
                            self.measurementsFruit.append(m)
                        case "outcome":
                            self.measurementsOutcomes.append(m)
                        default:
                            println("measurement.column[\(m.column)] not understood")
                        
                    }
                }
            }
            
            
        }
    }
    
    
    
   /*
    * measurementsForMinistryID
    *
    * return all the measurements for the ministry
    * with id = ministryID
    */
    func measurementsForMinistryID (ministryID:String) -> [Measurements]? {
        
        
        let fetchRequest =  NSFetchRequest(entityName:"Measurements")
        
        // where ministry_id = X
        fetchRequest.predicate = NSPredicate(format: "ministry_id = %@", ministryID)
        
        
        // sort by sort order
        //   column = [Faith, Fruit, Outcomes]
        let sortByOrder = NSSortDescriptor(key: "sort_order", ascending: true)
        fetchRequest.sortDescriptors = [sortByOrder]
        
        // now run the fetchRequest (Query)
        var error: NSError?
        let results = self.managedContext.executeFetchRequest(fetchRequest,error: &error) as [Measurements]?
        
        
        return results!
    }
    
    
    
    /* 
     * pageViewController(pageViewController: viewControllerAfterViewController)
     * (UIPageViewControllerDataSource)
     *
     * called when the UIPageViewController  swipes right.
     * 
     * this will return the next UIViewController after the current one provided, or nil if at end.
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        println("pageViewControllerAFTER")
        
        let pcvc = viewController as PageContentViewController
        
        var cnt:Int = 1
        switch (pcvc.measurementType) {
        case FAITH:
            cnt = measurementsFaith.count
        case FRUIT:
            cnt = measurementsFruit.count
        case OUTCOMES:
            cnt = measurementsOutcomes.count
        default:
            cnt = 1
        }
        
        var index = (viewController as PageContentViewController).pageIndex!
        index++
        if(index >= cnt){
            return nil
        }
        return self.viewControllerAtIndex(index, measurementType: pcvc.measurementType)
    }
    
    
    
    /*
    * pageViewController(pageViewController: viewControllerBeforeViewController)
    * (UIPageViewControllerDataSource)
    *
    * called when the UIPageViewController  swipes left.
    *
    * this will return the next UIViewController before the current one provided, or nil if at beginning.
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        println("pageViewControllerBEFORE")
        
        let pcvc = viewController as PageContentViewController
        
        var index = (viewController as PageContentViewController).pageIndex!
        if(index <= 0){
            return nil
        }
        index--
        return self.viewControllerAtIndex(index, measurementType: pcvc.measurementType)
    }
    
    
    
   /*
    * viewControllerAtIndex(index: measurementType)
    *
    * return a new UIViewController for the current index
    *
    */
    func viewControllerAtIndex(index : Int, measurementType: Int) -> UIViewController? {
        println("viewControllerAtIndex: \(index), measurementType: \(measurementType)")
        
        //// Find the right set of measurements to work with:
        var measurements : [Measurements]
        switch (measurementType) {
            case FAITH:
                measurements = self.measurementsFaith
            case FRUIT:
                measurements = self.measurementsFruit
            case OUTCOMES:
                measurements = self.measurementsOutcomes
            default:
                measurements = self.measurementsFaith
        }
        
        
        // if we don't have any or we are past the end  --> stop
        if((measurements.count == 0) || (index >= measurements.count)) {
            return nil
        }
        
        
        // create a new PageContentViewController to be displayed by the Scroller
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as PageContentViewController
        
        
        // assign the current measurement's details to this new PCVC
        pageContentViewController.measurementType = measurementType
        
        //
        pageContentViewController.measurementDescription = measurements[index].name
        
        pageContentViewController.measurement = measurements[index]
        
        // get the value for the current period
        var values = measurements[index].measurementValue

        var period = NSUserDefaults.standardUserDefaults().objectForKey("period") as String
        var periodVals = values.filteredSetUsingPredicate(NSPredicate(format: "period = %@", period)!)
        var valueForThisPeriod = periodVals.allObjects.first as MeasurementValue
        
        println("s:\(valueForThisPeriod.total.stringValue)")
        pageContentViewController.measurementValue = valueForThisPeriod.total.stringValue
        
        
        pageContentViewController.pageIndex = index
        
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        //println("presentationCountForPageViewController: \(cnt)")
        
        let pcvc = pageViewController.viewControllers[0] as PageContentViewController
        var cnt:Int = 1
        switch (pcvc.measurementType) {
        case FAITH:
            cnt = measurementsFaith.count
        case FRUIT:
            cnt = measurementsFruit.count
        case OUTCOMES:
            cnt = measurementsOutcomes.count
        default:
            cnt = 1
        }
        
        println("presentationCountForPageViewController: \(cnt)")
        return cnt
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func faithHeaderTouched(sender: UIButton) {
        if (currentlyOpenMeasurementCategory == FAITH) {
            return
        }
        
        closeView(currentlyOpenMeasurementCategory)
        openView(FAITH)
        
        
        currentlyOpenMeasurementCategory = FAITH
    }
    @IBAction func fruitHeaderTouched(sender: UIButton) {
        if (currentlyOpenMeasurementCategory == FRUIT) {
            return
        }
        
        closeView(currentlyOpenMeasurementCategory)
        openView(FRUIT)
        
        
        currentlyOpenMeasurementCategory = FRUIT
    }
    @IBAction func outcomesHeaderTouched(sender: UIButton) {
        if (currentlyOpenMeasurementCategory == OUTCOMES) {
            return
        }
        
        closeView(currentlyOpenMeasurementCategory)
        openView(OUTCOMES)
        
        
        currentlyOpenMeasurementCategory = OUTCOMES
    }
    
    func closeView(viewType:Int) {
        var constraint: NSLayoutConstraint
        var mView: UIView
        
        switch (viewType) {
        case FAITH:
            constraint = measurementsViewFaithHeight
            mView = measurementsViewFaith
        case FRUIT:
            constraint = measurementsViewFruitHeight
            mView = measurementsViewFruit
        case OUTCOMES:
            constraint = measurementsViewOutcomesHeight
            mView = measurementsViewOutcomes
        default:
            constraint = measurementsViewFaithHeight
            mView = measurementsViewFaith
        }
        
        constraint.constant = 0
        mView.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.5, animations: { () in
            self.view.layoutIfNeeded()
            mView.alpha = 0
        })
    }
    
    func openView(viewType:Int) {
        var heightConstraint: NSLayoutConstraint
        var mView: UIView
        var viewsHeaderTop: UIButton
        var viewsHeaderBottom: UIButton?
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        switch (viewType) {
        case FAITH:
            heightConstraint = measurementsViewFaithHeight
            mView = measurementsViewFaith
            viewsHeaderTop = self.faithHeader
            viewsHeaderBottom = self.fruitHeader
        case FRUIT:
            heightConstraint = measurementsViewFruitHeight
            mView = measurementsViewFruit
            viewsHeaderTop = self.fruitHeader
            viewsHeaderBottom = self.outcomesHeader
        case OUTCOMES:
            heightConstraint = measurementsViewOutcomesHeight
            mView = measurementsViewOutcomes
            viewsHeaderTop = self.outcomesHeader
            viewsHeaderBottom = nil
        default:
            heightConstraint = measurementsViewFaithHeight
            mView = measurementsViewFaith
            viewsHeaderTop = self.faithHeader
            viewsHeaderBottom = self.fruitHeader
        }
        
        mView.hidden = false
        
        heightConstraint.constant = screenSize.height -
                                    //(faithHeader.frame.height * 3) -
                                    (faithHeader.imageView!.frame.height * 3) -
                                    tabBarController!.tabBar.frame.height -
                                    UIApplication.sharedApplication().statusBarFrame.size.height -
                                    periodControl.frame.height -
                                    appBanner.frame.height
        
        println("heightConstraint.constant: \(heightConstraint.constant)")
        println("screenSize.height \(screenSize.height)")
        println("(faithHeader.frame.height * 3) \(faithHeader.frame.height * 3)")
        println("tabBarController!.tabBar.frame.height \(tabBarController!.tabBar.frame.height)")
        println("UIApplication.sharedApplication().statusBarFrame.size.height \(UIApplication.sharedApplication().statusBarFrame.size.height)")
        println("periodSelector.frame.height \(periodControl.frame.height)")
        println("appBanner.frame.height \(appBanner.frame.height)")
        
        UIView.animateWithDuration(0.5, animations: { () in
            self.view.layoutIfNeeded()
            mView.alpha = 1.0
        })
    }
    
    func updatePeriodControl(){
        /*
        // team_role might be undefined
        if let team_role =  NSUserDefaults.standardUserDefaults().objectForKey("team_role") as? String {
            self.self_assigned = team_role == "self_assigned"
        } else {
            self.self_assigned = true
        }
        
        lblSubTitle.hidden = !self_assigned
        self.tableView.allowsSelection = !self_assigned
        
        
        let currMcc = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String).lowercaseString
        mcc = currMcc
        
        
        // ministry_name might be undefined
        if let ministryName = NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as? String {
            lblTitle.text = (ministryName) + "(" + currMcc + ")"
        } else {
            lblTitle.text = "Self Assigned" + "(" + currMcc + ")"
        }
        */
        
        periodControl.setEnabled(period != GlobalFunctions.currentPeriod(), forSegmentAtIndex: 2)
        self.periodControl.setTitle(GlobalFunctions.convertPeriodToPrettyString(period), forSegmentAtIndex: 1)
        //tableView.reloadData()
        self.loadData()
        
    }

    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showMeasurementDetail") {
            // pass data to next view
            let detail:measurementDetailViewController = segue.destinationViewController as measurementDetailViewController
            //let indexPath = self.tableView.indexPathForSelectedRow()
            //detail.measurement = fetchedResultController.objectAtIndexPath(indexPath!) as Measurements
            detail.measurement = measurementsFaith[2]
        }
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
