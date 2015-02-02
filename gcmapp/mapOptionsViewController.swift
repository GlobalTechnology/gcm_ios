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
    var mapVC:  mapViewController!
    
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
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var ns =  NSUserDefaults.standardUserDefaults()
        
        
        targets.on = (ns.objectForKey("showTargets") as Bool?) != false
        groups.on = (ns.objectForKey("showGroups") as Bool?) != false
        churches.on = (ns.objectForKey("showChurches") as Bool?) != false
        multiplyingChurches.on = (ns.objectForKey("showMultiplyingChurches") as Bool?) != false
        training.on = (ns.objectForKey("showTraining") as Bool?) != false
        	
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section==1{
            switch indexPath.row{
            case 0: //addChurch
                for m in mapVC.markers{
                    m.opacity=0.2
                    m.tappable = false
                }
                var  marker = GMSMarker(position: mapVC.mapView.projection.coordinateForPoint(mapVC.mapView.center))
                marker.icon = UIImage(named: mapViewController.getIconNameForChurch(1))
                
                
                marker.title = ""
                marker.map = mapVC.mapView
                var data = JSONDictionary()
                data["marker_type"] = "new_church"
                data["name"] = ""
                data["contact_name"] = ""  //could prefill user's name here
                data["contact_email"] = ""
                data["size"]=0
                data["development"] = 1
                data["security"] = 2
                
                marker.userData=data
                marker.infoWindowAnchor = CGPointMake(0.5, 0.25)
                marker.groundAnchor = CGPointMake(0.5, 1.0)
                marker.draggable = true
                marker.opacity=1.0
                mapVC.markers.append(marker)
                
              
                mapVC.searchMap.hidden=true
                
                mapVC.lblMove.hidden = false

                self.dismissViewControllerAnimated(true, completion: nil)
                break
            case 1: //addTraining
                for m in mapVC.markers{
                    m.opacity=0.2
                    m.tappable = false
                }
                var  marker = GMSMarker(position: mapVC.mapView.projection.coordinateForPoint(mapVC.mapView.center))
                marker.icon = UIImage(named: "Training" )
                
                
                marker.title = ""
                marker.map = mapVC.mapView
                var data = JSONDictionary()
                data["marker_type"] = "new_training"
                data["name"] = ""
                data["type"] = ""
                data["date"] = GlobalFunctions.currentDate()   
                marker.userData=data
                marker.infoWindowAnchor = CGPointMake(0.5, 0.25)
                marker.groundAnchor = CGPointMake(0.5, 1.0)
                marker.draggable = true
                marker.opacity=1.0
                mapVC.markers.append(marker)
                
                
                mapVC.searchMap.hidden=true
                
                mapVC.lblMove.hidden = false
                
                self.dismissViewControllerAnimated(true, completion: nil)
                break
            case 2: //back
                self.dismissViewControllerAnimated(true, completion: nil)
                break
            default:
                break
            }
            
        }
    }
    
    
    
}

