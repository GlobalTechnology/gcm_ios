//
//  HasMcc.swift
//  gcmapp
//
//  Created by Justin Mohit on 19/08/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class HasMcc {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    func  hasMcc() -> Bool {
        
        var error: NSError?
        
        var flag: Bool = false
        
        if let ministryID = NSUserDefaults.standardUserDefaults().objectForKey("ministry_id") as? String {
            
            let fetchRequest =  NSFetchRequest(entityName:"Ministry" )
            fetchRequest.predicate=NSPredicate(format: "id = %@", ministryID )
            let fetchedResults =  appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as! [Ministry]
            if fetchedResults.count > 0{
                if let ministry:Ministry = fetchedResults.first {
                    
                   
                    if (ministry.has_slm as Bool) {
                        
                        flag = true
                    }
                    if(ministry.has_llm as Bool) {
                        
                        flag = true
                    }
                    if(ministry.has_gcm as Bool) {
                        
                        flag = true
                    }
                    if(ministry.has_ds as Bool) {
                        
                        flag = true
                    }
                    
                    
                }
                
            } // end if fetchedResults
            
        }

      return flag
    }
    
    

}
