//
//  NotificationManager.swift
//  gcmapp
//
//  Created by MOHIT on 19/08/15.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation

class NotificationManager {
    private var observerTokens: [AnyObject] = []
    let mainQueue = NSOperationQueue.mainQueue()
    deinit {
        deregisterAll()
    }
    
    func deregisterAll() {
        for token in observerTokens {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
        
        observerTokens = []
    }
    
    func registerObserver(name: String!, block: (NSNotification! -> Void)) {
        

        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: nil) {note in
            block(note)
        }
        
        observerTokens.append(newToken)
    }
    
    func registerObserver(name: String!, forObject object: AnyObject!, block: (NSNotification! -> Void)) {
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(name, object: object, queue: mainQueue) {note in
            block(note)
        }
        
        observerTokens.append(newToken)
    }
}
/* how to use 
private let notificationManager = NotificationManager()

override init() {
notificationManager.registerObserver(MyNotificationItemAdded) { note in
//println("item added!")
}
*/
