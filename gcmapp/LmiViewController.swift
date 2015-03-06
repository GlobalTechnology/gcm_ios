//
//  Lmi3ViewController.swift
//  gcmapp
//
//  Created by Mark Briggs on 3/5/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class LmiViewController: UIViewController {

    @IBOutlet weak var accView: AccordionView!
    
    override func viewDidLoad() {
        println("*** av ***")
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds

        // Do any additional setup after loading the view.
        //UIButton header1 =
        //var header1:UIButton;
        let header1 = UIButton();
        //header1.setTitle("ttttt", forState: UIControlState.Normal)
        header1.frame = CGRectMake(0, 0, 20, 100);
        header1.setImage(UIImage(named: "measure30"), forState: UIControlState.Normal)
        header1.backgroundColor = UIColor.blueColor()
        
        let view1 = UIView();
        view1.frame = CGRectMake(0, 0, 0, 200)
        view1.backgroundColor = UIColor.redColor()
        
        let pc1 = UIPageViewController();
        //pc1.
        
        // ==== Header 2 ======
        let header2 = UIButton();
        //header1.setTitle("ttttt", forState: UIControlState.Normal)
        header2.frame = CGRectMake(0, 0, 0, 100);
        header2.setImage(UIImage(named: "groupiconlock"), forState: UIControlState.Normal)
        header2.backgroundColor = UIColor.blueColor()
        
        let view2 = UIView();
        view2.frame = CGRectMake(0, 0, 0, 200)
        view2.backgroundColor = UIColor.greenColor()
        
        accView.frame = CGRectMake(0, 20, screenSize.width, screenSize.height)
        accView.addHeader(header1, withView: view1)
        accView.addHeader(header2, withView: view2)
        
        accView.allowsEmptySelection = false
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
