//
//  FirstViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 02/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit
import CoreData





class mapViewController: UIViewController, GMSMapViewDelegate,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var calloutView: SMCalloutView!
    @IBOutlet var emptyCalloutView: UIView!
    
    @IBOutlet weak var lblMinistry: UILabel!
    
    @IBOutlet weak var searchMap: UITextField!
    @IBOutlet weak var autocompleteTableView: UITableView!
   
    
    var churches:[Church]!
    var training:[Training]!
    var autocompleteList:[String]!=Array()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nc = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = nc.addObserverForName(GlobalConstants.kDidReceiveChurches, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            self.redrawMap()
        }
        var observer2 = nc.addObserverForName(GlobalConstants.kDidReceiveTraining, object: nil, queue: mainQueue) {(notification:NSNotification!) in
            self.redrawMap()
        }
        
        
        
        self.view.sendSubviewToBack(self.mapView)
       self.searchMap.delegate=self
      
        
        
        self.calloutView = SMCalloutView()
        var button = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        
        button.addTarget( self, action: "calloutAccessoryButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.calloutView.rightAccessoryView = button
        
        self.emptyCalloutView = UIView(frame: CGRect.zeroRect)
        mapView.delegate = self
        
        
        // Do any additional setup after loading the view, typically from a nib.
        mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(14.944949165712828,-90.34616906534576), zoom: 8, bearing: 0, viewingAngle: 0)
        
        mapView.settings.rotateGestures = false
        
        
        self.autocompleteTableView.delegate=self
        self.autocompleteTableView.dataSource = self
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        redrawMap()
    }
    
    
    func redrawMap(){
        
        var ministryId  = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as String?
        var mcc  = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String?)
        
        if(mcc != nil){
            mcc = mcc!.lowercaseString
        }
        

        if ministryId != nil{
            let min_name=NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as String!
            let mcc=NSUserDefaults.standardUserDefaults().objectForKey("mcc") as String!
            
            lblMinistry.text = "\(min_name) (\(mcc))"
            
            
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            let managedContext = appDelegate.managedObjectContext!
            var error: NSError?
            
            
            
            let fetchRequest = NSFetchRequest(entityName:"Church")
            
            
            
            
            
            
            var devs:[Int] = Array()
            if ((NSUserDefaults.standardUserDefaults().objectForKey("showTargets") as Bool?) != false) { devs.append(1) }
            if ((NSUserDefaults.standardUserDefaults().objectForKey("showGroups") as Bool?) != false) { devs.append(2) }
            if ((NSUserDefaults.standardUserDefaults().objectForKey("showChurches") as Bool?) != false) { devs.append(3) }
            if ((NSUserDefaults.standardUserDefaults().objectForKey("showMultiplyingChurches") as Bool?) != false) { devs.append(5) }
            
            let pred1=NSPredicate(format: "ministry_id = %@", ministryId!)
            let pred2=NSPredicate(format: "development in %@", devs)
           
            
            
           // let pred = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType,  subpredicates: [pred1, pred2])
            
            
            fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [pred1!, pred2!])
           
            
            
            self.churches =
                managedContext.executeFetchRequest(fetchRequest,
                    error: &error) as [Church]?
            
            
            println("Found \(churches.count) results")
            self.mapView.clear()
            for c  in churches {
                var dict = JSONDictionary()
                dict["marker_type"] = "church"
            
                for key in c.entity.attributesByName.keys.array{
                    dict[key as String]=c.valueForKey(key as String)
                }
                
                var  position  = CLLocationCoordinate2DMake( c.valueForKey("latitude") as CLLocationDegrees,c.valueForKey("longitude") as CLLocationDegrees)
                var  marker = GMSMarker(position: position)
                marker.icon = UIImage(named: mapViewController.getIconNameForChurch(c.valueForKey("development") as NSNumber ) )
                
                marker.title = c.valueForKey("name") as String
                marker.map = self.mapView
                marker.userData = dict
                marker.infoWindowAnchor = CGPointMake(0.5, 0.25)
                marker.groundAnchor = CGPointMake(0.5, 1.0)
               
                if let parent = c.parent as Church? {
                    let  path =  GMSMutablePath()
                    
                    path.addLatitude(parent.latitude as CLLocationDegrees, longitude: parent.longitude as CLLocationDegrees)
                    path.addLatitude(c.latitude as CLLocationDegrees, longitude: c.longitude as CLLocationDegrees)
                    
                    let  line = GMSPolyline(path: path)
                    line.strokeWidth=2
                    
                    var grad = GMSStrokeStyle.gradientFromColor(UIColor.blackColor(), toColor: UIColor.lightGrayColor())
                    
                   line.spans = [GMSStyleSpan(style: grad)]
                    
                    
                    line.strokeColor = UIColor.lightGrayColor()
                    line.map = self.mapView
                    
                    var circle = CLLocationCoordinate2D(latitude: parent.latitude as CLLocationDegrees, longitude: parent.longitude as CLLocationDegrees)
                    var circ = GMSCircle(position: circle, radius: 80)
                    circ.fillColor=UIColor.blackColor()
                    circ.map = self.mapView
                    
                  
                    
                }
                
            }
            if mcc != nil{
                let fetchRequest2 = NSFetchRequest(entityName:"Training")
                fetchRequest2.predicate = NSPredicate(format: "ministry_id = %@ AND mcc = %@ AND !( latitude =0 AND longitude = 0)", ministryId!, mcc.lowercaseString)
                self.training =
                    managedContext.executeFetchRequest(fetchRequest2,
                        error: &error) as [Training]?
                for t  in training {
                    var dict = JSONDictionary()
                    dict["marker_type"] = "training"
                    for key in t.entity.attributesByName.keys.array{
                        dict[key as String]=t.valueForKey(key as String)
                    }
                    
                    dict["stages"] = t.stages
                    
                    var  position  = CLLocationCoordinate2DMake( t.valueForKey("latitude") as CLLocationDegrees, t.valueForKey("longitude") as CLLocationDegrees)
                    var  marker = GMSMarker(position: position)
                    marker.icon = UIImage(named: "Training" )
                    
                    marker.title = t.valueForKey("name") as String
                    marker.map = self.mapView
                    marker.userData = dict
                    marker.infoWindowAnchor = CGPointMake(0.5, 0.25)
                    marker.groundAnchor = CGPointMake(0.5, 1.0)
                }
            }
            
            
        }
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let anchor = marker.position as CLLocationCoordinate2D
        let point = mapView.projection.pointForCoordinate(anchor)
        self.calloutView.title = marker.title
        self.calloutView.calloutOffset = CGPointMake(0, -50)
        self.calloutView.hidden = false
        var calloutRect = CGRectZero
        calloutRect.origin=point
        calloutRect.size = CGSizeZero
        self.calloutView .presentCalloutFromRect(calloutRect, inView: mapView, constrainedToView: mapView, animated: true)
        return self.emptyCalloutView
        
    }
    
    func mapView(pMapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if(pMapView.selectedMarker != nil && !self.calloutView.hidden){
            let anchor = pMapView.selectedMarker.position as CLLocationCoordinate2D
            let arrowPt = self.calloutView.backgroundView.arrowPoint;
            var pt = pMapView.projection.pointForCoordinate(anchor)
            pt.x -= arrowPt.x
            pt.y -= arrowPt.y
            self.calloutView.frame = CGRect(origin: pt, size: self.calloutView.frame.size)
            
            
        }else {
            self.calloutView.hidden=true
        }
        
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.calloutView.hidden=true
    }
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        mapView.selectedMarker = marker
        return true
    }
    
   /* override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "churchDetail" {
            let marker = self.mapView.selectedMarker
            var churchData = marker.userData as JSONDictionary
            var cd = segue.destinationViewController as churchViewController
            
            cd.data = churchData
            
        }
    }*/
    
    
    
    class func getIconNameForChurch(development: NSNumber) -> String
    {
        switch(development){
        case 1:
            return "targeticon"
        case 2:
            return "groupicon"
        case 3:
            return "churchicon"
        case 5:
            return "multiplyingchurchicon"
        default:
            return ""
        }
    }
    
    func calloutAccessoryButtonTapped(obj: AnyObject?){
        
        
        if ((self.mapView.selectedMarker) != nil) {
            
            //self.performSegueWithIdentifier("churchDetail", sender: self)
            
            let marker = self.mapView.selectedMarker
            var data = marker.userData as JSONDictionary
            var vc:UIViewController!
            switch data["marker_type"] as String!{
                case "church":
                    let ch = self.storyboard?.instantiateViewControllerWithIdentifier("churchViewController") as churchViewController
                    ch.data = data
                    vc=ch as UIViewController
                
                case "training":
                    let tr = self.storyboard?.instantiateViewControllerWithIdentifier("trainingViewController") as trainingViewController
                    tr.data = data
                    vc=tr as UIViewController
            default:
                break
                
            }
            
            
            
            
            
            
            
            
            
            self.modalPresentationStyle =  UIModalPresentationStyle.PageSheet
            self.presentViewController(vc, animated: true, completion: nil	)
            
            
            /* let alertView = UIAlertView(title:  (churchData["name"] as String), message: (churchData["name"] as String), delegate: nil, cancelButtonTitle: "OK")
            
            alertView.show()*/
            
        }
        
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("autocompleteCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = autocompleteList[indexPath.row]
        return cell
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        autocompleteTableView.hidden=false;
        var substring:String = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        self.searchAutocompleteEntriesWithSubstring(substring)
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchMap.text = autocompleteList[indexPath.row]
        autocompleteTableView.hidden=true
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
          textField.resignFirstResponder()
        autocompleteTableView.hidden=true
        
        for c in churches{
            var r:NSRange = (c.name.lowercaseString as NSString).rangeOfString(searchMap.text.lowercaseString)
            if r.location == 0{
                mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(c.latitude as CLLocationDegrees ,c.longitude as CLLocationDegrees ), zoom: 16, bearing: 0, viewingAngle: 0)
            
                
            }
        }
        searchMap.text = ""
         return true
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String){
        autocompleteList.removeAll(keepCapacity: false)
        for c in churches{
            var r:NSRange = (c.name.lowercaseString as NSString).rangeOfString(substring.lowercaseString)
            if r.location == 0{
                autocompleteList.append(c.name)
            }
        }
        autocompleteTableView.reloadData()
    }
    
    
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

