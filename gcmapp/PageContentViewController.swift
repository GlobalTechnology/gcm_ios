//
//  PageContentViewController.swift
//  gcmapp
//
//  Created by Mark Briggs on 3/7/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {

    var pageIndex: Int?
    //var titleText : String!
    //var imageName : String!
    
    var measurementType : Int!
    
    var measurementDescription: String!
    //var measurementValue: Int!
    var measurementValue: String!
    
    @IBOutlet weak var measurementDescriptionLbl: UITextView!
    @IBOutlet weak var measurementValueLbl: UILabel!
    
    
    @IBOutlet weak var wbsCategory: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //measurementValue.backgroundColor = UIColor(patternImage: UIImage(named: "numberCircle")!)
        
        
        
        measurementDescriptionLbl.text = measurementDescription
        //measurementValueLbl.text = measurementValue.description
        measurementValueLbl.text = measurementValue
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
