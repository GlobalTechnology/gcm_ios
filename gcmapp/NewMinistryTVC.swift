//
//  NewMinistryTVC.swift
//  gcmapp
//
//  Created by Jon Vellacott on 03/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class NewMinistryTVC: UITableViewController, UITextFieldDelegate, NSURLConnectionDataDelegate  {
    @IBOutlet weak var tbSearchBox: UITextField!
    var autocompleteList:[JSONDictionary]! = Array()
    var ministryList =  JSONArray()
    var isModal:Bool = false
    @IBOutlet var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Join Ministry"
     
        if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kNoMinistrySelected) as Bool == true)
        {
//            menuButton.enabled = false
            self.navigationController?.navigationItem.leftBarButtonItem = nil
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kFromLeftMenuHomeTap)
        }
        else
        {
            menuButton.target = self.revealViewController()
            menuButton.action = Selector("revealToggle:")
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        getAllMinistries()
        tbSearchBox.delegate=self
        
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: "Join Ministry")
//        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return autocompleteList.count
    }
    
    
    
    
    func getAllMinistries(){
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.color = UIColor(red:0.0/255.0,green:128.0/255.0,blue:64.0/255.0,alpha:1.0)
        // self.view.sendSubviewToBack(self.tableView)
        
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String {
            API(token: token).getMinistries(false){
                (data: AnyObject?,error: NSError?) -> Void in
                
                
                if data != nil{
                    self.ministryList = data as! JSONArray
                    self.autocompleteList.removeAll(keepCapacity: true)

                    for m  in self.ministryList{

                    self.autocompleteList.append(m as! JSONDictionary)
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //self..hidden=false;
        
            var substring:String = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
               self.searchAutocompleteEntriesWithSubstring(substring)
        
        if (substring.isEmpty == true){
            
           
            self.autocompleteList.removeAll(keepCapacity: true)
            
            for m  in self.ministryList{
                self.autocompleteList.append(m as! JSONDictionary)
            }
           
            self.tableView.reloadData()
            
            
            
        }
        else {
            
        }
        
      
//        textField.reloadInputViews()
//        
//        if textField.isFirstResponder() {
//            textField.resignFirstResponder()
//            textField.becomeFirstResponder()
//        }
        
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
       
        textField.resignFirstResponder()
        return true
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String){
        autocompleteList.removeAll(keepCapacity: false)
        for m  in self.ministryList{
            var r:NSRange = (((m as! JSONDictionary)["name"] as! String).lowercaseString as NSString).rangeOfString(substring.lowercaseString)
            if r.location == 0{
                autocompleteList.append(m as! JSONDictionary)
            }
        }
        self.tableView.reloadData()
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       // tbSearchBox.text = autocompleteList[indexPath.row]["name"] as String
        
        // believe it or not, this can get called with autocompleteList as empty!
        if (autocompleteList.count > 0) {
            
            // maybe there is a race condition, but  autocompleteList.count can
            // be >0 entering into this section and then empty by the time we hit the
            // .postNotification() below.  putting this here apparently reduces the 
            // chance we are hitting that situation.
            var userInfo = autocompleteList[indexPath.row]
            
            //Add assignment to this team.
            //send it as a notification so dataSync can control this.
            tbSearchBox.resignFirstResponder()
           
                /* Done By Caleb Kapil */
            
            var alertController = UIAlertController(title: "", message: "Do you want to join this ministry?", preferredStyle: .Alert)
            
            // Create the actions
            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                
                NSLog("OK Pressed")
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kShouldJoinMinistry, object: self, userInfo: userInfo)
                
                
                if(NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kNoMinistrySelected) as Bool == true)
                {
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kNoMinistrySelected)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
            
            //            self.navigationController?.popViewControllerAnimated(true)
            //            if self.isModal {
            //                self.removeFromParentViewController()
            //            }
            
            //----------------------------------------------------------------//
            
            //   GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory( "assignments", action: "join ministry", label: nil, value: nil).build()  as [NSObject: AnyObject])
        
        } else {
            //println("NewMinistryTVC.tableView( didSelectRowAtIndexPath:)");
            //println("... called when autocompleteList is empty!  why?");
        }
        
       // self.loadSearchedChurch()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("autocompleteMinCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = autocompleteList[indexPath.row]["name"] as? String
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
