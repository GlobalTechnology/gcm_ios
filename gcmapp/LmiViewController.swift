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
    
    let VIEW_FAITH = 0;
    let VIEW_FRUIT = 1;
    let VIEW_OUTCOMES = 2;
    
    override func viewDidLoad() {
        println("*** av ***")
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds

        // Do any additional setup after loading the view.
        
        let header1 = self.measurementHeader(VIEW_FAITH)
        
        
        /*
        
        let header1 = UIButton();
        header1.frame = CGRectMake(0, 0, 0, 100);
        header1.setBackgroundImage(UIImage(named: "FaithHeader"), forState: UIControlState.Normal)
        header1.backgroundColor = UIColor.blueColor()
        header1.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        header1.setTitle("Faith Actions", forState: UIControlState.Normal)
        header1.titleLabel?.font = UIFont(name: "Helvetica", size: 30)
        header1.titleEdgeInsets = UIEdgeInsetsMake(0, 120, 0, 0)
        header1.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        */
        
        /*
        let btnLabel1 = UILabel();
        btnLabel1.text = "Faith"
        header1.addSubview(btnLabel1)
        */
        
        
        let view1 = self.measurementView(VIEW_FAITH)
        /*
        let view1 = UIView();
        view1.frame = CGRectMake(0, 0, 0, 200)
        view1.backgroundColor = UIColor.whiteColor()
        
        // Faith Circle Bottom
        let circleBottomIV = UIImageView()
        circleBottomIV.frame = CGRectMake(0, 0, 79, 28)
        let circleBottom1 = UIImage(named: "FaithBottomCircle")
        circleBottomIV.image = circleBottom1
        view1.addSubview(circleBottomIV)
        
        // Top Shadow
        let topShadowIV = UIImageView();
        topShadowIV.frame = CGRectMake(79, 0, 400, 15)
        let topShadow1 = UIImage(named: "TopShadow")
        topShadowIV.image = topShadow1
        view1.addSubview(topShadowIV)
        
        // Bottom Shadow
        let bottomShadowIV = UIImageView();
        bottomShadowIV.frame = CGRectMake(0, 185, 480, 15)
        let bottomShadow1 = UIImage(named: "BottomShadow");
        bottomShadowIV.image = bottomShadow1
        view1.addSubview(bottomShadowIV)
        */
        
        // ==== Header 2 ======
        let header2 = self.measurementHeader(VIEW_FRUIT)
        /*
        let header2 = UIButton();
        header2.frame = CGRectMake(0, 0, 0, 100);
        header2.setImage(UIImage(named: "FruitHeader"), forState: UIControlState.Normal)
        header2.backgroundColor = UIColor.blueColor()
        */
        
        let view2 = self.measurementView(VIEW_FRUIT)
        /*
        let view2 = UIView();
        view2.frame = CGRectMake(0, 0, 0, 200)
        view2.backgroundColor = UIColor.greenColor()
        */
        
        // ==== Header 3 ======
        let header3 = self.measurementHeader(VIEW_OUTCOMES)
        /*
        let header3 = UIButton();
        header3.frame = CGRectMake(0, 0, 0, 100);
        header3.setImage(UIImage(named: "OutcomesHeader"), forState: UIControlState.Normal)
        header3.backgroundColor = UIColor.blueColor()
        */
        
        let view3 = self.measurementView(VIEW_OUTCOMES)
        
        accView.frame = CGRectMake(0, 20, screenSize.width, screenSize.height)
        
        accView.addHeader(header1, withView: view1)
        accView.addHeader(header2, withView: view2)
        accView.addHeader(header3, withView: view3)
        
        accView.allowsEmptySelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func measurementHeader(viewType: Int) -> UIButton {
        let header = UIButton();
        header.frame = CGRectMake(0, 0, 0, 100);
        header.backgroundColor = UIColor.blueColor()
        header.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        header.titleLabel?.font = UIFont(name: "Helvetica", size: 30)
        header.titleEdgeInsets = UIEdgeInsetsMake(0, 120, 0, 0)
        header.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        var bgImageName: String
        var headerTitle: String
        
        switch viewType {
        case VIEW_FAITH:
            bgImageName = "FaithHeader"
            headerTitle = "Faith Actions"
        case VIEW_FRUIT:
            bgImageName = "FruitHeader"
            headerTitle = "Fruiter"
        case VIEW_OUTCOMES:
            bgImageName = "OutcomesHeader"
            headerTitle = "Outcomes"
        default:
            bgImageName = "FaithHeader"
            headerTitle = "Faith Actions"
        }
        
        header.setBackgroundImage(UIImage(named: bgImageName), forState: UIControlState.Normal)
        header.setTitle(headerTitle, forState: UIControlState.Normal)
        
        return header
    }
    
    func measurementView(viewType: Int) -> UIView {
        
        let view = UIView();
        view.frame = CGRectMake(0, 0, 0, 200)
        view.backgroundColor = UIColor.whiteColor()
        
        var bottomCircleImageName: String
        
        switch viewType {
        case VIEW_FAITH:
            bottomCircleImageName = "FaithBottomCircle"
        case VIEW_FRUIT:
            //bottomCircleImageName = "FruitBottomCircle"
            bottomCircleImageName = "FaithBottomCircle"
        case VIEW_OUTCOMES:
            //bottomCircleImageName = "OutcomesBottomCircle"
            bottomCircleImageName = "FaithBottomCircle"
        default:
            bottomCircleImageName = "FaithBottomCircle"
        }
        
        
        
        
        
        // Faith Circle Bottom
        let circleBottomIV = UIImageView()
        circleBottomIV.frame = CGRectMake(0, 0, 79, 28)
        let circleBottom = UIImage(named: bottomCircleImageName)
        circleBottomIV.image = circleBottom
        view.addSubview(circleBottomIV)
        
        // Top Shadow
        let topShadowIV = UIImageView();
        topShadowIV.frame = CGRectMake(79, 0, 400, 15)
        let topShadow = UIImage(named: "TopShadow")
        topShadowIV.image = topShadow
        view.addSubview(topShadowIV)
        
        // Bottom Shadow
        let bottomShadowIV = UIImageView();
        bottomShadowIV.frame = CGRectMake(0, 185, 480, 15)
        let bottomShadow = UIImage(named: "BottomShadow");
        bottomShadowIV.image = bottomShadow
        view.addSubview(bottomShadowIV)
        
        
        //let mPVCViewController = UIViewController();
        //mPVCViewController.frame = CGRectMake(0, 0, 500, 200)

        //let mVC = measurementsVC()
        let mPVC = measurementsPVC()
        view.addSubview(mPVC.view)
        
        
        
        
        return view
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
