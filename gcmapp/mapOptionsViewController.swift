//
//  mapOptionsViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 05/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit
import CoreData

class mapOptionsViewController: UITableViewController {
    @IBOutlet weak var targets: UISwitch!
    @IBOutlet weak var groups: UISwitch!
    @IBOutlet weak var churches: UISwitch!
    @IBOutlet weak var multiplyingChurches: UISwitch!
    @IBOutlet weak var training: UISwitch!
    @IBOutlet weak var campuses: UISwitch!
    var mapVC:  mapViewController!
    var read_only: Bool = true
    
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
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            
        }
        return section==0 ? 5 : read_only ? 4:4   // allow to all member to create traning and church icons
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var ns =  NSUserDefaults.standardUserDefaults()
        
        
        targets.on = (ns.objectForKey("showTargets") as! Bool?) != false
        groups.on = (ns.objectForKey("showGroups") as! Bool?) != false
        churches.on = (ns.objectForKey("showChurches") as! Bool?) != false
        multiplyingChurches.on = (ns.objectForKey("showMultiplyingChurches") as! Bool?) != false
        training.on = (ns.objectForKey("showTraining") as! Bool?) != false
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if var team_role  = NSUserDefaults.standardUserDefaults().objectForKey("team_role") as? String {
            
            self.read_only = !GlobalFunctions.contains(team_role, list: GlobalConstants.LEADERS_ONLY)

        }

        
        
        
        tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        if indexPath.section==1{
            switch indexPath.row{
            case 2: //addChurch
                /*
                if read_only{
                    return
                }
*/
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
            case 3: //addTraining
                
                /*
                if read_only{
                    return
                }*/
                
                for m in mapVC.markers{
                    m.opacity=0.2
                    m.tappable = false
                }
                var  marker = GMSMarker(position: mapVC.mapView.projection.coordinateForPoint(mapVC.mapView.center))
                marker.icon = UIImage(named: "train" )
                
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
            case 0: //back
                self.dismissViewControllerAnimated(true, completion: nil)
                break
            case 1: //default map view
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext!
                var ministry_id  = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String
                var error: NSError?
           
                    mapVC.ministry.zoom = mapVC.mapView.camera.zoom
                    mapVC.ministry.latitude = mapVC.mapView.camera.target.latitude
                    mapVC.ministry.longitude = mapVC.mapView.camera.target.longitude

                
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                // get map info(lat ,long,zoom)
                
                var mapInfoDic: NSDictionary = NSDictionary(objectsAndKeys: ministry_id,"min_id",mapVC.mapView.camera.target.latitude,"lat",mapVC.mapView.camera.target.longitude,"long",mapVC.mapView.camera.zoom,"zoom" )
                
                    let notificationCenter = NSNotificationCenter.defaultCenter()
                   notificationCenter.postNotificationName(GlobalConstants.kShouldSaveUserPreferences, object: nil, userInfo: mapInfoDic as! JSONDictionary)
               
                //  notificationCenter.postNotificationName(GlobalConstants.kShouldUpdateMin, object: nil, userInfo: ["ministry": mapVC.ministry])
                    self.dismissViewControllerAnimated(true, completion: nil)

                break
            default:
                break
            }
            
        }
    }
    
    
    
}

