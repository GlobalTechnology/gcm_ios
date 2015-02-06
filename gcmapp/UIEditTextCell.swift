//
//  UIEditTextCell.swift
//  gcmapp
//
//  Created by Jon Vellacott on 28/01/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class UIEditTextCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    
    @IBAction func tbEditingDidEnd(sender: UITextField) {
        if self.isChurch{
            if field_name == "size"{
                if church.data[field_name] as NSNumber != (value.text! as NSString).integerValue{
                    church.data[field_name] = (value.text! as NSString).integerValue
                    church.changed = true
                    //let notificationCenter = NSNotificationCenter.defaultCenter()
                    //notificationCenter.postNotificationName(GlobalConstants.kDidChangeChurch, object: nil)

                }
            }
            else{
                if church.data[field_name] as? String != value.text{
                    church.data[field_name] =  value.text
                    church.changed = true
                    //let notificationCenter = NSNotificationCenter.defaultCenter()
                    //notificationCenter.postNotificationName(GlobalConstants.kDidChangeChurch, object: nil)
                }
            }
            
            
            
            
        }
        else
        {
            if training.data[field_name] as? String != value.text{
                training.data[field_name] = value.text
                training.changed = true
                //let notificationCenter = NSNotificationCenter.defaultCenter()
                //notificationCenter.postNotificationName(GlobalConstants.kDidChangeTraining, object: nil)
            }
        }
       
        
    }

    
    @IBOutlet weak var value: UITextField!
    var field_name:String = ""
    var church:ChurchTVC!
    var training:trainingViewController!
    var isChurch:Bool = true
    
    
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
