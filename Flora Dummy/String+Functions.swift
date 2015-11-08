//
//  String+Functions.swift
//
//
//  Created by Michael Schloss on 6/1/15.
//  Copyright (c) 2015 Michael Schloss. All rights reserved.
//

//Trims a string only along a certain side.  Useful for IDs and calculator displays

import UIKit

///The side to trim along
@objc enum StringSide : Int
{
    ///The Left (front) side of the string
    case Left
    
    ///The Right (back) side of the string
    case Right
}

extension String
{
    /**
    Trims the string along a certain side
    
    :param: side The side of the string to trim along
    
    :returns: A string trimmed along the side specified

    */
    func stringByStrippingPaddingOffSide(side: StringSide) -> String
    {
        guard characters.count > 1 else { return self }
        
        var newString = self
        switch side
        {
        case .Left:     //Takes all 0's off of left side
            while newString.startIndex.advancedBy(1) < newString.endIndex && newString.substringToIndex(startIndex.advancedBy(1)) == "0"
            {
                newString = newString.substringFromIndex(startIndex.advancedBy(1))
            }
            
        case .Right:    //Takes all 0's off right side.
            //This case has an interesting side effect.  If self is initially "" or nil, adding initial 0's will produce a "" string.
            //This is comparable to -stringByTrimmingCharactersInSet, in which this case will auto-trim the left side if inital value is 0[0...]"
            //This effect is only seen when adding to the string from "" or nil, this is not the case when the full string is already set
            while newString.characters.count > 0 && newString.substringFromIndex(endIndex.advancedBy(-1)) == "0"
            {
                newString = newString.substringToIndex(endIndex.advancedBy(-1))
            }
        }
        
        return newString
    }
}

extension NSString
{
    func stringByStrippingPaddingOffSide(side: StringSide) -> NSString
    {
        if length <= 1
        {
            return self
        }
        
        var newString = self
        switch side
        {
        case .Left:     //Takes all 0's off of left side
            while newString.length > 0 && newString.substringToIndex(1) == "0"
            {
                newString = newString.substringFromIndex(1)
            }
            break
            
        case .Right:    //Takes all 0's off right side.
            //This case has an interesting side effect.  If self is initially "" or nil, adding initial 0's will produce a "" string.
            //This is comparable to -stringByTrimmingCharactersInSet, in which this case will auto-trim the left side if inital value is 0[0...]"
            //This effect is only seen when adding to the string from "" or nil, this is not the case when the full string is already set
            while newString.length > 0 && newString.substringFromIndex(newString.length - 1) == "0"
            {
                newString = newString.substringToIndex(newString.length - 1)
            }
            break
        }
        
        return newString
    }
}
