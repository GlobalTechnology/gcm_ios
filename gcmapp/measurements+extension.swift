//
//  measurements+extension.swift
//  gcmapp
//
//  Created by Jon Vellacott on 03/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
extension Measurements {
     func sortOrder() -> NSNumber{
        switch(self.section.lowercaseString){
        case "win":
            return 0
        case "build":
            return 1
        case "send":
            return 2
        default:
            return 3
        }
        
    }

    
}