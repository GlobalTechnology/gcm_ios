    //
    //  MeasDetailEditCell.swift
    //  gcmapp
    //
    //  Created by Jon Vellacott on 10/12/2014.
    //  Copyright (c) 2014 Expidev. All rights reserved.
    //
    
    import UIKit
    
    
    class MeasDetailEditCell: UITableViewCell {
        
        @IBOutlet weak var editValue: UITextField!
        
        @IBOutlet weak var lblTitle: UILabel!
        var me: MeasurementMeSource!
        var mls: MeasurementLocalSource!
        var isLocalSource = false;
     

        
        @IBAction func editValueDidChanged(sender: UITextField) {
             let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var error: NSError?
            let managedContext = appDelegate.managedObjectContext!
            if(isLocalSource){
                if(mls.value != (editValue.text as NSString!).integerValue){
                    mls.changed = true
                    mls.value = (editValue.text as NSString!).integerValue
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    let notificationCenter = NSNotificationCenter.defaultCenter()
                    notificationCenter.postNotificationName(GlobalConstants.kDidChangeMeasurementValues, object: nil)

                }
                
            }
            else
            {
                if(me.value != (editValue.text as NSString!).integerValue){
                    me.changed=true
                    me.value = (editValue.text as NSString!).integerValue
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    let notificationCenter = NSNotificationCenter.defaultCenter()
                    notificationCenter.postNotificationName(GlobalConstants.kDidChangeMeasurementValues, object: nil)

                }
            }
           /* var error: NSError?
           
            
            
            
            
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeMeasurementValues, object: nil)*/
            
        }
    }
