	//
//  MeasurementSummaryCell.swift
//  gcmapp
//
//  Created by Jon Vellacott on 02/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class MeasurementSummaryCell: UITableViewCell {

    @IBOutlet weak var lblRow: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var tbValue: UITextField!
    var me: MeasurementMeSource!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func editValueDidChanged(sender: UITextField) {
        if me == nil{
            //create a blank one.
            
        }
        
            if(me.value != (tbValue.text as NSString!).integerValue){
                me.changed=true
                me.value = (tbValue.text as NSString!).integerValue
                var error: NSError?
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext!
                if !managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                    
                }
                
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(GlobalConstants.kDidChangeMeasurementValues, object: nil)
            }
      
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
