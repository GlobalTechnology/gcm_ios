//
//  settingsViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 04/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit

class settingsViewController: UITableViewController {
    @IBAction func Logout(sender: UIButton) {
        
        TheKeyOAuth2Client.sharedOAuth2Client().logout()
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var min_cell=tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
        let min_name = NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as String?
        if min_name != nil {
            min_cell.detailTextLabel!.text = min_name
        } else{
            min_cell.detailTextLabel!.text = ""
        }
        
        
        
        
        var mcc_cell=tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))!
        let mcc = NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String?
       
        if mcc != nil {
            mcc_cell.detailTextLabel!.text = mcc
        } else{
            mcc_cell.detailTextLabel!.text = ""
        }

    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.row)
        {
        case 3:
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kReset, object: nil)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        case 4:
             TheKeyOAuth2Client.sharedOAuth2Client().logout()
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kLogout, object: nil)

            
            break
        default:
            break
        }
    }
    
}
	