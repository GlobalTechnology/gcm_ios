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
                case GET_MINISTRIES
                case UPDATE_GENERAL
                case ADD_UPDATE_MEASUREMENT
                
                case ADD_GENERAL
                case DELETE_GENERAL
                case SAVE_MAP_USER_PREFERENCES     // set enum for map
                case GET_MAP_USER_PREFERENCES      // set enum for map
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
                self.getToken(st, callback: callback)
            }
            
            init(token: String){
                super.init()
                self.token  = token
                
            }
            
            func getToken(st:String, callback:APICallback){
                self.st=st
                
                let url = "\(GlobalConstants.SERVICE_ROOT)token?st=\(st)"
                //println(" line \(__LINE__) in function \(__FUNCTION__)+\(url)")
                makeHTTPGetRequest( Path.GET_TOKEN, callback: callback, url: url)
            }
            
            func deleteToken(){
                
                let url = "\(GlobalConstants.SERVICE_ROOT)token"
                
                
//                let request = NSMutableURLRequest(URL: NSURL(string: url as String)!)
//                request.HTTPMethod = "DELETE"
//                let conn = NSURLConnection(request: request, delegate:self, startImmediately: false)
//                if (conn == nil) {
//                    callback(nil, nil)
//                }
//                else{
//                    conn!.setDelegateQueue(NSOperationQueue())
//                    conn!.start()
//                }
                
                
                
                let request = NSMutableURLRequest(URL: NSURL(string: url)!)
                request.HTTPMethod = "DELETE"
                let conn = NSURLConnection(request: request, delegate:nil)
                if (conn == nil) {
                    callback(nil, nil)
                }
            }
            
            func getMinistries(refresh:Bool, callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)ministries?token=\(self.token)&refresh=" + (refresh ? "true" : "false")
                
                makeHTTPGetRequest(Path.GET_MINISTRIES, callback: callback, url: url)
            }
            
            func addAssignment(username: String, ministry_id:String, team_role:String, callback: APICallback){
                let url = "\(GlobalConstants.SERVICE_ROOT)assignments?token=\(self.token)"
                
                //println(url)
                var body = "{\"username\": \"\(username)\",\"ministry_id\":\"\(ministry_id)\",\"team_role\":\"\(team_role)\"}"
                //println(body)
                makeHTTPPostRequest( Path.ADD_GENERAL, callback: callback, url: url, body:  body)
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
                //println("\(url)")
                makeHTTPGetRequest( Path.GET_TRAINING, callback: callback, url: url)
            }
            
            func getMeasurement(ministryId: String, mcc: String, period: String, callback: APICallback)
            {
                
                var languageCode: String = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)! as! String
                println(languageCode)
              
                let url = "\(GlobalConstants.SERVICE_ROOT)measurements?token=\(self.token)&locale=\(languageCode)&ministry_id=\(ministryId)&mcc=\(mcc)&period=\(period)&source=\(GlobalConstants.LOCAL_SOURCE)"
                  //println("\(url)")
                self.cur_url = url
                makeHTTPGetRequest( Path.GET_MEASUREMENTS, callback: callback, url: url)
            }
            
            func getMeasurementDetail(measurementId: String, ministryId: String, mcc: String, period: String, callback: APICallback)
            {
                
                var languageCode: String = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)! as! String
                println(languageCode)
                let url = "\(GlobalConstants.SERVICE_ROOT)measurements/\(measurementId)?token=\(self.token)&locale=\(languageCode)&ministry_id=\(ministryId)&mcc=\(mcc)&period=\(period)"
                //println("\(url)")
                self.cur_url = url
                makeHTTPGetRequest( Path.GET_MEASUREMENT_DETAIL, callback: callback, url: url)
            }
            
            
            //>---------------------------------------------------------------------------------------------------
            // Author Name      :   Justin Mohit
            // Date             :   July, 31 2015
            // Input Parameters :   N/A.
            // Purpose          :   get user_preferences.
            //>---------------------------------------------------------------------------------------------------

            
            func getUserPreferences(callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)user_preferences?token=\(self.token)"
                //println("\(url)")
                //self.cur_url = url
                makeHTTPGetRequest( Path.GET_MAP_USER_PREFERENCES, callback: callback, url: url)
            }

            
            
            //>---------------------------------------------------------------------------------------------------
            // Author Name      :   Justin Mohit
            // Date             :   July, 31 2015
            // Input Parameters :   mapInfo,callback.
            // Purpose          :   Post user_preferences.
            //>---------------------------------------------------------------------------------------------------
           
            
            func saveUser_preferences(mapInfo: NSDictionary, callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)user_preferences?token=\(self.token)"
                var jsonError: NSError?
                
                var ministryId: AnyObject?  = mapInfo["min_id"]
                var lat: AnyObject?  = mapInfo["lat"]
                var long: AnyObject?  = mapInfo["long"]
                var zoom: AnyObject? = mapInfo["zoom"]

                var body = "{\"default_map_views\": ["
                
                body += "{\"ministry_id\": \"\(ministryId!)\",\"location\":{\"latitude\":\(lat!),\"longitude\":\(long!)} , \"location_zoom\":\(zoom!)}"
                
                body += "]}"

                print(body)
                
                makeHTTPPostRequest( Path.SAVE_MAP_USER_PREFERENCES, callback: callback, url: url, body:  body)
            }
            
            //>---------------------------------------------------------------------------------------------------
            // Author Name      :   Caleb Kapil
            // Date             :   Sept, 24 2015
            // Input Parameters :   mapInfo,callback.
            // Purpose          :   Post user_preferences for staff Support.
            //>---------------------------------------------------------------------------------------------------
            
            
            func save_StaffSupprot_User_preferences(mapInfo: NSDictionary, callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)user_preferences?token=\(self.token)"
                var jsonError: NSError?
                
                
                var supportStaff_Status: AnyObject?  = mapInfo["supported_staff"]

                var body = "{\"supported_staff\": \"\(supportStaff_Status!)\"}"//["
                
                println(body)
                
                makeHTTPPostRequest( Path.SAVE_MAP_USER_PREFERENCES, callback: callback, url: url, body:  body)
            }
        
            
            
            //>---------------------------------------------------------------------------------------------------
            // Author Name      :   Justin Mohit
            // Date             :   July, 31 2015
            // Input Parameters :    training_id,callback.
            // Purpose          :    Delete Traning.
            //>---------------------------------------------------------------------------------------------------
            
            
            func deleteTraning(training_id: Int, callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)training/\(training_id)?token=\(self.token)"
                //println("\(url)")
                //self.cur_url = url
                makeHTTPDeleteRequest(Path.DELETE_GENERAL, callback: callback, url: url)
            }
            //>---------------------------------------------------------------------------------------------------
            // Author Name      :   Justin Mohit
            // Date             :   July, 31 2015
            // Input Parameters :    training_id,callback.
            // Purpose          :    Delete Church.
            //>---------------------------------------------------------------------------------------------------
            
            
            func deleteChurch(church: JSONDictionary , callback: APICallback)
            {
                
                var church_id  = church["id"] as? Int
                var ministry_id = church["ministry_id"] as? String
                var name = church["name"] as? String
 
                let url = "\(GlobalConstants.SERVICE_ROOT)churches/\(church_id!)?token=\(self.token)"
                //println("\(url)")
                let calendar = NSCalendar.currentCalendar()
                // Set up date object
                let date = NSDate()
                // Create an NSDate for the first and last day of the month
                let components = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
                components.month  += 0
                components.day     = 0
                let lastDateOfMonth: NSDate = calendar.dateFromComponents(components)!
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
               
                // var body = "{\"end_date\": \( dateFormatter.stringFromDate(lastDateOfMonth))}"
                
                var body = "{\"ministry_id\": \"\(ministry_id!)\",\"name\":\"\(name!)\",\"end_date\":\"\(dateFormatter.stringFromDate(lastDateOfMonth))\"}"
                
                 //println(body)
                //self.cur_url = url
                makeHTTPPutRequest(Path.UPDATE_GENERAL, callback: callback, url: url,body : body)
            }
           
            func saveTrainingCompletion(tc:TrainingCompletion, callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)training_completion/\(tc.id)?token=\(self.token)"
                var jsonError: NSError?
                var body = "{\"number_completed\": \(tc.number_completed)}"
                
                makeHTTPPutRequest( Path.UPDATE_GENERAL, callback: callback, url: url, body:  body)
            }
            
            func addTrainingCompletion(tc:createTrainingStage, callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)training_completion?token=\(self.token)"
                var jsonError: NSError?
                
                
                var body = tc.toJSON()
                //println(body)
                makeHTTPPostRequest( Path.ADD_GENERAL, callback: callback, url: url, body:  body)
            }
            func saveMeasurement(meas:Array<Measurement>, callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)measurements?token=\(self.token)"
                var jsonError: NSError?
                var body = "["
                for m in  meas {
                    body += m.toJSON() + ","
                }
                body = body.substringToIndex(body.endIndex.predecessor()) //remove last ,
                body += "]"
                //println(url)
                //println(body)
                makeHTTPPostRequest( Path.ADD_UPDATE_MEASUREMENT, callback: callback, url: url, body:  body)
            }
            
            func saveChurch(church:Church, callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)churches/\(church.id)?token=\(self.token)"
                var jsonError: NSError?
                var body = church.toJson()
                //println(body)
                makeHTTPPutRequest( Path.UPDATE_GENERAL, callback: callback, url: url, body:  body)
            }
            func addChurch(church:Church, callback: APICallback)
            {
                let url = "\(GlobalConstants.SERVICE_ROOT)churches?token=\(self.token)"
                var jsonError: NSError?
                var body = church.toJson()
                //println(body)
                makeHTTPPostRequest( Path.ADD_GENERAL, callback: callback, url: url, body:  body)
            }
            
            func saveTraining(training: Training, callback: APICallback){
                let url = "\(GlobalConstants.SERVICE_ROOT)training/\(training.id)?token=\(self.token)"
                var jsonError: NSError?
                //println(url)
                var body = training.toJson()
                //println(body)
                makeHTTPPutRequest( Path.UPDATE_GENERAL, callback: callback, url: url, body:  body)
            }
            
            func addTraining(training: Training, callback: APICallback){
                let url = "\(GlobalConstants.SERVICE_ROOT)training?token=\(self.token)"
                var jsonError: NSError?
                //println(url)
                
                var body = training.toJson()
                 //println(body)
                makeHTTPPostRequest( Path.ADD_GENERAL, callback: callback, url: url, body:  body)
            }
            func updateMinistry(ministry: Ministry, callback: APICallback){
                let url = "\(GlobalConstants.SERVICE_ROOT)ministries/\(ministry.id)?token=\(self.token)"
                var jsonError: NSError?
                //println(url)
                var body = ministry.toJson()
                //println(body)
                makeHTTPPutRequest( Path.UPDATE_GENERAL, callback: callback, url: url, body:  body)
            }
            
            func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
                let httpResponse = response as! NSHTTPURLResponse
                statusCode = httpResponse.statusCode
                //println(statusCode)
                
                switch (httpResponse.statusCode) {
                case 201, 200, 401:
                    self.responseData.length = 0
                default:
                    
                    println("ignore")
                }
            }
            
            func connection(connection: NSURLConnection, didFailWithError error: NSError) {
                //println(error)
            }
            
            func connection(connection: NSURLConnection, didReceiveData data: NSData) {
                self.responseData.appendData(data)
            }
            
            
            func connectionDidFinishLoading(connection: NSURLConnection) {
                var error: NSError?
                var json : AnyObject!
                if responseData.length>0{
                    
                    json = NSJSONSerialization.JSONObjectWithData(self.responseData, options: NSJSONReadingOptions.MutableLeaves, error: &error)
                    //println(json)
                    
                    if (error != nil) {
                        var error_msg = NSString(data: responseData, encoding: NSUTF8StringEncoding)
                        //println(error_msg)
                        callback(nil, error)
                        return
                    }
                }
                
                switch(statusCode, self.path!) {
                    
                case (200, Path.GET_TOKEN):
                    //self.handleGetToken(json)
                    callback(self.handleGetToken(json), nil)
                case (200, Path.GET_CHURCHES):
                    callback(self.handleGetJSONArray(json), nil)
                case (200, Path.GET_TRAINING):
                    //println(NSString(data: self.responseData, encoding: NSUTF8StringEncoding))
               
                    
                    callback(self.handleGetJSONArray(json), nil)
                case (200, Path.GET_MEASUREMENTS):
                    callback(self.handleGetJSONArray(json), nil)
                case (200, Path.GET_MEASUREMENT_DETAIL):
                    callback(self.handleGetJSONDictionary(json), nil)
                case (200, Path.GET_MINISTRIES):
                    callback(self.handleGetJSONArray(json), nil)
                case (201, Path.UPDATE_GENERAL):
                    //println(json)
                    callback(true , nil)
                case (200, Path.UPDATE_GENERAL):
                    callback(true , nil)
                case (201, Path.ADD_GENERAL):
                    
                    callback(self.handleGetJSONDictionary(json) , nil)
                case (201, Path.ADD_UPDATE_MEASUREMENT):
                    
                    callback(true , nil)
                case (200, Path.SAVE_MAP_USER_PREFERENCES):
                    
                    callback(true , nil)
                    
                case (200, Path.GET_MAP_USER_PREFERENCES):
                    
                    callback(self.handleGetJSONDictionary(json) , nil)
                    
                case (204, Path.DELETE_GENERAL):
                    callback(true , nil)

                    
                default:
                    if statusCode == 401 {
                        if (json as! JSONDictionary)["reason"] as! String == GlobalConstants.apiSessionInvalid{
                            if login_attempts < 5{
                                login_attempts += 1
                                //println("401:  reauthenticating - attempt \(login_attempts)")
                                
                                if  let isRefreshing =  NSUserDefaults.standardUserDefaults().objectForKey(GlobalConstants.kIsRefreshingToken) as! Bool? {
                                    
                                    // prevent from optional crash
                                }
                                
                                else {
                                    
                                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kIsRefreshingToken)
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    let notificationCenter = NSNotificationCenter.defaultCenter()
                                    notificationCenter.postNotificationName(GlobalConstants.kLogin, object: nil)
                                }
                            }
                        }
                    }
                    
                    // Unknown Error
                    //println("401")
                    //println("... responseData:\(NSString(data: responseData, encoding: NSUTF8StringEncoding))")
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
                
                //println(json)
                return(json as? JSONDictionary)
            }
            
            // private
            func makeHTTPGetRequest(path: Path, callback: APICallback, url: NSString) {
               
                self.path = path
                self.callback = callback
                
                let request = NSURLRequest(URL: NSURL(string: url as String)!)
                let conn = NSURLConnection(request: request, delegate:self, startImmediately: false)
            
                
                
                //if (callback != nil){
                if (conn == nil ) {
                    callback(nil, nil)
                }
                else{
                     conn!.setDelegateQueue(NSOperationQueue())
                        conn!.start()
                }
                //}
            }
            
            func makeHTTPPostRequest(path: Path, callback: APICallback, url: NSString, body: NSString) {
                self.path = path
                self.callback = callback
                let request = NSMutableURLRequest(URL: NSURL(string: url as String)!)
                request.HTTPMethod = "POST"
                request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
                let conn = NSURLConnection(request: request, delegate:self, startImmediately: false)
                if (conn == nil) {
                    callback(nil, nil)
                }
                else{
                    conn!.setDelegateQueue(NSOperationQueue())
                    conn!.start()
                }
            }
            
            func makeHTTPPutRequest(path: Path, callback: APICallback, url: NSString, body: NSString) {
                self.path = path
                self.callback = callback
                let request = NSMutableURLRequest(URL: NSURL(string: url as String)!)
                request.HTTPMethod = "PUT"
                request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
                let conn = NSURLConnection(request: request, delegate:self, startImmediately: false)
                if (conn == nil) {
                    callback(nil, nil)
                }
                else{
                     conn!.setDelegateQueue(NSOperationQueue())
                    conn!.start()
                }
            }
            
            func makeHTTPDeleteRequest(path: Path, callback: APICallback, url: NSString) {  // Justin Mohit delete request block.
                
                self.path = path
                self.callback = callback
                let request = NSMutableURLRequest(URL: NSURL(string: url as String)!)
                request.HTTPMethod = "DELETE"
                let conn = NSURLConnection(request: request, delegate:self, startImmediately: false)
                if (conn == nil) {
                    callback(nil, nil)
                }
                else{
                    conn!.setDelegateQueue(NSOperationQueue())
                    conn!.start()
                }
            }
            
        }
