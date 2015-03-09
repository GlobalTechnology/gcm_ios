//
//  Hack1ViewController.swift
//  gcmapp
//
//  Created by Mark Briggs on 3/7/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class Hack1ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var measurementsViewFaith: UIView!
    @IBOutlet weak var measurementsViewFruit: UIView!
    @IBOutlet weak var measurementsViewOutcomes: UIView!
    
    @IBOutlet weak var measurementsViewFaithHeight: NSLayoutConstraint!
    
    @IBOutlet weak var measurementsViewFruitHeight: NSLayoutConstraint!
    
    @IBOutlet weak var measurementsViewOutcomesHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var faithHeader: UIButton!
    
    @IBOutlet weak var fruitHeader: UIButton!
    
    @IBOutlet weak var outcomesHeader: UIButton!
    
    let FAITH = 0
    let FRUIT = 1
    let OUTCOMES = 2
    
    
    var currentlyOpenMeasurementCategory = 0

    var measurementDescriptionsFaith = ["Exposing Through Mass Media", "Some Other Method", "Crazy Method", "Insane Method"]
    //var measurementValuesFaith = [5,3,7,8]
    var measurementValuesFaith = ["5","3","7","8"]
    
    var measurementDescriptionsFruit = ["Discipleship Wow", "Are you Serious?!", "Great job!"]
    //var measurementValuesFruit = [1,2,3]
    var measurementValuesFruit = ["1","2","3"]
    
    var measurementDescriptionsOutcomes = ["Description #1", "Description #2", "Description #3", "Description #4", "Description #5", ]
    //var measurementValuesOutcomes = [9,8,7,6,5]
    var measurementValuesOutcomes = ["9","8","7","6","5"]
    
    
    
    //var count = 0
    
    var pageViewControllerFaith : UIPageViewController!
    var pageViewControllerFruit : UIPageViewController!
    var pageViewControllerOutcomes : UIPageViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentlyOpenMeasurementCategory = FAITH
        
        faithHeader.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
        fruitHeader.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
        outcomesHeader.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
        
        
        
        // === Faith ===
        pageViewControllerFaith = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as UIPageViewController
        self.pageViewControllerFaith.dataSource = self
        
        let pageContentViewControllerFaith = self.viewControllerAtIndex(0, measurementType: FAITH)
        self.pageViewControllerFaith.setViewControllers([pageContentViewControllerFaith!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)

        self.pageViewControllerFaith.view.frame = measurementsViewFaith.bounds
        self.addChildViewController(pageViewControllerFaith)
        measurementsViewFaith.addSubview(pageViewControllerFaith.view)
        self.pageViewControllerFaith.didMoveToParentViewController(self)

        
        
        // === Fruit ===
        pageViewControllerFruit = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as UIPageViewController
        self.pageViewControllerFruit.dataSource = self
        
        let pageContentViewControllerFruit = self.viewControllerAtIndex(0, measurementType: FRUIT)
        self.pageViewControllerFruit.setViewControllers([pageContentViewControllerFruit!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        self.pageViewControllerFruit.view.frame = measurementsViewFruit.bounds
        self.addChildViewController(pageViewControllerFruit)
        measurementsViewFruit.addSubview(pageViewControllerFruit.view)
        self.pageViewControllerFruit.didMoveToParentViewController(self)
        
        
        measurementsViewFruitHeight.constant = 0
        measurementsViewFruit.hidden = true

        
        
        // === Outcomes ===
        pageViewControllerOutcomes = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as UIPageViewController
        self.pageViewControllerOutcomes.dataSource = self
        
        let pageContentViewControllerOutcomes = self.viewControllerAtIndex(0, measurementType: OUTCOMES)
        self.pageViewControllerOutcomes.setViewControllers([pageContentViewControllerOutcomes!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        self.pageViewControllerOutcomes.view.frame = measurementsViewOutcomes.bounds
        self.addChildViewController(pageViewControllerOutcomes)
        measurementsViewOutcomes.addSubview(pageViewControllerOutcomes.view)
        self.pageViewControllerOutcomes.didMoveToParentViewController(self)
        
        measurementsViewOutcomesHeight.constant = 0
        measurementsViewOutcomes.hidden = true
        
        
        
        openView(FAITH)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        println("pageViewControllerAFTER")
        
        let pcvc = viewController as PageContentViewController
        
        var cnt:Int = 1
        switch (pcvc.measurementType) {
        case FAITH:
            cnt = measurementDescriptionsFaith.count
        case FRUIT:
            cnt = measurementDescriptionsFruit.count
        case OUTCOMES:
            cnt = measurementDescriptionsOutcomes.count
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
    
    func viewControllerAtIndex(index : Int, measurementType: Int) -> UIViewController? {
        println("viewControllerAtIndex: \(index), measurementType: \(measurementType)")
        
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as PageContentViewController
        
        pageContentViewController.measurementType = measurementType
        
        
        var measurementDescriptions : [String]
        //var measurementValues : [Int]
        var measurementValues : [String]
        switch (measurementType) {
        case FAITH:
            measurementDescriptions = measurementDescriptionsFaith
            measurementValues = measurementValuesFaith
        case FRUIT:
            measurementDescriptions = measurementDescriptionsFruit
            measurementValues = measurementValuesFruit
        case OUTCOMES:
            measurementDescriptions = measurementDescriptionsOutcomes
            measurementValues = measurementValuesOutcomes
        default:
            measurementDescriptions = measurementDescriptionsFaith
            measurementValues = measurementValuesFaith
        }
        
        if((measurementDescriptions.count == 0) || (index >= measurementDescriptions.count)) {
            return nil
        }
        
        pageContentViewController.measurementDescription = measurementDescriptions[index]
        pageContentViewController.measurementValue = measurementValues[index]
        
        pageContentViewController.pageIndex = index
        
        //pageContentViewController.view.frame = measurementsViewFaith.bounds  //???
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        //println("presentationCountForPageViewController: \(cnt)")
        
        let pcvc = pageViewController.viewControllers[0] as PageContentViewController
        var cnt:Int = 1
        switch (pcvc.measurementType) {
        case FAITH:
            cnt = measurementDescriptionsFaith.count
        case FRUIT:
            cnt = measurementDescriptionsFruit.count
        case OUTCOMES:
            cnt = measurementDescriptionsOutcomes.count
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
        var constraint: NSLayoutConstraint
        var mView: UIView
        var viewsHeaderTop: UIButton
        var viewsHeaderBottom: UIButton?
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        switch (viewType) {
        case FAITH:
            constraint = measurementsViewFaithHeight
            mView = measurementsViewFaith
            viewsHeaderTop = self.faithHeader
            viewsHeaderBottom = self.fruitHeader
        case FRUIT:
            constraint = measurementsViewFruitHeight
            mView = measurementsViewFruit
            viewsHeaderTop = self.fruitHeader
            viewsHeaderBottom = self.outcomesHeader
        case OUTCOMES:
            constraint = measurementsViewOutcomesHeight
            mView = measurementsViewOutcomes
            viewsHeaderTop = self.outcomesHeader
            viewsHeaderBottom = nil
        default:
            constraint = measurementsViewFaithHeight
            mView = measurementsViewFaith
            viewsHeaderTop = self.faithHeader
            viewsHeaderBottom = self.fruitHeader
        }
        
        mView.hidden = false
        
        constraint.constant = screenSize.height - (faithHeader.bounds.height * 3) - tabBarController!.tabBar.frame.height - UIApplication.sharedApplication().statusBarFrame.size.height
        UIView.animateWithDuration(0.5, animations: { () in
            self.view.layoutIfNeeded()
            mView.alpha = 1.0
        })
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
