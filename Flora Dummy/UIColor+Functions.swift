//
//  UIColor+Functions.swift
//
//
//  Created by Michael Schloss on 5/19/15.
//  Copyright (c) 2015 Michael Schloss. All rights reserved.
//

//Extends the UIColor class for various uses

import UIKit

extension UIColor
{
    convenience init(hexString: String)
    {
        let colorString = ((hexString as NSString).stringByReplacingOccurrencesOfString("#", withString: "")) as String
        
        let alpha = 1.0
        let red = UIColor.colorCompenentFrom(colorString, atStartIndex: 0, withLength: 2)
        let green = UIColor.colorCompenentFrom(colorString, atStartIndex: 2, withLength: 2)
        let blue = UIColor.colorCompenentFrom(colorString, atStartIndex: 4, withLength: 2)
        
        self.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    class func randomColor() -> UIColor
    {
        let red = CGFloat(arc4random_uniform(11))/10.0
        let green = CGFloat(arc4random_uniform(11))/10.0
        let blue = CGFloat(arc4random_uniform(11))/10.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var shouldUseWhiteText : Bool
        {
        get
        {
            let componentColors = CGColorGetComponents(self.CGColor)
            
            var darknessScore = (componentColors[0] * 255) * 299
            darknessScore += (componentColors[1] * 255) * 587
            darknessScore += (componentColors[2] * 255) * 114
            darknessScore /= 1000
            
            if (darknessScore <= 125)
            {
                return true
            }
            
            return false
        }
    }
    
    /*var lighter : UIColor
        {
        get
        {
            var alpha : CGFloat = 0.0
            var red : CGFloat = 0.0
            var green : CGFloat = 0.0
            var blue : CGFloat = 0.0
            
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return UIColor(red: red + 0.1, green: green + 0.1, blue: blue + 0.1, alpha: alpha)
        }
    }*/
    
    var darker : UIColor
        {
        get
        {
            var alpha : CGFloat = 0.0
            var red : CGFloat = 0.0
            var green : CGFloat = 0.0
            var blue : CGFloat = 0.0
            
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            if red == 0.0 && blue == 0.0 && green == 0.0
            {
                return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha + 0.1)
            }
            
            return UIColor(red: red - 0.1, green: green - 0.1, blue: blue - 0.1, alpha: alpha + 0.1)
        }
    }
    
    var textRepresentation : String
        {
        get
        {
            var red : CGFloat = 0.0
            var green : CGFloat = 0.0
            var blue : CGFloat = 0.0
            var alpha : CGFloat = 0.0
            
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return "(\(red * 255.0), \(green * 255.0), \(blue * 255.0))"
        }
    }
    
    private class func colorCompenentFrom(string : String, atStartIndex start : Int, withLength length : Int) ->Float
    {
        let subString = ((string as NSString).substringWithRange(NSMakeRange(start, length))) as String
        let fullHex = length == 2 ? subString : (subString + subString)
        
        var hexCompenent : UInt32 = 0
        let scanner = NSScanner(string: fullHex)
        scanner.scanHexInt(&hexCompenent)
        
        return Float(hexCompenent) / 255.0
    }
}