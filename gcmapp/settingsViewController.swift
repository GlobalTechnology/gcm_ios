//
//  settingsViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 04/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit

class settingsViewController: UITableViewController {
   
    private let notificationManager = NotificationManager()
  
    @IBOutlet var menuButton: UIBarButtonItem!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.title = "Settings"
        // let notificationCenter = NSNotificationCenter.defaultCenter()
        // notificationCenter.postNotificationName(GlobalConstants.kShouldRefreshAll, object: nil)
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: "Settings")
//        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        var min_cell=tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
        if let min_name = NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as! String? {
            min_cell.detailTextLabel!.text = min_name
        } else{
            min_cell.detailTextLabel!.text = ""
            
        }
    
        var mcc_cell=tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))!
       
        if let mcc = NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String? {
            mcc_cell.detailTextLabel!.text = mcc
        } else{
            mcc_cell.detailTextLabel!.text = ""
        }
        
       
        if HasMcc().hasMcc() == true {
            
            if let mcc = NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String? {
                mcc_cell.detailTextLabel!.text = mcc
            }
            
            if let min_name = NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as! String? {
                min_cell.detailTextLabel!.text = min_name
            }
        }
        else {
            
            mcc_cell.detailTextLabel!.text = ""

        }
       
        
        
//        // update ministry
//        notificationManager.registerObserver(GlobalConstants.kDidChangeAssignment, forObject: nil) { note  in
//            
//        //println(" *** settingsViewController: kDidChangeAssignment: telling tableView.reloadData()")
//            self.tableView.reloadData()
//        }

    }
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 4
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//         var cell = tableView.dequeueReusableCellWithIdentifier("MccCell", forIndexPath: indexPath) as! UITableViewCell
//        
//        
//         return cell
//    }
    
    var timer = NSTimer()

    func showLoader(){
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.color = UIColor(red:0.0/255.0,green:128.0/255.0,blue:64.0/255.0,alpha:1.0)
        
     timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("stopLoader"), userInfo: nil, repeats: true)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: "showLoaderInSetting", object: nil)
    }
    
    func stopLoader(){
        dispatch_async(dispatch_get_main_queue(), {
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
        })
        
        timer.invalidate()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLoader", name: "showLoaderInSetting", object: nil)

        switch(indexPath.row)
        {
        case 2:
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kReset, object: nil)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
       
        default:
            break
        }
    }
    
}
	