//
//  Hack1ViewController.swift
//  gcmapp
//
//  Created by Mark Briggs on 3/7/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class Hack1ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet weak var measurementsView: UIView!
    

    let pageTitles = ["Title 1", "Title 2", "Title 3", "Title 4"]
    var images = ["page1.png","page2.png","page3.png","page4.png"]
    var count = 0
    
    var pageViewController : UIPageViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as UIPageViewController
        self.pageViewController.dataSource = self
        
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        /* We are substracting 30 because we have a start again button whose height is 30*/
        //self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 30)
        
        //!!!!!!!!!
        /*
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        */
        
        //tableViewController.view.frame = self.contentView.bounds;
        self.pageViewController.view.frame = measurementsView.bounds
        self.addChildViewController(pageViewController)
        measurementsView.addSubview(pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as PageContentViewController).pageIndex!
        index++
        if(index >= self.images.count){
            return nil
        }
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as PageContentViewController).pageIndex!
        if(index <= 0){
            return nil
        }
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return nil
        }
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as PageContentViewController
        
        pageContentViewController.imageName = self.images[index]
        pageContentViewController.titleText = self.pageTitles[index]
        pageContentViewController.pageIndex = index
        
        pageContentViewController.view.frame = measurementsView.bounds  //???
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
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
