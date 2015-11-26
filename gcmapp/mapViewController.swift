//
//  FirstViewController.swift
//  gcmapp
//
//  Created by -on 02/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit
import CoreData

class mapViewController: UIViewController, GMSMapViewDelegate,UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIActionSheetDelegate {
    
    private let notificationManager = NotificationManager()
    var sync: dataSync!
    
    var longPressLatitude = CLLocationDegrees()
    var longPressLongitude = CLLocationDegrees()
    
    var isMarkerDraggable = Bool()
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var calloutView: SMCalloutView!
    @IBOutlet var emptyCalloutView: UIView!
    
    @IBOutlet weak var lblMinistry: UILabel!
    @IBOutlet weak var searchMap: UITextField!
    @IBOutlet weak var autocompleteTableView: UITableView!
   
    // @IBOutlet var menuButton: UIButton!
    @IBOutlet var menuButton: UIBarButtonItem!//
    var rightAddBarButtonItem: UIBarButtonItem!//

    @IBOutlet weak var lblMove: UILabel!

    var isFilterPopupOpen = Bool()
    
    var iconArray = [String]()
    var iconImageArray = [String]()

    var searchController:UISearchController!
    var searchActive : Bool = false
    
    var churches:[Church]!
    var training:[Training]!
    var autocompleteList:[String]!=Array()
    
    var markers:[GMSMarker]! = Array()
    var churchLines:[GMSPolyline]! = Array()
    var churchdots:[GMSMarker]! = Array()
    var ministry: Ministry!
    
    var makeUserEnable = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton.enabled = false
        makeUserEnable = false
        
        if let title = NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as? String {
            self.navigationController?.navigationBar.topItem?.title = title
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "redrawMap", name: "callRedrawMethod", object: nil)
        
        isMarkerDraggable = false
        isFilterPopupOpen = false
        autocompleteTableView.tag = 0
        self.calloutView = SMCalloutView()
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")

        // 1
        
        let button: UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        //set image for button
        button.setImage(UIImage(named: "mapFilters"), forState: UIControlState.Normal)
        //add function for button
        button.addTarget(self, action: "rightMenuTap", forControlEvents: UIControlEvents.TouchUpInside)
        //set frame
        button.frame = CGRectMake(0, 0, 20, 20)
        
