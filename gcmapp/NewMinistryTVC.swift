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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllMinistries()
        tbSearchBox.delegate=self
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
        var token = NSUserDefaults.standardUserDefaults().objectForKey("token") as String
        API(token: token).getMinistries(false){
            (data: AnyObject?,error: NSError?) -> Void in
            if data != nil{
                self.ministryList = data as JSONArray
                
                //self.loadSearchedChurch()
            }
        }
       
        
    }
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //self..hidden=false;
        var substring:String = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        self.searchAutocompleteEntriesWithSubstring(substring)
        return true
    }
    
   
    
    
    
    func searchAutocompleteEntriesWithSubstring(substring: String){
        autocompleteList.removeAll(keepCapacity: false)
        for m  in self.ministryList{
            var r:NSRange = (((m as JSONDictionary)["name"] as String).lowercaseString as NSString).rangeOfString(substring.lowercaseString)
            if r.location == 0{
                autocompleteList.append(m as JSONDictionary)
            }
        }
        self.tableView.reloadData()
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       // tbSearchBox.text = autocompleteList[indexPath.row]["name"] as String
        
        //Add assignment to this team.
        //send it as a notification so dataSync can control this.
        tbSearchBox.resignFirstResponder()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.postNotificationName(GlobalConstants.kShouldJoinMinistry, object: self, userInfo: autocompleteList[indexPath.row])
        
        
        
        self.navigationController?.popViewControllerAnimated(true)
        
        
       // self.loadSearchedChurch()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("autocompleteMinCell", forIndexPath: indexPath) as UITableViewCell
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
