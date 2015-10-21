//
//  assignment+extension.swift
//  gcmapp
//
//  Created by Jon Vellacott on 04/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData

extension Assignment {
    class func getAssignmentForMinistryId(ministryId: String) -> Assignment?{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fr =  NSFetchRequest(entityName:"Assignment" )
        fr.predicate = NSPredicate(format: "ministry.id=%@",  ministryId)
        
        var error: NSError?
        
        let assignments = managedContext.executeFetchRequest(fr,error: &error) as! [Assignment]
        if assignments.count>0{
            return assignments.first
        }
        else{
            return nil
        }
        
    }
    
}