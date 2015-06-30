//
//  GraphView.swift
//  gcmapp
//
//  Created by Jon Vellacott on 10/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import UIKit

class GraphView: UIView {

     var values:[MeasurementValue]!
    
    
    override func drawRect(rect: CGRect) {
        let context:CGContextRef = UIGraphicsGetCurrentContext()
        
    
        let strokeRect = CGRectMake(self.bounds.origin.x + 30, self.bounds.origin.y+5, self.bounds.width-50, self.bounds.height-36)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 1.0)
        CGContextStrokeRect(context, strokeRect)
        
        var maxnum:Int = 5
        
        for row in values{
            if row.total.integerValue > maxnum{
                maxnum = row.total.integerValue
            }
        }
        maxnum = setScale(maxnum)
        
        
        let dx = strokeRect.width /  5
        let dy = strokeRect.height / CGFloat(maxnum)
        var p = GlobalFunctions.currentPeriod()
        
        
        
    
        
        
        let font = UIFont.systemFontOfSize(9)
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: textStyle
        ]
        for i in 0...5{
            let periodRect = CGRectMake(strokeRect.origin.x + strokeRect.width - (dx/3.0) -  (dx * CGFloat(i)),strokeRect.origin.y + strokeRect.height, dx/1.5, 12)
            (p as NSString).drawInRect(periodRect, withAttributes: textFontAttributes)
            CGContextMoveToPoint(context, strokeRect.origin.x + strokeRect.width -  (dx * CGFloat(i)), strokeRect.origin.y + strokeRect.height )
            
            CGContextAddLineToPoint(context, strokeRect.origin.x + strokeRect.width -  (dx * CGFloat(i)), strokeRect.origin.y + strokeRect.height - 5.0)
            p = GlobalFunctions.prevPeriod(p)
        }
        
        CGContextStrokePath(context)
        
        CGContextBeginPath(context)
       
        
        
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
        
        var y_scale = getScaleInterval(maxnum)
        var y:Int = y_scale
        textStyle.alignment = NSTextAlignment.Right
        while y<=maxnum{
            let lblRect = CGRectMake(strokeRect.origin.x - 30 , strokeRect.origin.y - 6 + strokeRect.height - (CGFloat(y) * dy), 20, 12)
            
            
            NSString(format: "%d", y).drawInRect(lblRect, withAttributes: textFontAttributes)

            
            CGContextMoveToPoint(context, strokeRect.origin.x , strokeRect.origin.y  + strokeRect.height - (CGFloat(y) * dy))
            
            CGContextAddLineToPoint(context, strokeRect.origin.x + strokeRect.width, strokeRect.origin.y  + strokeRect.height - (CGFloat(y) * dy))
            y += y_scale
        }
        
        //draw Legend
        
       CGContextStrokePath(context)
        
        CGContextBeginPath(context)
        CGContextSetLineWidth(context, 3.0)
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextMoveToPoint(context, strokeRect.origin.x , strokeRect.origin.y  + strokeRect.height + 25)
        CGContextAddLineToPoint(context, strokeRect.origin.x - 15 + strokeRect.width/6, strokeRect.origin.y  + strokeRect.height + 25)
        CGContextStrokePath(context)
     
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextMoveToPoint(context, strokeRect.origin.x + strokeRect.width/3, strokeRect.origin.y  + strokeRect.height + 25)
        CGContextAddLineToPoint(context, strokeRect.origin.x-15 + strokeRect.width/2, strokeRect.origin.y  + strokeRect.height + 25)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor)
        CGContextMoveToPoint(context, strokeRect.origin.x + (2 * strokeRect.width/3), strokeRect.origin.y  + strokeRect.height + 25)
        CGContextAddLineToPoint(context, strokeRect.origin.x-15 + (5 * strokeRect.width/6), strokeRect.origin.y  + strokeRect.height + 25)
        CGContextStrokePath(context)
        
        textStyle.alignment = NSTextAlignment.Left
        var legRect = CGRectMake(strokeRect.origin.x - 10 + strokeRect.width/6, strokeRect.origin.y - 6 + strokeRect.height + 25, 20 + strokeRect.width/6, 12)
        
        NSString(string: "Total").drawInRect(legRect, withAttributes: textFontAttributes)
        legRect = CGRectMake(strokeRect.origin.x - 10 + strokeRect.width/2, strokeRect.origin.y - 6 + strokeRect.height + 25, 20 + strokeRect.width/6, 12)
        
        NSString(string: "Local").drawInRect(legRect, withAttributes: textFontAttributes)
        legRect = CGRectMake( strokeRect.origin.x-10 + (5 * strokeRect.width/6), strokeRect.origin.y - 6 + strokeRect.height + 25, 20 + strokeRect.width/6, 12)
        
        NSString(string: "Me").drawInRect(legRect, withAttributes: textFontAttributes)

        
        
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        p = GlobalFunctions.currentPeriod()
        
        
       CGContextSetLineWidth(context, 4.0)
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
      
        for i in 0...5{
            
            var val:NSNumber = 0
            let searchVal = values.filter {$0.period == p}
            
            if searchVal.count > 0{
                
                    val = searchVal.first!.total
                
            }
                      if i==0 {
                CGContextMoveToPoint(context, strokeRect.origin.x + strokeRect.width, strokeRect.origin.y + strokeRect.height - (dy * CGFloat(val)))
            }
            else{
             
                CGContextAddLineToPoint(context, strokeRect.origin.x + strokeRect.width -  (dx * CGFloat(i)), strokeRect.origin.y + strokeRect.height - (dy * CGFloat(val)))
            }
          p = GlobalFunctions.prevPeriod(p)
        }
        
         p = GlobalFunctions.currentPeriod()
        
        CGContextStrokePath(context)
        CGContextBeginPath(context)
         CGContextSetLineWidth(context, 2.0)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        
        for i in 0...5{
            
            var val:NSNumber = 0
            let searchVal = values.filter {$0.period == p}
            
            if searchVal.count > 0{
                
                val = searchVal.first!.local
                
            }
            if i==0 {
                CGContextMoveToPoint(context, strokeRect.origin.x + strokeRect.width, strokeRect.origin.y + strokeRect.height - (dy * CGFloat(val)))
            }
            else{
                
                CGContextAddLineToPoint(context, strokeRect.origin.x + strokeRect.width -  (dx * CGFloat(i)), strokeRect.origin.y + strokeRect.height - (dy * CGFloat(val)))
            }
            p = GlobalFunctions.prevPeriod(p)
        }
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor)
         p = GlobalFunctions.currentPeriod()
        for i in 0...5{
            
            var val:NSNumber = 0
            let searchVal = values.filter {$0.period == p}
            
            if searchVal.count > 0{
                
                val = searchVal.first!.me
                
            }
            if i==0 {
                CGContextMoveToPoint(context, strokeRect.origin.x + strokeRect.width, strokeRect.origin.y + strokeRect.height - (dy * CGFloat(val)))
            }
            else{
                
                CGContextAddLineToPoint(context, strokeRect.origin.x + strokeRect.width -  (dx * CGFloat(i)), strokeRect.origin.y + strokeRect.height - (dy * CGFloat(val)))
            }
            p = GlobalFunctions.prevPeriod(p)
        }
        CGContextStrokePath(context)


    }
    
    
    func setScale(maxnum: Int) -> Int{
        var rtn = maxnum
        if maxnum < 50{
            rtn +=  (5 - (maxnum % 5))
        }
        else if maxnum<100{
            rtn += (10 - (maxnum % 10))
        }
        else if maxnum<300{
            rtn += (100 - (maxnum % 100))
        }
        else if maxnum<500{
            rtn += (500 - (maxnum % 500))
        }
        else {
            rtn += (1000 - (maxnum % 1000))
        }
        println("scale: \(rtn)")
        return rtn
    }
    
    func getScaleInterval(maxnum:Int) -> Int{
        var rtn = 5
        if maxnum <= 25{
            rtn = 5
        }
        else if maxnum<=50{
            rtn = 10
        }
        else if maxnum<100{
            rtn = 25
        }
        else if maxnum<500{
            rtn = 100
        }
        else if maxnum<1000{
            rtn = 250
        }
        else if maxnum<5000{
            rtn = 1000
        }
        else if maxnum<10000{
            rtn = 2500
        }
        else {
            rtn = 5000
        }
        return rtn
    }
    
}