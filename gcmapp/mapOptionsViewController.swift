//
//  mapOptionsViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 05/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit

class mapOptionsViewController: UITableViewController {
    @IBOutlet weak var targets: UISwitch!
    @IBOutlet weak var groups: UISwitch!
    @IBOutlet weak var churches: UISwitch!
    @IBOutlet weak var multiplyingChurches: UISwitch!
    @IBOutlet weak var training: UISwitch!
    @IBOutlet weak var campuses: UISwitch!

    @IBAction func btnReturn(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func targetChanged(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setValue(targets.on, forKey: "showTargets")
    }
    
    @IBAction func groupsChanged(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setValue(groups.on, forKey: "showGroups")
    }
    
    @IBAction func churchesChanged(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setValue(churches.on, forKey: "showChurches")
    }
    
    @IBAction func multiplyingChurchesChanged(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setValue(multiplyingChurches.on, forKey: "showMultiplyingChurches")
    }
    
    @IBAction func trainingChanged(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setValue(training.on, forKey: "showTraining")
    }
    @IBAction func campusChanged(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setValue(campuses.on, forKey: "showCampuses")
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var ns =  NSUserDefaults.standardUserDefaults()
        
        
        targets.on = (ns.objectForKey("showTargets") as Bool?) != false
        groups.on = (ns.objectForKey("showGroups") as Bool?) != false
        churches.on = (ns.objectForKey("showChurches") as Bool?) != false
        multiplyingChurches.on = (ns.objectForKey("showMultiplyingChurches") as Bool?) != false
        training.on = (ns.objectForKey("showTraining") as Bool?) != false
        campuses.on = (ns.objectForKey("showCampuses") as Bool?) != false
        
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section==1 {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
}

