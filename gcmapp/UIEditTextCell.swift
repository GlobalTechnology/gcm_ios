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
        
        church.data[field_name] = ((field_name == "size") ? (value.text! as NSString).integerValue : value.text)
        church.changed = true
        
    }
    @IBOutlet weak var value: UITextField!
    var field_name:String = ""
    var church:ChurchTVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
