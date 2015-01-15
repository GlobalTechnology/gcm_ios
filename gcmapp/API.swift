//
//  api.swift
//  gcmapp
//
//  Created by Jon Vellacott on 02/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONArray = Array<AnyObject>

class API: NSObject, NSURLConnectionDataDelegate {
    enum Path {
        case GET_TOKEN
        case GET_CHURCHES
        case GET_TRAINING
        case GET_MEASUREMENTS
        case GET_MEASUREMENT_DETAIL
        case UPDATE_TRAINING_COMPLETION
    }
    typealias APICallback = ((AnyObject?, NSError?) -> ())
    let responseData:NSMutableData = NSMutableData()
    var statusCode:Int = -1
    var callback: APICallback! = nil
    var path: Path! = nil
    var cur_url=""
    var st:String = "a"
    var token: String = ""
    var login_attempts:Int = 0
    init(st: String, callback: APICallback) {
        super.init()
       self.getToken(st, callback)
    }
    
     init(token: String){
        super.init()
        self.token  = token
       
    }
    
    func getToken(st:String, callback:APICallback){
           self.st=st
            
            let url = "\(GlobalConstants.SERVICE_ROOT)token?st=\(st)"
            println("\(url)")
            makeHTTPGetRequest( Path.GET_TOKEN, callback: callback, url: url)
      

    }
    func getChurches(ministryId: String, callback: APICallback)
    {
        if self.token != ""{
            let url = "\(GlobalConstants.SERVICE_ROOT)churches?token=\(self.token)&ministry_id=\(ministryId)"
            makeHTTPGetRequest( Path.GET_CHURCHES, callback: callback, url: url)
        }
        else{
            callback(nil, nil)
        }
    }
    func getTraining(ministryId: String,mcc: String, callback: APICallback)
    {
        let url = "\(GlobalConstants.SERVICE_ROOT)training?token=\(self.token)&ministry_id=\(ministryId)&mcc=\(mcc)"
        println("\(url)")
        makeHTTPGetRequest( Path.GET_TRAINING, callback: callback, url: url)
    }
    func getMeasurement(ministryId: String, mcc: String, period: String, callback: APICallback)
    {
        let url = "\(GlobalConstants.SERVICE_ROOT)measurements?token=\(self.token)&ministry_id=\(ministryId)&mcc=\(mcc)&period=\(period)"
        println("\(url)")
        self.cur_url = url
        makeHTTPGetRequest( Path.GET_MEASUREMENTS, callback: callback, url: url)
    }
    func getMeasurementDetail(measurementId: String,ministryId: String, mcc: String, period: String, callback: APICallback)
    {
        let url = "\(GlobalConstants.SERVICE_ROOT)measurements/\(measurementId)?token=\(self.token)&ministry_id=\(ministryId)&mcc=\(mcc)&period=\(period)"
        println("\(url)")
         self.cur_url = url		
        makeHTTPGetRequest( Path.GET_MEASUREMENT_DETAIL, callback: callback, url: url)
    }
    
    func saveTrainingCompletion(tc:TrainingCompletion, callback: APICallback)
    {
        let url = "\(GlobalConstants.SERVICE_ROOT)training_completion/\(tc.id)?token=\(self.token)"
        var jsonError: NSError?
      
        
        var body = "{\"number_completed\": \(tc.number_completed)}"
        println("\(url)")
        println("\(body)")
        makeHTTPPutRequest( Path.UPDATE_TRAINING_COMPLETION, callback: callback, url: url, body:  body)
    }
    

    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        let httpResponse = response as NSHTTPURLResponse
        statusCode = httpResponse.statusCode
        switch (httpResponse.statusCode) {
        case 201, 200, 401:
            self.responseData.length = 0
        default:
        
            println("ignore")
        }
    }
    
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.responseData.appendData(data)
    }
    
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var error: NSError?
        var json : AnyObject! = NSJSONSerialization.JSONObjectWithData(self.responseData, options: NSJSONReadingOptions.MutableLeaves, error: &error)
        if (error != nil) {
            callback(nil, error)
            return
        }
        
        switch(statusCode, self.path!) {
        case (200, Path.GET_TOKEN):
            //self.handleGetToken(json)
            callback(self.handleGetToken(json), nil)
        case (200, Path.GET_CHURCHES):
            callback(self.handleGetJSONArray(json), nil)
        case (200, Path.GET_TRAINING):
            callback(self.handleGetJSONArray(json), nil)
        case (200, Path.GET_MEASUREMENTS):
            callback(self.handleGetJSONArray(json), nil)
        case (200, Path.GET_MEASUREMENT_DETAIL):
            callback(self.handleGetJSONDictionary(json), nil)
        case (201, Path.UPDATE_TRAINING_COMPLETION):
            if let resultObj = json as? JSONDictionary {
                println(resultObj)
                
            }
                         callback(true , nil)

        default:
            if statusCode == 401 {
                if login_attempts < 5{
                    login_attempts += 1
                    println("401:  reauthenticating - attempt \(login_attempts)")
                     TheKeyOAuth2Client.sharedOAuth2Client().ticketForServiceURL(NSURL(string: GlobalConstants.SERVICE_API), complete: { (ticket: String!) -> Void in
                        self.getToken(ticket, self.callback)
                    })

                }
                
            }
            if let resultObj = json as? JSONDictionary {
                println(resultObj)
                
            }
            println(self.path)
            // Unknown Error
            println("Unknown error")
            callback(nil, nil)
        }
    }
    
    
    func handleAuthError(json: AnyObject) -> NSError {
        if let resultObj = json as? JSONDictionary {
            // beta2 workaround
            if let messageObj: AnyObject = resultObj["error"] {
                if let message = messageObj as? String {
                    return NSError(domain:"signIn", code:401, userInfo:["error": message])
                }
            }
        }
        return NSError(domain:"signIn", code:401, userInfo:["error": "unknown auth error"])
    }
    
    
    func handleGetToken(json: AnyObject) -> JSONDictionary? {
        
        
        if let resultObj = json as? JSONDictionary {
            login_attempts = 0
            return resultObj

            
        }else{
                return nil
        }
    
    }
  
    func handleGetJSONArray(json: AnyObject) ->JSONArray? {
        return(json as? JSONArray)
    }
    func handleGetJSONDictionary(json: AnyObject) ->JSONDictionary? {
        return(json as? JSONDictionary)
    }
    
    
    
    // private
    func makeHTTPGetRequest(path: Path, callback: APICallback, url: NSString) {
        self.path = path
        self.callback = callback
        let request = NSURLRequest(URL: NSURL(string: url)!)
        let conn = NSURLConnection(request: request, delegate:self)
        //if (callback != nil){
        if (conn == nil ) {
            callback(nil, nil)
        }
        //}
    }
    
    func makeHTTPPostRequest(path: Path, callback: APICallback, url: NSString, body: NSString) {
        self.path = path
        self.callback = callback
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        let conn = NSURLConnection(request: request, delegate:self)
        if (conn == nil) {
            callback(nil, nil)
        }
    }
    func makeHTTPPutRequest(path: Path, callback: APICallback, url: NSString, body: NSString) {
        self.path = path
        self.callback = callback
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "PUT"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        let conn = NSURLConnection(request: request, delegate:self)
        if (conn == nil) {
            callback(nil, nil)
        }
    }
    
}