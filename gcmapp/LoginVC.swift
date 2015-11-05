//
//  ViewController.swift
//  GMA
//
//  Created by Justin Mohit on 25/08/15.
//  Copyright (c) 2015 Justin Mohit. All rights reserved.
//

import UIKit

class LoginVC: UIViewController,TheKeyOAuth2ClientLoginDelegate {

    private let notificationManager = NotificationManager()
    var sync: dataSync!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
     self.sync=dataSync()
     
        if let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist") {
            var dict = NSDictionary(contentsOfFile: path) as! Dictionary<String, String>
            // Use your dict here
            let url = dict["TheKeyServerURL"]
            let client_id = dict["TheKeyClientId"]
            
            //  //println("TheKeyerverURL: \(url) ClientId: \(client_id)")
            
            
            TheKeyOAuth2Client.sharedOAuth2Client().setServerURL(NSURL(string: url!) , clientId: client_id!  )
            
            
            notificationManager.registerObserver(TheKeyOAuth2ClientDidChangeGuidNotification, forObject: TheKeyOAuth2Client.sharedOAuth2Client()){ note in
                
                if  TheKeyOAuth2Client.sharedOAuth2Client().isAuthenticated() {
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isLoggedIn")
                    
                    self.postLoginNotification()
                    self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("SWRevealViewController") as! UIViewController, animated: false)
                }
                else
                {
                    
                    self.sync.token=""
                self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("SWRevealViewController") as! UIViewController, animated: false)
                    
                    TheKeyOAuth2Client.sharedOAuth2Client().presentLoginViewController(NSClassFromString("GMALoginViewController") , fromViewController: self, loginDelegate: self)
                
                    
                
                }
            }
            
            
            if (TheKeyOAuth2Client.sharedOAuth2Client().isAuthenticated() && TheKeyOAuth2Client.sharedOAuth2Client().guid() != nil){
                
                postLoginNotification()
                self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("SWRevealViewController") as! UIViewController, animated: false)
                
            }else
            {
                //
                TheKeyOAuth2Client.sharedOAuth2Client().logout()
            }
            
        }

    }
    
    func loginViewController(loginViewController: TheKeyOAuth2LoginViewController!, loginError error: NSError!) {
        //println(error)
    }
 
    func postLoginNotification(){
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

