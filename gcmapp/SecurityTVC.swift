//
//  SecurityTVC.swift
//  gcmapp
//
//  Created by Jon Vellacott on 28/01/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class SecurityTVC: UITableViewController {
   var church:ChurchTVC!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)

    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if church.data["security"] == nil{
            church.data["secutiry"] = 2
            }
            var old_value = church.data["security"]  as! NSNumber
        
        switch(indexPath.row){
        case 0:
            church.data["security"] = 0
            break
        case 1:
            church.data["security"] = 1
            break
        case 2:
            church.data["security"] = 2
            break
        default:
            break
            
        }
        
        self.church.changed = old_value != church.data["security"] as! NSNumber
        
        self.church.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var row:Int = -1
        if church.data["security"] != nil{
        switch(church.data["security"] as! NSNumber){
        case 0:
            row=0
            break
        case 1:
            row=1
            break
        case 2:
            row=2
            break
        case 3:
            row=2
            break
        default:
            break
            
        }
        if row>=0{
            tableView.selectRowAtIndexPath(NSIndexPath(forRow:row, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
            tableView.cellForRowAtIndexPath(NSIndexPath(forRow:row, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        }
        
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
        return 3
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
