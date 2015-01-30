//
//  trainingViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 08/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit
import CoreData

class trainingViewController: UITableViewController, UITableViewDelegate,UITextFieldDelegate {
    
    
    
    var data:JSONDictionary!
    var tc:[TrainingCompletion]!
    var changed:Bool = false
    var mapVC:  mapViewController!
    
    
    
    @IBOutlet weak var name: UILabel!
    
    @IBAction func btnClose(sender: UIButton) {
       self.SaveChanges()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnMove(sender: UIButton) {
        self.SaveChanges()
        self.mapVC.makeSelectedMarkerDraggable()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func SaveChanges() {
        if self.changed {
            //broadcast for update
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeTrainingCompletion, object: nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if(data["name"] != nil){
            name.text = data["name"] as? String
        }
        
        
        let descriptor = NSSortDescriptor(key: "phase", ascending: true)
        
        tc = (data["stages"] as NSSet).sortedArrayUsingDescriptors([descriptor]) as [TrainingCompletion]
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        tableView.addGestureRecognizer(tap)
        
        
        
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        tableView.endEditing(true)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let stage = tc[textField.tag ] as TrainingCompletion
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        if stage.number_completed != (textField.text as NSString).integerValue
        {
            stage.number_completed = (textField.text as NSString).integerValue
            stage.changed = true
            self.changed = true
            
            var error: NSError?
            
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data["stages"] == nil{
            return 0
        }
        else
        {
            return   tc.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TrainingCompCell", forIndexPath: indexPath) as TrainingCompCell
        
        var stage = tc[indexPath.row] as TrainingCompletion
        cell.stage.text = stage.phase.stringValue
        cell.date.text  = stage.date
        cell.participants.text = stage.number_completed.stringValue
        cell.participants.delegate = self
        cell.participants.tag = indexPath.row
        
        
        
        
        
        return cell
    }
    
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }
    
    
}