        rightAddBarButtonItem = UIBarButtonItem(customView: button)
        // 2
        var rightSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "showSearchBar:")
        // 3
        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem,rightSearchBarButtonItem], animated: false)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var error: NSError?
        
        if let ministryId  = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String? {
            
            let fr =  NSFetchRequest(entityName:"Ministry" )
            fr.predicate = NSPredicate(format: "id == %@", ministryId )
            
            let min = managedContext.executeFetchRequest(fr,error: &error) as! [Ministry]
            if min.count>0{
                self.ministry = min.first!
                
                self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(self.ministry!.latitude.doubleValue as CLLocationDegrees,self.ministry!.longitude.doubleValue as CLLocationDegrees), zoom: self.ministry.zoom.floatValue , bearing: 0, viewingAngle: 0)
            }
        }
        
        
        self.mapView.settings.compassButton = true
    }
    
    func makeMenuBtnEnable(){

        dispatch_async(dispatch_get_main_queue()) {
            if let title = NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as? String {
                self.navigationController?.navigationBar.topItem?.title = title
            }

            if(self.makeUserEnable == true){
                self.makeUserEnable = false
                self.menuButton.enabled = true
            }
            else{
                self.makeUserEnable = true
                self.menuButton.enabled = false
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear( animated)
        
        // observer_getUserPreferences
        notificationManager.registerObserver(GlobalConstants.kShouldLoadUserPreferences) { note in
            
            self.getUserPreferences() // call api for set userpreferences
            
        }
        
        // observer_deleteTraning
        notificationManager.registerObserver(GlobalConstants.kShouldDeleteTraining) { note in
            
            var trainingDic : NSDictionary = note.userInfo as! JSONDictionary
            for m in self.markers {
                
                var mark = m
                if (mark.userData as! JSONDictionary)["id"]  as! NSNumber == trainingDic["training_id"] as! NSNumber
                {
                    m.map = nil
                }
            }
            
            self.deleteTraning(trainingDic as! JSONDictionary)
        }
        
        //observer_deleteChurch
        notificationManager.registerObserver(GlobalConstants.kShouldDeleteChurch) { note in
            
            var churchDic : NSDictionary = note.userInfo as! JSONDictionary
            for m in self.markers {
                
                var mark = m
                if (mark.userData as! JSONDictionary)["id"]  as! NSNumber == churchDic["id"] as! NSNumber
                {
                    m.map = nil
                }
            }
            
            self.deleteChurch(churchDic as! JSONDictionary)
        }
        
        //observer receive church
        notificationManager.registerObserver(GlobalConstants.kDidReceiveChurches) {(notification:NSNotification!) in
            self.redrawMap()
        }
        
        //observer receive training
        notificationManager.registerObserver(GlobalConstants.kDidReceiveTraining) {(notification:NSNotification!) in
            self.redrawMap()
        }
        
        
        
        self.view.sendSubviewToBack(self.mapView)
        // self.searchMap.delegate=self
        
        
        var button = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        
        button.addTarget( self, action: "calloutAccessoryButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.calloutView.rightAccessoryView = button
        
        self.emptyCalloutView = UIView(frame: CGRect.zeroRect)
        mapView.delegate = self
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.settings.rotateGestures = false
        
//        notificationManager.registerObserver(GlobalConstants.kDrawTrainingPinKey) {(notification:NSNotification!) in
//            
//            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
//            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
//            dispatch_async(backgroundQueue, {
//                //println("This is run on the background queue")
//                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    //println("This is run on the main queue, after the previous code in outer block")
//                    
//                    let userInfo:JSONDictionary = notification.userInfo as! JSONDictionary
//                    
//                    var position = CLLocationCoordinate2DMake(userInfo["latitude"] as! CLLocationDegrees, userInfo["longitude"] as! CLLocationDegrees)
//                    
//                    var  marker = GMSMarker(position: position)
//                    marker.icon = UIImage(named: "train" )
//                    
//                    marker.title = userInfo["name"] as! String
//                    marker.map = self.mapView
//                    
//                    //        userInfo["marker_type"] = "training"
//                    
//                    marker.userData = userInfo
//                    marker.infoWindowAnchor = CGPointMake(0.5, 0.25)
//                    marker.groundAnchor = CGPointMake(0.5, 1.0)
//                    marker.opacity=1.0
//                    self.markers.append(marker)
//                    //        lblMove.hidden = false
//                    self.view.bringSubviewToFront(self.lblMove)
//                })
//            })
//        }
//        
//        notificationManager.registerObserver(GlobalConstants.kDrawChurchPinKey) {(notification:NSNotification!) in
//            
//            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
//            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
//            dispatch_async(backgroundQueue, {
//                //println("This is run on the background queue")
//                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    //println("This is run on the main queue, after the previous code in outer block")
//                    
//                    let userInfo:JSONDictionary = notification.userInfo as! JSONDictionary
//                    
//                    var position = CLLocationCoordinate2DMake(userInfo["latitude"] as! CLLocationDegrees, userInfo["longitude"] as! CLLocationDegrees)
//                    
//                    var  marker = GMSMarker(position: position)
//                    marker.icon = UIImage(named: mapViewController.getIconNameForChurch(1))
//                    
//                    marker.title = userInfo["name"] as! String
//                    marker.map = self.mapView
//                    marker.userData = userInfo
//                    marker.infoWindowAnchor = CGPointMake(0.5, 0.25)
//                    marker.groundAnchor = CGPointMake(0.5, 1.0)
//                    marker.opacity=1.0
//                    self.markers.append(marker)
//                    //        lblMove.hidden = false
//                    self.view.bringSubviewToFront(self.lblMove)
//                    
//                })
//            })
//        }
        
        notificationManager.registerObserver(GlobalConstants.kUpdatePinInforamtionKey) {(notification:NSNotification!) in
            
            let userInfo:JSONDictionary = notification.userInfo as! JSONDictionary
            
            self.mapView.selectedMarker.title = userInfo["name"] as! String
            self.mapView.selectedMarker.userData = userInfo
        }
        
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "drawTrainingPin:", name: "drawTrainingPinKey", object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePinInformation:", name: "updatePinInforamtionKey", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kFromLeftMenuHomeTap) == true)
        {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kFromLeftMenuHomeTap)
            self.redrawMap()
        }
        else
        {
            if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kDoOnceSettingActive) == false){
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kDoOnceSettingActive)

                NSUserDefaults.standardUserDefaults().setValue(true, forKey: GlobalConstants.kShowTargets)
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: GlobalConstants.kShowGroups)
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: GlobalConstants.kShowChurches)
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: GlobalConstants.kShowMultiplyingChurches)
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: GlobalConstants.kShowParents)
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: GlobalConstants.kShowTraining)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func cancelButtonTap(sender: AnyObject){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func showSearchBar(sender: AnyObject) {
        
        // Create the search controller and make it perform the results updating.
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.autocompleteTableView.delegate = self
        self.autocompleteTableView.dataSource = self
        
        // Present the view controller
        presentViewController(searchController, animated: true, completion: nil)
    }

    
    var subView = UIView()
    var subImgView = UIImageView()
    var popupTblView = UITableView()
    
    let cellIdentifier = "cellIdentifier"
    
    func rightMenuTap() // justin
    {
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            //println("This is run on the background queue")
            
            
            
            
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //println("This is run on the main queue, after the previous code in outer block")
                
        if(self.isFilterPopupOpen == true)
        {
            self.isFilterPopupOpen = false
            self.subView.removeFromSuperview()
            // self.redrawMap()
        }
        else
        {
            self.isFilterPopupOpen = true
                
            self.popupTblView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
                
            self.iconArray  = ["Targets","Groups","Churches","Multiplying Churches","Church Parents","Training Activities"]
                
            self.iconImageArray = ["target","group","church","multiply","multiply","train"]
                
            var tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: "outSideViewTap")
            
            self.subView.frame = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            self.subView.backgroundColor = UIColor.clearColor()
            self.subView.alpha = 1.0
            self.view.addSubview(self.subView)
            
            
            self.subImgView.frame = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            self.subImgView.backgroundColor = UIColor.lightGrayColor()
            self.subImgView.alpha = 0.6
            self.subImgView.userInteractionEnabled = true
            self.subView.addSubview(self.subImgView)
            self.subImgView.addGestureRecognizer(tapGesture)

            
            self.popupTblView.frame = CGRectMake(20.0, (UIScreen.mainScreen().bounds.size.height / 2) - 186, UIScreen.mainScreen().bounds.size.width - 40, 304)
            self.popupTblView.backgroundColor = UIColor.whiteColor()
            self.popupTblView.separatorStyle = UITableViewCellSeparatorStyle.None
            self.popupTblView.bounces = false
            self.popupTblView.scrollEnabled = false
            self.popupTblView.tag = 1
            self.popupTblView.alpha = 1.0
            self.popupTblView.layer.cornerRadius = 6.0
            self.subView.addSubview(self.popupTblView)
            self.subView.bringSubviewToFront(self.popupTblView)
            
            self.popupTblView.dataSource = self
            self.popupTblView.delegate = self
        }
                
            })
        })
    }
    
    func outSideViewTap()
    {
        
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            println("Work Dispatched")
            // Do heavy or time consuming work
            
            // Create a weak reference to prevent retain cycle and get nil if self is released before run finishes
            dispatch_async(dispatch_get_main_queue()){
                
                self.isFilterPopupOpen = false
                self.subView.removeFromSuperview()
                
                
                
            }
            
        }
        

        
       
           }
    
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        //println("\(buttonIndex)")
        switch (buttonIndex){
            
        case 0:
            println("Cancel")
        case 1:
            self.addTraining()
            break
            
        case 2:
            self.addChurch()
           
            break
            
        default:
            break
        }
    }
    
    // add church
    
    func addChurch() {
        
        var data = JSONDictionary()
        
        data["marker_type"] = "new_church"
        data["name"] = ""
        data["contact_name"] = ""  //could prefill user's name here
        data["contact_email"] = ""
        data["size"]=0
        data["development"] = 1
        data["security"] = 2
        
        
        let ch = self.storyboard?.instantiateViewControllerWithIdentifier("ChurchTVC") as! ChurchTVC
        
        ch.data = data as JSONDictionary
        ch.data["latitude"] = longPressLatitude
        ch.data["longitude"] = longPressLongitude
        ch.mapVC = self
        self.modalPresentationStyle =  UIModalPresentationStyle.PageSheet
        self.presentViewController(ch, animated: true, completion: nil)
    }
    
    func updatePinInformation(notification:NSNotification)
    {
        let userInfo:JSONDictionary = notification.userInfo as! JSONDictionary
        
        self.mapView.selectedMarker.title = userInfo["name"] as! String
        self.mapView.selectedMarker.userData = userInfo
    }
    
    // add Training
    
    func addTraining() {
        
        var data = JSONDictionary()
        
        data["marker_type"] = "new_training"
        data["name"] = ""
        data["type"] = "Other"
        data["date"] = GlobalFunctions.currentDate()
        
        let tr = self.storyboard?.instantiateViewControllerWithIdentifier("trainingViewController") as! trainingViewController
        tr.data = data as JSONDictionary
        tr.data["latitude"] = longPressLatitude
        tr.data["longitude"] = longPressLongitude
        //println(tr.data["type"])
        var emptyStages = [TrainingCompletion]()
        tr.data["stages"]  = NSSet(array: emptyStages)
        
        tr.mapVC = self
        self.modalPresentationStyle =  UIModalPresentationStyle.PageSheet
        self.presentViewController(tr, animated: true, completion: nil)
    }
    
    class func churchesContainsId(id:NSNumber, churches:[Church]) -> Bool{
       return ( churches.filter {$0.id == id  } as [Church]).count>0
    }
    
    class func trainingContainsId(id:NSNumber, training:[Training]) -> Bool{
        return ( training.filter {$0.id == id  } as [Training]).count>0
    }
    
    
    
    
    //>---------------------------------------------------------------------------------------------------
    // Author Name      :   Justin Mohit
    // Date             :   Aug, 4 2015
    // Input Parameters :   N/A.
    // Purpose          :   get user_preferences.
    //>---------------------------------------------------------------------------------------------------
    
    func getUserPreferences(){
        
        var token : String = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        //println(token)
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.color = UIColor(red:0.0/255.0,green:128.0/255.0,blue:64.0/255.0,alpha:1.0)
        
        API(token: token).getUserPreferences(){
            (data: AnyObject?,error: NSError?) -> Void in
            //Nothing to do...
            
            dispatch_async(dispatch_get_main_queue(), {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            })
            
            
            if var userpreferencesData: JSONDictionary = data as? JSONDictionary {
                
                var error: NSError?
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
                let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
                
                if(moc!.executeFetchRequest(fetchRequest,
                    error: &error)?.count == 0)
                {
                    var alertController = UIAlertController(title: "", message: "Please identify a ministry team that you work most closely with and request to join that team.", preferredStyle: .Alert)
                    
                    var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        self.performSegueWithIdentifier("NewMinistryView", sender: nil)
                    }
                    
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
                    if(userpreferencesData.count > 0){
                        
                        if userpreferencesData.indexForKey("default_map_views") != nil {
                            // the key exists in the dictionary
                            
                            var mapArr = userpreferencesData["default_map_views"] as! JSONArray
                            
                            
                            for m in mapArr {
                                
                                var locationDic = m["location"] as! JSONDictionary

                                
                                var error: NSError?
                                fetchRequest.predicate = NSPredicate(format: "id = %@", m["ministry_id"] as! String!)
                                let ministry = moc!.executeFetchRequest(fetchRequest, error: &error) as! [Ministry]
                                if ministry.count>0{
                                    
                                    ministry.first!.latitude = locationDic["latitude"] as! NSNumber
                                    ministry.first!.longitude = locationDic["longitude"] as! NSNumber
                                    ministry.first!.zoom = m["location_zoom"] as! NSNumber
                                }
                                    
                                if !moc!.save(&error) {
                                    //println("Could not save \(error), \(error?.userInfo)")
                                }
                                
                                
                                
                                
                                var minId = m["ministry_id"] as! String
                                var lat: AnyObject? = locationDic["latitude"]   //["location"]["latitude"]
                                var long: AnyObject? = locationDic["longitude"]
                                var zm : AnyObject? = m["location_zoom"]
                                
                        if let id = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String{
                                if (minId == id) {
                                    
                                    //                        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
                                    
                                    dispatch_async(dispatch_get_main_queue(),{
                                        
                                        self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(lat!.doubleValue as CLLocationDegrees,long!.doubleValue as CLLocationDegrees), zoom: zm!.floatValue , bearing: 0, viewingAngle: 0)
                                        
                                    });
                                    //}
                                }
                            }
                        }
                        }
                        else {
                            
                            println("no key found")
                        }
                }
            }
        }
    }
    
    
    //>---------------------------------------------------------------------------------------------------
    // Author Name      :   Justin Mohit
    // Date             :   Aug, 4 2015
    // Input Parameters :   trainingId : Int ,lat : Double ,long: Double ,zm : Int.
    // Purpose          :   delete Traning.
    //>---------------------------------------------------------------------------------------------------
    
    func deleteTraning(trainingInfo : JSONDictionary){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var error : NSError? = nil
        var qReq: NSFetchRequest = NSFetchRequest(entityName: "Training")
        qReq.includesPropertyValues = false
        qReq.predicate = NSPredicate(format: "id = %@", trainingInfo["training_id"] as! NSNumber)
        if let objects = appDelegate.managedObjectContext!.executeFetchRequest(qReq, error:&error) {
            
            for resultItem in objects {
                var qItem = resultItem as! Training
                appDelegate.managedObjectContext!.deleteObject(qItem)
                
            }
            
            appDelegate.backgroundContext!.save(&error)
            
            
            qReq = NSFetchRequest(entityName: "TrainingCompletion")
            qReq.includesPropertyValues = false
            qReq.predicate = NSPredicate(format: "id = %@", trainingInfo["training_id"] as! NSNumber)
            if let objects = appDelegate.backgroundContext!.executeFetchRequest(qReq, error:&error) {
                
                for resultItem in objects {
                    var qItem = resultItem as! TrainingCompletion
                    appDelegate.backgroundContext!.deleteObject(qItem)
                }
                
                appDelegate.backgroundContext!.save(&error)
        
                //self.redrawMap()
                
        
        var token : String = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        //println(token)
        
               
        API(token: token).deleteTraning(trainingInfo["training_id"] as! Int){
            (data: AnyObject?,error: NSError?) -> Void in
            //Nothing to do...
            
            }
        }
      }
    }

    
    //>---------------------------------------------------------------------------------------------------
    // Author Name      :   Justin Mohit
    // Date             :   Aug, 4 2015
    // Input Parameters :   trainingId : Int ,lat : Double ,long: Double ,zm : Int.
    // Purpose          :   delete Church.
    //>---------------------------------------------------------------------------------------------------
    
    func deleteChurch(churchInfo : JSONDictionary){
        
        var token : String = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        //println(token)
        
        API(token: token).deleteChurch(churchInfo as JSONDictionary){
            (data: AnyObject?,error: NSError?) -> Void in
            //Nothing to do...
            //println(data)
            
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                var error : NSError? = nil
                var qReq: NSFetchRequest = NSFetchRequest(entityName: "Church")
                qReq.includesPropertyValues = false
                qReq.predicate = NSPredicate(format: "id = %@", churchInfo["id"] as! NSNumber)
                if let objects = appDelegate.backgroundContext!.executeFetchRequest(qReq, error:&error) {
                    
                    for resultItem in objects {
                        var qItem = resultItem as! Church
                        appDelegate.backgroundContext!.deleteObject(qItem)
                    }
                    
                    appDelegate.backgroundContext!.save(&error)
                }
            
            self.redrawMap()
        }
    }
    
    
    func redrawMap(){
               
        //println("This is run on the background queue")
        
        var ministryId  = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String?
        var mcc  = (NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String?)
        
        if(mcc != nil){
            mcc = mcc!.lowercaseString
        }
        
        makeUserEnable = true
        self.makeMenuBtnEnable()

        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
        
        moc?.performBlockAndWait ({
            
            
            if  mcc! == "llm" || mcc! == "slm"  {
                
                NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowTargets)
                NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowGroups)
                NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowChurches)
                NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowMultiplyingChurches)
                NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowParents)
            }
            
            if ministryId != nil{
                let min_name=NSUserDefaults.standardUserDefaults().objectForKey("ministry_name") as! String!
                let mcc=NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String!
                
                //  self.lblMinistry.text = "\(min_name) (\(mcc))"
                var error: NSError?
                
                
                
                let fetchRequest = NSFetchRequest(entityName:"Church")
                
                
                let fr =  NSFetchRequest(entityName:"Ministry" )
                fr.predicate = NSPredicate(format: "id == %@", ministryId! )
                
                
                let min = moc!.executeFetchRequest(fr,error: &error) as! [Ministry]
                if min.count>0{
                    self.ministry = min.first!
                    
                    
                    //  mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(ministry!.latitude.doubleValue as CLLocationDegrees,ministry!.longitude.doubleValue as CLLocationDegrees), zoom: ministry.zoom.floatValue , bearing: 0, viewingAngle: 0)
                }
                
                
                var devs:[Int] = Array()
                if ((NSUserDefaults.standardUserDefaults().objectForKey(GlobalConstants.kShowTargets) as! Bool?) != false) { devs.append(1) }
                if ((NSUserDefaults.standardUserDefaults().objectForKey(GlobalConstants.kShowGroups) as! Bool?) != false) { devs.append(2) }
                
                if ((NSUserDefaults.standardUserDefaults().objectForKey(GlobalConstants.kShowChurches) as! Bool?) != false) { devs.append(3) }
                
                if ((NSUserDefaults.standardUserDefaults().objectForKey(GlobalConstants.kShowMultiplyingChurches) as! Bool?) != false) { devs.append(5) }
                
                let pred1=NSPredicate(format: "ministry_id = %@", ministryId!)
                let pred2=NSPredicate(format: "development in %@", devs)
                
                
                
                // let pred = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType,  subpredicates: [pred1, pred2])
                
                
                fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [pred1, pred2])
                
                self.churches =
                    moc!.executeFetchRequest(fetchRequest,
                        error: &error) as! [Church]?
                
                // update some UI
                
                    //println("This is run on the main queue, after the previous code in outer block")
                
                    //Find Items to delete
                    var toDelete = self.markers.filter {  (($0 as GMSMarker).userData as! JSONDictionary)["marker_type"] as! String != "church" || !mapViewController.churchesContainsId((($0 as GMSMarker).userData as! JSONDictionary)["id"]  as! NSNumber, churches: self.churches)}
                
                    
                    for m in toDelete{
                        
                        m.map = nil
                        
                    }
                    
                    
                    //Filter the current list
                    self.markers = self.markers.filter { (($0 as GMSMarker).userData as! JSONDictionary)["marker_type"] as! String == "church" && mapViewController.churchesContainsId((($0 as GMSMarker).userData as! JSONDictionary)["id"]  as! NSNumber, churches: self.churches)}
                    
                    //  markers.removeAll(keepCapacity: false)
                    for l in self.churchLines{
                        
                        l.map = nil
                        
                    }
                    
                    for d in self.churchdots{
                        
                        d.map = nil
                        
                    }
                    
                    self.churchLines.removeAll(keepCapacity: false)
                    self.churchdots.removeAll(keepCapacity: false)
                    
                    for c  in self.churches {
                        
                        
                        //determine add or update.
                        
                        var marker: GMSMarker!
                        let searchMarkers = (self.markers.filter { (($0 as GMSMarker).userData as! JSONDictionary)["marker_type"] as! String == "church" && (($0 as GMSMarker).userData as! JSONDictionary)["id"] as! NSNumber == c.id} ) as [GMSMarker]
                        
                        var  position  = CLLocationCoordinate2DMake( c.valueForKey("latitude") as! CLLocationDegrees,c.valueForKey("longitude") as! CLLocationDegrees)
                        
                        if searchMarkers.count > 0{
                            //update
                            marker = searchMarkers.first
                            
                        }
                        else{
                            
                            marker = GMSMarker(position: position)
                            marker.map = self.mapView
                            marker.infoWindowAnchor = CGPointMake(0.5, 0.25)
                            marker.groundAnchor = CGPointMake(0.5, 1.0)
                            self.markers.append(marker)
                        }
                        
                        
                        
                        
                        var dict = JSONDictionary()
                        dict["marker_type"] = "church"
                        
                        for key in c.entity.attributesByName.keys.array{
                            dict[key as! String]=c.valueForKey(key as! String)
                        }
                        
                        marker.icon = UIImage(named: mapViewController.getIconNameForChurch(c.valueForKey("development") as! NSNumber ) )
                        
                        marker.title = c.valueForKey("name") as! String
                        
                        marker.userData = dict
                        
                        if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kShowParents) == true {
                            
                            if let parent = c.parent as Church? {
                                let  path =  GMSMutablePath()
                                
                                path.addLatitude(parent.latitude as CLLocationDegrees, longitude: parent.longitude as CLLocationDegrees)
                                path.addLatitude(c.latitude as CLLocationDegrees, longitude: c.longitude as CLLocationDegrees)
                                
                                let  line = GMSPolyline(path: path)
                                line.strokeWidth = 2
                                
                                var grad = GMSStrokeStyle.gradientFromColor(UIColor.blackColor(), toColor: UIColor.lightGrayColor())
                                
                                line.spans = [GMSStyleSpan(style: grad)]
                                
                                
                                line.strokeColor = UIColor.lightGrayColor()
                                
                                line.map = self.mapView
                                var  marker2 = GMSMarker(position: CLLocationCoordinate2DMake( parent.latitude as CLLocationDegrees,parent.longitude as CLLocationDegrees))
                                marker2.icon = UIImage(named:"dot" )
                                
                                
                                marker2.map = self.mapView
                                marker2.userData = c.id
                                
                                marker2.groundAnchor = CGPointMake(0.5, 0.5)
                                
                                
                                /*
                                var circle = CLLocationCoordinate2D(latitude: parent.latitude as CLLocationDegrees, longitude: parent.longitude as CLLocationDegrees)
                                var circ = GMSCircle(position: circle, radius: 80)
                                circ.fillColor=UIColor.blackColor()
                                circ.map = self.mapView */
                                
                                dict["parent_name"] = parent.name
                                marker.userData = dict
                                
                                
                                self.churchLines.append(line)
                                self.churchdots.append(marker2)
                                
                            }
                        }
                    }
                
                     
                    
                    
                    if mcc != nil{
                        
                        
                        var error: NSError?
                        
                        let fetchRequest2 = NSFetchRequest(entityName:"Training")
                        fetchRequest2.predicate = NSPredicate(format: "ministry_id = %@ AND mcc = %@ AND !( latitude = 0 AND longitude = 0)", ministryId!, mcc!.lowercaseString)
                        self.training =
                            moc!.executeFetchRequest(fetchRequest2,  // change managedContext
                                error: &error) as! [Training]?
                        
                        if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kShowTraining) == false {
                            
                            //Find Items to delete
                            var toDelete = self.markers.filter {  (($0 as GMSMarker).userData as! JSONDictionary)["marker_type"] as! String != "church" || !mapViewController.churchesContainsId((($0 as GMSMarker).userData as! JSONDictionary)["id"]  as! NSNumber, churches: self.churches)}
                            
                            
                            // update some UI
                            
                            
                            
                            for m in toDelete{
                                
                                if(m.userData.valueForKey("marker_type") as! String == "training"){
                                    
                                    m.map = nil
                                    
                                }
                                else {
                                    
                                }
                            }
                        }
                        
                        
                        if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kShowTraining) == true {
                            
                            
                            for t  in self.training {
                                var dict = JSONDictionary()
                                dict["marker_type"] = "training"
                                for key in t.entity.attributesByName.keys.array{
                                    dict[key as! String] = t.valueForKey(key as! String)
                                }
                                
                                dict["stages"] = t.stages
                                
                                var  position  = CLLocationCoordinate2DMake(t.valueForKey("latitude") as! CLLocationDegrees, t.valueForKey("longitude") as! CLLocationDegrees)
                                
                                var  marker = GMSMarker(position: position)
                                marker.icon = UIImage(named: "train" )
                                
                                marker.title = t.valueForKey("name") as! String
                                marker.map = self.mapView
                                marker.userData = dict
                                marker.infoWindowAnchor = CGPointMake(0.5, 0.25)
                                marker.groundAnchor = CGPointMake(0.5, 1.0)
                                self.markers.append(marker)
                            }
                        }
                    }
            } // e
        })

    }
    
    // MARK:- Search Bar delegate method
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        if(autocompleteList.count <= 0)
        {
            autocompleteTableView.hidden = true
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        autocompleteTableView.hidden=true;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        self.loadSearchedChurch()
    }
    
    
    
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        autocompleteTableView.hidden=false;
        self.mapView.bringSubviewToFront(autocompleteTableView)
        var substring:String = (searchBar.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        self.searchAutocompleteEntriesWithSubstring(substring)
        return true
    }
    
    
    func loadSearchedChurch(){
        self.searchController.searchBar.resignFirstResponder()
        autocompleteTableView.hidden=true
        
        for c in churches{
            var r:NSRange = (c.name.lowercaseString as NSString).rangeOfString(self.searchController.searchBar.text.lowercaseString)
            if r.location == 0{
                mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(c.latitude as CLLocationDegrees ,c.longitude as CLLocationDegrees ), zoom: 16, bearing: 0, viewingAngle: 0)
            }
        }
        self.searchController.searchBar.text = ""
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String){
        
        autocompleteList.removeAll(keepCapacity: false)
        if let allChurch = churches {
            for c in allChurch{
                var r:NSRange = (c.name.lowercaseString as NSString).rangeOfString(substring.lowercaseString)
                if r.location == 0{
                    autocompleteList.append(c.name)
                }
            }
            autocompleteTableView.reloadData()

        }
        
        
    }

    
    // MARK:- Google map delegate method
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
        //println(marker)
        mapView.selectedMarker = marker
        mapView.selectedMarker.draggable=true

        //  self.makeSelectedMarkerDraggable()

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
            return "target"
        case 2:
            return "group"
        case 3:
            return "church"
        case 5:
            return "multiply"
        default:
            return ""
        }
    }
    
    
    
    func calloutAccessoryButtonTapped(obj: AnyObject?){
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "calloutButtonTap")
        
        if let marker1 = self.mapView.selectedMarker {  // prevent to nil
            
            //self.performSegueWithIdentifier("churchDetail", sender: self)
            
            let marker = marker1
            var data : JSONDictionary = JSONDictionary()
            
            if let data1 = marker.userData as? JSONDictionary {
                
                data = data1
                
            }
            else {
                
                data = JSONDictionary()
            }
            
            var vc:UIViewController!
            switch data["marker_type"] as! String!{
                case "church":
                    let ch = self.storyboard?.instantiateViewControllerWithIdentifier("ChurchTVC") as! ChurchTVC
                    ch.data = data
                    ch.mapVC = self
                    vc=ch as UIViewController
                
                case "training":
                    NSUserDefaults.standardUserDefaults().setObject(data["date"], forKey: "createdDate")
                    let tr = self.storyboard?.instantiateViewControllerWithIdentifier("trainingViewController") as! trainingViewController
                   
                    if(data["type"] as! String == ""){
                        data["type"] = "Other"
                        tr.data = data
                    }
                    else{
                        tr.data = data
                    }
                    tr.mapVC = self
                    vc=tr as UIViewController
            default:
                break
                
            }
             self.calloutView.hidden=true
            
            if let vc1 = vc {
            
            self.modalPresentationStyle =  UIModalPresentationStyle.PageSheet
            self.presentViewController(vc1, animated: true, completion: nil	)
            
            }
            
            /* let alertView = UIAlertView(title:  (churchData["name"] as String), message: (churchData["name"] as String), delegate: nil, cancelButtonTitle: "OK")
            
            alertView.show()*/
        }
    }
    
    
    
    
    func mapView(mapView: GMSMapView!, didEndDraggingMarker marker: GMSMarker!) {
        
        // flag = false
        
        for m in markers{
            m.opacity=1.0
            m.tappable = true
            m.draggable = false
        }
        lblMove.hidden = true
        
        if (marker.userData as! JSONDictionary)["marker_type"] as! String == "church"{
            let fetchRequest = NSFetchRequest(entityName:"Church")
           
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
            
            moc?.performBlock ({
                
             var error: NSError?
            fetchRequest.predicate = NSPredicate(format: "id = %@", (marker.userData as! JSONDictionary)["id"] as! NSNumber)
            let church = moc!.executeFetchRequest(fetchRequest, error: &error) as! [Church]
            if church.count>0{
                
                church.first!.changed=true
                church.first!.latitude = marker.position.latitude
                church.first!.longitude = marker.position.longitude
            }
            
            if !moc!.save(&error) {
                //println("Could not save \(error), \(error?.userInfo)")
            }
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeChurch, object: nil)
            //   GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "church", action: "move", label: nil, value: nil).build()  as [NSObject: AnyObject])
        })
        
        }
            
        else if (marker.userData as! JSONDictionary)["marker_type"] as! String == "training"{
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

            var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
            
            moc?.performBlock ({

                
                let fetchRequest = NSFetchRequest(entityName:"Training")
                var error: NSError?
                
                fetchRequest.predicate = NSPredicate(format: "id = %@", (marker.userData as! JSONDictionary)["id"] as! NSNumber)
                let training = moc!.executeFetchRequest(fetchRequest, error: &error) as! [Training]
                if training.count>0{
                    training.first!.changed=true
                    training.first!.latitude = marker.position.latitude
                    training.first!.longitude = marker.position.longitude
                }
                
                if !moc!.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kDidChangeTraining, object: nil)
            
            
            })
            
            
           
            //   GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "training", action: "move", label: nil, value: nil).build()  as [NSObject: AnyObject])
        }
            
        //now save the new location of the current marker
        
        
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        if(isMarkerDraggable == true)
        {
            isMarkerDraggable = false
            return
        }
        
        if HasMcc().hasMcc() == false {
            
            let alertView = UIAlertView(title:"", message: "No MCC found in current Ministry", delegate: nil, cancelButtonTitle: "OK")
            
            alertView.show()
            
        }
            
        else {
            
            //            if flag{
            //
            //
            //            }
            //            else {
            
            longPressLatitude = coordinate.latitude
            longPressLongitude = coordinate.longitude
            
            var btntitles = String()
            if  NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String == "LLM" || NSUserDefaults.standardUserDefaults().objectForKey("mcc") as! String == "SLM"  {
                
                
                let actionSheet = UIActionSheet(title: "Create New?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Training")
                
                actionSheet.showInView(self.mapView)
            }
            else {
                
                let actionSheet = UIActionSheet(title: "Create New?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles:  "Training","Church")
                
                actionSheet.showInView(self.mapView)
                
            }
            
        }
        //}
        
        
        
    }
    
    
    func makeSelectedMarkerDraggable(){
        
        isMarkerDraggable = true
        
        for m in markers{
            m.opacity=0.35
            m.tappable = false
        }
        
        mapView.selectedMarker.opacity=1.0
        //lblMove.hidden = false
        // self.view.bringSubviewToFront(lblMove)
    }
    
    // MARK: - TableView Delegate method
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if(tableView.tag == 0)
        {
            return 1
        }
        else
        {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 0)
        {
            return autocompleteList.count
        }
        else
        {
            if(section == 0)
            {
                return iconArray.count
            }
            else
            {
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(tableView.tag == 0)
        {
            var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("autocompleteCell") as! UITableViewCell
            
            cell.textLabel!.text = autocompleteList[indexPath.row]
            
            return cell
        }
        else
        {

            var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as! UITableViewCell
            
            if cell == nil
            {
                cell = UITableViewCell(style: UITableViewCellStyle.Default,reuseIdentifier:self.cellIdentifier)
                
            }
            else
            {
                for view in cell.subviews
                {
                    view.removeFromSuperview()
                }
                
                cell.prepareForReuse();
            }
            
            if(indexPath.section == 0)
            {
                cell.selectionStyle = UITableViewCellSelectionStyle.None

                var imgTitle = UIImageView()
                imgTitle.frame = CGRectMake(5.0, 10.0, 25.0, 25.0)
                imgTitle.image = UIImage(named:iconImageArray[indexPath.row])
                cell.addSubview(imgTitle)
                
                var txtLabel = UILabel()
                txtLabel.frame = CGRectMake(35.0, 12.0, 250.0, 20.0)
                txtLabel.text = OneSkyOTAPlugin.localizedStringForKey(iconArray[indexPath.row], value: nil, table: nil)//iconArray[indexPath.row]
                txtLabel.textColor = UIColor.blackColor()
                cell.addSubview(txtLabel)
            
                var switchOption = UISwitch()
                switchOption.frame.origin.x = popupTblView.frame.size.width - 60.0
                switchOption.frame.origin.y = 5.0
                cell.addSubview(switchOption)
                if(indexPath.row == 0)
                {
                    if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kShowTargets) as Bool == true)
                    {
                        switchOption.on = true
                    }
                    else
                    {
                        switchOption.on = false
                    }
                }
                else if(indexPath.row == 1)
                {
                    if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kShowGroups) as Bool == true)
                    {
                        switchOption.on = true
                    }
                    else
                    {
                        switchOption.on = false
                    }
                }
                else if(indexPath.row == 2)
                {
                    if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kShowChurches) as Bool == true)
                    {
                        switchOption.on = true
                    }
                    else
                    {
                        switchOption.on = false
                    }
                }
                else if(indexPath.row == 3)
                {
                    if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kShowMultiplyingChurches) as Bool == true)
                    {
                        switchOption.on = true
                    }
                    else
                    {
                        switchOption.on = false
                    }
                }
                else
                {
                    if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kShowTraining) as Bool == true)
                    {
                        switchOption.on = true
                    }
                    else
                    {
                        switchOption.on = false
                    }
                }
                
                var imgSeprator = UIImageView()
                imgSeprator.frame = CGRectMake(0.0, 43.5, tableView.frame.width, 0.5)
                imgSeprator.backgroundColor = UIColor.lightGrayColor()
                cell.addSubview(imgSeprator)
                
                switchOption.tag = (indexPath.section * 1000) + indexPath.row
                switchOption.addTarget(self, action: "changeSwitch:", forControlEvents: UIControlEvents.ValueChanged)
            }
            else
            {
                var txtLabel = UILabel()
                txtLabel.frame = CGRectMake(0.0, 12.0,tableView.frame.size.width, 20.0)
                txtLabel.textAlignment = NSTextAlignment.Center
                txtLabel.text = "Set Default Map"
                txtLabel.textColor = UIColor.blackColor()
                cell.addSubview(txtLabel)
            }
            
            return cell
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView.tag == 0)
        {
            self.searchController.searchBar.text = autocompleteList[indexPath.row]
            self.loadSearchedChurch()
        }
        else
        {
            if(indexPath.section == 1)
            {
                var ministryId  = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as! String?
                
                var mapInfoDic: NSDictionary = NSDictionary(objectsAndKeys: ministryId!,"min_id",mapView.camera.target.latitude,"lat",mapView.camera.target.longitude,"long",mapView.camera.zoom,"zoom" )
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                var moc: NSManagedObjectContext? = appDelegate.managedObjectContext
                
                
                let fetchRequest = NSFetchRequest(entityName:"Ministry")

                moc?.performBlock ({
                
                var error: NSError?
                fetchRequest.predicate = NSPredicate(format: "id = %@", ministryId!)
                let ministry = moc!.executeFetchRequest(fetchRequest, error: &error) as! [Ministry]
                if ministry.count>0{
                    
                    ministry.first!.latitude = self.mapView.camera.target.latitude
                    ministry.first!.longitude = self.mapView.camera.target.longitude
                    ministry.first!.zoom = self.mapView.camera.zoom
                }
                
                if !moc!.save(&error) {
                    //println("Could not save \(error), \(error?.userInfo)")
                }
                
                    })
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kShouldSaveUserPreferences, object: nil, userInfo: mapInfoDic as! JSONDictionary)
                
                isFilterPopupOpen = false
                subView.removeFromSuperview()
            }
        }
    }
    
    
    func changeSwitch(switchIndex: UISwitch)
    {
        
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            println("Work Dispatched")
            // Do heavy or time consuming work
            
            // Create a weak reference to prevent retain cycle and get nil if self is released before run finishes
            dispatch_async(dispatch_get_main_queue()){
                [weak self] in
                // Task 3: Return data and update on the main thread, all UI calls should be on the main thread
                
                if let weakSelf = self {
                    
                    if((switchIndex.tag % 1000) == 0)
                    {
                        if(switchIndex.on){
                            NSUserDefaults.standardUserDefaults().setValue(switchIndex.on, forKey: GlobalConstants.kShowTargets)
                        }
                        else{
                            NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowTargets)
                        }
                    }
                    else if((switchIndex.tag % 1000) == 1)
                    {
                        if(switchIndex.on){
                            NSUserDefaults.standardUserDefaults().setValue(switchIndex.on, forKey: GlobalConstants.kShowGroups)
                        }
                        else{
                            NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowGroups)
                        }
                    }
                    else if((switchIndex.tag % 1000) == 2)
                    {
                        if(switchIndex.on){
                            NSUserDefaults.standardUserDefaults().setValue(switchIndex.on, forKey: GlobalConstants.kShowChurches)
                        }
                        else{
                            NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowChurches)
                        }
                        
                        //call the method for reset the data//
                    }
                    else if((switchIndex.tag % 1000) == 3)
                    {
                        if(switchIndex.on){
                            NSUserDefaults.standardUserDefaults().setValue(switchIndex.on, forKey: GlobalConstants.kShowMultiplyingChurches)
                        }
                        else{
                            NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowMultiplyingChurches)
                        }
                    }
                    else if ((switchIndex.tag % 1000) == 4)
                    {
                        if(switchIndex.on){
                            NSUserDefaults.standardUserDefaults().setValue(switchIndex.on, forKey: GlobalConstants.kShowParents)
                        }
                        else{
                            NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowParents)
                        }
                    }
                    else if ((switchIndex.tag % 1000) == 5)
                    {
                        if(switchIndex.on){
                            NSUserDefaults.standardUserDefaults().setValue(switchIndex.on, forKey: GlobalConstants.kShowTraining)
                        }
                        else{
                            NSUserDefaults.standardUserDefaults().setValue(false, forKey: GlobalConstants.kShowTraining)
                        }
                    }
                    

                    self!.redrawMap()
                    
                    
                    
                }
        
            }
        }

        
        
        
        
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="ShowOptions"{
            let tvc = segue.destinationViewController as! mapOptionsViewController
            tvc.mapVC = self
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
        
    }


