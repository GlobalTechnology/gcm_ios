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
        var mv: MeasurementValue!
        var mls: MeasurementLocalSource!
        var isLocalSource = false;
        @IBAction func editValueDidChanged(sender: UITextField) {
            if(isLocalSource){
                if(mls.value != (editValue.text as NSString!).integerValue){
                    mls.changed = true
                    mls.value = (editValue.text as NSString!).integerValue
                }
                
            }
            else
            {
                if(mv.me != (editValue.text as NSString!).integerValue){
                    mv.changed=true
                    mv.me = (editValue.text as NSString!).integerValue
                }
            }
           /* var error: NSError?
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            
            let managedContext = appDelegate.managedObjectContext!
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(GlobalConstants.kDidChangeMeasurementValues, object: nil)*/
            
        }
    }
