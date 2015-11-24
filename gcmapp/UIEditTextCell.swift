//
//  UIEditTextCell.swift
//  gcmapp
//
//  Created by Jon Vellacott on 28/01/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class UIEditTextCell: UITableViewCell,UITextFieldDelegate {
    @IBOutlet weak var title: UILabel!
    
    @IBAction func tbEditingDidEnd(sender: UITextField) {
        if self.isChurch{
            if field_name == "size"{
                if church.data[field_name] as! NSNumber != (value.text! as NSString).integerValue{
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
        value.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK:- UITextField delegate method
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag == 4){
        let maxLength = 4
        let currentString: NSString = textField.text
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
        else if(textField.tag == 3){
            let maxLength = 15
            let currentString: NSString = textField.text
            let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
            return newString.length <= maxLength
        }
        else{
           return true
        }
    }
}
