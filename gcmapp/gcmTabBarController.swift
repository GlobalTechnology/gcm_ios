//
//  gcmTabBarController.swift
//  gcmapp
//
//  Created by Jon Vellacott on 04/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit

class gcmTabBarController: UITabBarController , TheKeyOAuth2ClientLoginDelegate{
    var sync: dataSync!
    private let notificationManager = NotificationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tabBar.tintColor = UIColor(red: 13.0/255, green: 25.0/255, blue: 49.0/255, alpha: 1.0)
        
        // self.sync=dataSync()
      
        // Do any additional setup after loading the view.
      if let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist") {
            var dict = NSDictionary(contentsOfFile: path) as! Dictionary<String, String>
            // Use your dict here
            let url = dict["TheKeyServerURL"]
            let client_id = dict["TheKeyClientId"]
            
            //  //println("TheKeyerverURL: \(url) ClientId: \(client_id)")
            
            
            TheKeyOAuth2Client.sharedOAuth2Client().setServerURL(NSURL(string: url!) , clientId: client_id!  )
        
            let notificationCenter = NSNotificationCenter.defaultCenter()
            let mainQueue = NSOperationQueue.mainQueue()
            
            
            notificationManager.registerObserver(TheKeyOAuth2ClientDidChangeGuidNotification, forObject: TheKeyOAuth2Client.sharedOAuth2Client()){ note in
                
                if  TheKeyOAuth2Client.sharedOAuth2Client().isAuthenticated() {
                    self.postLoginNotification()
                } else{
                    self.sync.token=""
                    TheKeyOAuth2Client.sharedOAuth2Client().presentLoginViewController(NSClassFromString("GMALoginViewController") , fromViewController: self, loginDelegate: self)
                }
            }
           
            
            if (TheKeyOAuth2Client.sharedOAuth2Client().isAuthenticated() && TheKeyOAuth2Client.sharedOAuth2Client().guid() != nil){
                postLoginNotification()
                
            }else
            {
                //
                TheKeyOAuth2Client.sharedOAuth2Client().logout()
            }
            
            notificationManager.registerObserver(GlobalConstants.kLogout){ note in
              
                self.sync.token=""
            }
            
            
        } 
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
       
    }
 
    func postLoginNotification(){
        
         let notificationCenter = NSNotificationCenter.defaultCenter()
         notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
    }

    func loginViewController(loginViewController: TheKeyOAuth2LoginViewController!, loginError error: NSError!) {
        //println(error)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    override func shouldAutorotate() -> Bool {
        //return false
        return self.selectedViewController!.shouldAutorotate()
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if let vc = self.selectedViewController {
            return vc.supportedInterfaceOrientations()
        }
        return super.supportedInterfaceOrientations()
        
        //return self.selectedViewController!.supportedInterfaceOrientations()
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
