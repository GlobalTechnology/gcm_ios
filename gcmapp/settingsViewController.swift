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
  
    
    @IBAction func Logout(sender: UIButton) {
        
        TheKeyOAuth2Client.sharedOAuth2Client().logout()
        
    }
    
  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Settings"
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "noRedrawMap")
        // let notificationCenter = NSNotificationCenter.defaultCenter()
        // notificationCenter.postNotificationName(GlobalConstants.kShouldRefreshAll, object: nil)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Settings")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
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
        
        var team_role_cell=tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))!
        
        if  let team_role = NSUserDefaults.standardUserDefaults().objectForKey("team_role") as! String? {
            team_role_cell.detailTextLabel!.text = GlobalFunctions.getTeamRoleFormatted(team_role)
        }
        else
        {
            
            team_role_cell.detailTextLabel!.text = ""
        }

        if HasMcc().hasMcc() == true {
            
            if let mcc = NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String? {
                mcc_cell.detailTextLabel!.text = mcc
            }
        }
        else {
            
            mcc_cell.detailTextLabel!.text = ""

        }
        
        
        
        //
        // Now register for kDidChangeAssignment  -> so we update our TeamRole value
        //
       
        let nc = NSNotificationCenter.defaultCenter()
        let myQueue = NSOperationQueue()
        // update ministry
        notificationManager.registerObserver(GlobalConstants.kDidChangeAssignment, forObject: nil) { note  in
            
        println(" *** settingsViewController: kDidChangeAssignment: telling tableView.reloadData()")
            self.tableView.reloadData()
        }

    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.row)
        {
        case 4:
            
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kReset, object: nil)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        case 5:
            // TheKeyOAuth2Client.sharedOAuth2Client().logout()
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kLogout, object: self)
            
            break
        default:
            break
        }
    }
    
}
	