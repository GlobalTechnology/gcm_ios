//
//  churchViewController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 03/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit

class churchViewController: UIViewController {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var contactName: UITextField!
    
    @IBOutlet weak var contactEmail: UITextField!
    
    @IBOutlet weak var churchSize: UITextField!
    
    @IBAction func btnClose(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    var data:JSONDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        name.text = data["name"] as? String
        icon.image = UIImage(named: mapViewController.getIconNameForChurch(data["development"] as NSNumber))
        contactName.text = data["contactName"] as? String
        contactEmail.text = data["contactEmail"] as? String
        churchSize.text = (data["size"] as NSNumber).stringValue
        
        
      //          self.view.backgroundColor =  UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)
    }
      
}
	