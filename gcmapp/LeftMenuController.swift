//
//  BackTableVC.swift
//  SlideoutMenu
//
//  Created by Justin mohit on 4/8/15.
//  Copyright (c) 2015 Archetapp. All rights reserved.
//

import Foundation

class LeftMenuController: UIViewController {
    
    var TableArray = [String]()
    
    @IBOutlet var tblView: UITableView!
    let cellIdentifier = "cellIdentifier"

    override func viewDidLoad() {
        
        self.tblView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier);

        TableArray = ["Home","Measurements","Refresh","Join New Ministry","Supported staff","Settings","Logout"]

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "logout:",
            name: GlobalConstants.kLogoutNotification,
            object: nil)
        
    }
    
    @objc func logout(notification: NSNotification){
        //do stuff
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    override func viewWillAppear(animated: Bool) {
        
        tblView.reloadData()
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 8
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 0
        {
            
        return 60.0;//Choose your custom row height
        }
        else {
            return 44.0
        }
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

//        var cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? UITableViewCell
//        
//        if cell == nil {
//            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
//        }
        
        
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as! UITableViewCell
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,reuseIdentifier:self.cellIdentifier)
        }
        else
        {
            for view in cell.contentView.subviews
            {
                view.removeFromSuperview()
            }
            
            cell.prepareForReuse();
        }
        
        
        if(indexPath.row == 0)
        {
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            
            var lblName:UILabel = UILabel()
            lblName.frame = CGRectMake(10.0, 5.0, 300.0, 20.0)
            lblName.textColor = UIColor.blackColor()
            lblName.font = UIFont.systemFontOfSize(18.0, weight: 26.0)
            
            var welcome = OneSkyOTAPlugin.localizedStringForKey("Welcome", value: nil, table: nil)
            
            if let name = NSUserDefaults.standardUserDefaults().objectForKey("first_name") as? String {
                lblName.text = "\(welcome), \(name)"
                
                
            }
            else {
                lblName.text = ""
            }
            
            cell.contentView.addSubview(lblName)
            
            var lblRole:UILabel = UILabel()
            lblRole.frame = CGRectMake(10.0, 30.0, 300.0, 20.0)
            lblRole.textColor = UIColor.grayColor()
            lblRole.font = UIFont.systemFontOfSize(16.0, weight: 16.0)
            
            if let teamRole = NSUserDefaults.standardUserDefaults().objectForKey("team_role") as? String{
                
                
                lblRole.text = GlobalFunctions.getTeamRoleFormatted(teamRole)
            }
            else {
                lblRole.text = ""
            }
            
            cell.contentView.addSubview(lblRole)
        }
        else if(indexPath.row == 5)
        {
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            
            var lblName:UILabel = UILabel()
            lblName.frame = CGRectMake(10.0, 13.0, 300.0, 20.0)
            lblName.text = OneSkyOTAPlugin.localizedStringForKey(TableArray[indexPath.row - 1], value: nil, table: nil)
            
            cell.contentView.addSubview(lblName)
            
            
            var toggleSwitch = UISwitch()
            toggleSwitch.frame = CGRect(x: 200.0, y: 5.0, width: 40.0, height: 25.0)
            
            if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kSupprotedStaffSwichKey) as Bool == true){
                toggleSwitch.setOn(true, animated: false)
            }
            else{
                toggleSwitch.setOn(false, animated: false)
            }
            
            toggleSwitch.addTarget(self, action: "SupprotedStaffSwichChange:", forControlEvents: UIControlEvents.ValueChanged)
            cell.contentView.addSubview(toggleSwitch)
        }
        else{
            var lblName:UILabel = UILabel()
            lblName.frame = CGRectMake(10.0, 13.0, 300.0, 20.0)
            lblName.text = OneSkyOTAPlugin.localizedStringForKey(TableArray[indexPath.row - 1], value: nil, table: nil)
            
            cell.contentView.addSubview(lblName)
        }
        
        return cell!
    }
    
//     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        cell.separatorInset = UIEdgeInsetsZero
//        let lineView : UIView = UIView(frame: CGRectMake(0, cell.contentView.frame.size.height - 0.5, cell.contentView.frame.size.width, 0.5))
//        lineView.backgroundColor = UIColor(red: 81.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1.0)
//        //cell.contentView.addSubview(lineView)
//        
//        var customColorView : UIView = UIView()
//        customColorView.backgroundColor = UIColor(red: 212.0/255.0, green: 207.0/255.0, blue: 205.0/255.0, alpha: 1.0)
//        cell.selectedBackgroundView =  customColorView
//        
//    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // Do heavy or time consuming work
           
           
            // Create a weak reference to prevent retain cycle and get nil if self is released before run finishes
            dispatch_async(dispatch_get_main_queue()){
                [weak self] in
                
                
                // Task 3: Return data and update on the main thread, all UI calls should be on the main thread
                
                if let weakSelf = self {
                    
                    var storyboard = UIStoryboard(name: "Main", bundle: nil)
                    switch (indexPath.row)
                    {
                    case 1:
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kFromLeftMenuHomeTap)
                        var initialViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("home") as! UIViewController
                        weakSelf.revealViewController().pushFrontViewController(initialViewController, animated: true)
                    
                        break
                        
                    case 2:
                        if var team_role  = NSUserDefaults.standardUserDefaults().objectForKey("team_role") as? String {
                            
                            if team_role == "self_assigned" {
                                
                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kFromLeftMenuHomeTap)
                                var initialViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("home") as! UIViewController
                                weakSelf.revealViewController().pushFrontViewController(initialViewController, animated: true)
                                return
                            }
                        }
                        
                        
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kReloadPageControllerOnce)

                        var initialViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("Measurements") as! UIViewController
                        weakSelf.revealViewController().pushFrontViewController(initialViewController, animated: true)
                        
                        break
                        
                    case 3:
                        let notificationCenter = NSNotificationCenter.defaultCenter()
                        notificationCenter.postNotificationName(GlobalConstants.kShouldRefreshAll, object: nil)
                        
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kFromLeftMenuHomeTap)
                        var initialViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("home") as! UIViewController
                        weakSelf.revealViewController().pushFrontViewController(initialViewController, animated: true)
                        
                        break
                        
                    case 4:
                        var initialViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("NewMinistryTVC") as! UIViewController
                        weakSelf.revealViewController().pushFrontViewController(initialViewController, animated: true)
                        
                        break
                   
                    case 6:
                        var initialViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("settings") as! UIViewController
                        weakSelf.revealViewController().pushFrontViewController(initialViewController, animated: true)
                    
                        break
                        
                        
                    case 7:
                        let notificationCenter = NSNotificationCenter.defaultCenter()
                        notificationCenter.postNotificationName(GlobalConstants.kLogout, object: self)
                        NSUserDefaults.standardUserDefaults().removeObjectForKey(GlobalConstants.kDoOnceSettingActive)
                        break
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func SupprotedStaffSwichChange(swtch: UISwitch)
    {
        if(swtch.on)
        {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kSupprotedStaffSwichKey)
          

            var mapInfoDic: NSDictionary = NSDictionary(objectsAndKeys: 1,"supported_staff")
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kShouldSaveSupportStaffUserPreferences, object: nil, userInfo: mapInfoDic as! JSONDictionary)
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kSupprotedStaffSwichKey)
            
            var mapInfoDic: NSDictionary = NSDictionary(objectsAndKeys: 0,"supported_staff")
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kShouldSaveSupportStaffUserPreferences, object: nil, userInfo: mapInfoDic as! JSONDictionary)
        }
        
        tblView.reloadData()
    }
}