//
//  Utility.swift
//  PG
//
//  Created by Caleb Kapil on 26/12/14.
//  Copyright (c) 2014 Caleb Kapil. All rights reserved.
//

import Foundation

public class Utiltiy {

class func cleanJsonToObject(data: AnyObject)->AnyObject
{
var err: NSError?


if(data as! NSObject == NSNull())
{
var temp = NSDictionary()

return temp
}


var jsonObject:AnyObject

if(data.isKindOfClass(NSData))
{
jsonObject = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .MutableLeaves, error: &err) as! NSDictionary

}
else
{
jsonObject = data
}

if(jsonObject.isKindOfClass(NSArray))
{
var array:NSMutableArray = jsonObject.mutableCopy() as! NSMutableArray

for(var i = array.count-1;i >= 0;i--)
{
    var a:AnyObject = array[i]
    if(a as! NSObject == NSNull())
    {
        array.removeObjectAtIndex(i)
    }
    else
    {
        array[i] = self.cleanJsonToObject(a)
    }
}
return array
}
else if(jsonObject.isKindOfClass(NSDictionary))
{
var dictionary:NSMutableDictionary = jsonObject.mutableCopy() as! NSMutableDictionary


for key in dictionary.allKeys
{
   var d:AnyObject = dictionary["\(key)"]!
    
    
    if(d as! NSObject == NSNull())
    {
        dictionary["\(key)"] = ""
    }
    else
    {
     dictionary["\(key)"] = self.cleanJsonToObject(d)
    }
}
return dictionary
}
else
{
return jsonObject
}
}
}