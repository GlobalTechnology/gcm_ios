//
//  measurementsPVC.swift
//  gcmapp
//
//  Created by Mark Briggs on 3/6/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class measurementsPVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//class measurementsVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    //var pageViewController : UIPageViewController?
    var index = 0
    var measurementArray: NSArray = ["m1", "m2", "m3"]
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)

        // Do any additional setup after loading the view.
        //self.dataSource = self
        //self.delegate = self
        self.pageViewController!.dataSource = self
        self.pageViewController!.delegate = self
        
        
        //self.pageViewController.transitionStyle = UIPageViewControllerTransitionStyle.Scroll
        //self.navigationOrientation = UIPageViewControllerNavigationOrientation.Horizontal
        
        
        let startingViewController = self.viewControllerAtIndex(self.index)
        let viewControllers: NSArray = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        //self.pageViewController!.view.frame = CGRectMake(0, 0, 80, 80)
        
        //self.view.insertSubview(pageViewController!, aboveSubview: <#UIView#>)
        //self.view.addSubview(self.pageViewController!.view)
        //self.view.addSubview(self.pageViewController!.view)
        self.addChildViewController(self.pageViewController!)
        //self.view.addSubview(self.pageViewController!.view)
        var pageViewRect = self.view.bounds
        self.pageViewController!.view.frame = pageViewRect
        self.pageViewController!.didMoveToParentViewController(self)

    }
    */
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        let startingViewController = self.viewControllerAtIndex(self.index)
        let viewControllers: NSArray = [startingViewController]
        self.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        
        
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController {
        let mView = UIView();
        mView.frame = CGRectMake(0, 0, 400, 400)
        //mView.opaque = true
        mView.backgroundColor = UIColor.lightGrayColor()
        
        let str = measurementArray[index] as String
        
        let mLabel = UILabel();
        mLabel.text = str
        mLabel.textColor = UIColor.redColor()
        mLabel.backgroundColor = UIColor.grayColor()
        mLabel.frame = CGRectMake(0, 0, 200, 200)
        mView.addSubview(mLabel)
        
        let mViewController = UIViewController()
        //mViewController.view.frame = CGRectMake(0, 0, 400, 400)
        mViewController.view.addSubview(mView)
        //mViewController.restorationIdentifier = (measurementArray[index] as String)
        
        return mViewController;
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        //let identifier = viewController.restorationIdentifier
        //let index = self.measurementArray.indexOfObject(identifier!)
        
        /*
        if let identifier = viewController.restorationIdentifier {
            let index = self.measurementArray.indexOfObject(identifier)
            if index == measurementArray.count - 1 {
                return nil
            }
            self.index = self.index + 1
            return self.viewControllerAtIndex(self.index)
        } else {
            return nil
        }
        */
        if self.index == measurementArray.count - 1 {
            return nil
        }
        //self.index = self.index + 1
        self.index++
        return self.viewControllerAtIndex(self.index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        /*
        if let identifier = viewController.restorationIdentifier {
            let index = self.measurementArray.indexOfObject(identifier)
            if index == 0 {
                return nil
            }
            self.index = self.index - 1
            return self.viewControllerAtIndex(self.index)
        } else {
            return nil
        }
        */
        if self.index == 0 {
            return nil
        }
        //self.index = self.index + 1
        self.index--
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return measurementArray.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
