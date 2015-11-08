//
//  Definitions.swift
//  Flora Dummy
//
//  Created by Michael Schloss on 10/25/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

//  This Swift file will contain all functions that are found everywhere.  This reduces code load and centralizes any changes needed to be made.

import UIKit

//------------------
//  Global Variables
//------------------

let titleFont = UIFont.systemFontOfSize(48.0, weight: UIFontWeightHeavy)
let bodyFont  = UIFont.systemFontOfSize(24.0, weight: UIFontWeightRegular)

let CESCometTransitionDuration = 0.3

let ActivityDataLoaded = "CESDatabase Activity Data Downloaded"

@objc enum ActivityViewControllerType : Int
{
    case Intro, Module, Sandbox, Read, SquaresDragAndDrop, MathProblem, DrawingVC, Garden, ClockDrag, PictureQuiz, QuickQuiz, Vocab, Spelling
}

@objc enum DrawingVCOrientation : Int
{
    case Landscape, Portrait
}

//--------------------
//  String Extension
//--------------------

extension String {
    
    subscript (i: Int) -> Character
        {
            return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String
        {
            return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String
        {
            return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}

//-------------------
//  Definitions Class
//-------------------

@available(*, deprecated=9.0, message="Definitions is now deprecated, refer to specific function deprecation messages for what to do")
class Definitions: NSObject
{
    //Calculate the answer to a math problem
    class func calculate(equation: String) -> Double
    {
        var finalAnswer = 0.0
        
        //Trims the string to remove white space and other accidental charcters
        var trimmedEquation = equation.stringByReplacingOccurrencesOfString(" ", withString: "", options: .CaseInsensitiveSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " ,;."))
        
        //Parentheses -- (P)emdas
        var positionOfFirstOpenParentheses = -1
        var positionOfMatchingCloseParentheses = -1
        var parenCounter = 0
        
        for index in 0...trimmedEquation.characters.count - 1
        {
            if index > trimmedEquation.characters.count - 1
            {
                break
            }
            
            let character : Character = trimmedEquation[index]
            
            if character == "(" && positionOfFirstOpenParentheses == -1
            {
                positionOfFirstOpenParentheses = index
                parenCounter++
            }
            else if character == "("
            {
                parenCounter++
            }
            else if character == ")"
            {
                parenCounter--
                if parenCounter == 0
                {
                    positionOfMatchingCloseParentheses = index
                    let newEquation = trimmedEquation[(positionOfFirstOpenParentheses + 1)...(positionOfMatchingCloseParentheses - 1)]
                    let substitution = String(format: "%f", calculate(newEquation)).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0")).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "."))
                    trimmedEquation.replaceRange(Range<String.Index>(start: trimmedEquation.startIndex.advancedBy(positionOfFirstOpenParentheses), end: trimmedEquation.startIndex.advancedBy(positionOfMatchingCloseParentheses + 1)), with: substitution)
                }
            }
        }
        
        //Get just the numbers
        var numbers = trimmedEquation.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "+-^*/"))
        //Get just the operators
        var operators = trimmedEquation.componentsSeparatedByCharactersInSet(NSCharacterSet.alphanumericCharacterSet())
        //Sort out accidental blank space that comes with separating by numbers
        let tempArray = NSMutableArray(array: operators)
        if tempArray.containsObject("")
        {
            tempArray.removeObject("")
        }
        operators = tempArray.subarrayWithRange(NSRange(location:0, length: tempArray.count)) as! [String]
        
        //Exponents -- p(E)mdas
        for oper in operators
        {
            let index = (operators as NSArray).indexOfObject(oper)
            
            if oper == "^"
            {
                let leftSide = (numbers[index] as NSString).doubleValue
                let rightSide = (numbers[index + 1] as NSString).doubleValue
                
                let answer = pow(leftSide, rightSide)
                numbers[index] = String(format: "%f", answer).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0")).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "."))
                numbers.removeAtIndex(index + 1)
                operators.removeAtIndex(index)
            }
        }
        
        //Multiplication and Division -- pe(MD)as
        for oper in operators
        {
            let index = (operators as NSArray).indexOfObject(oper)
            
            if oper == "*"
            {
                let leftSide = (numbers[index] as NSString).doubleValue
                let rightSide = (numbers[index + 1] as NSString).doubleValue
                
                let answer = leftSide * rightSide
                numbers[index] = String(format: "%f", answer).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0")).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "."))
                numbers.removeAtIndex(index + 1)
                operators.removeAtIndex(index)
            }
            else if oper == "/"
            {
                let leftSide = (numbers[index] as NSString).doubleValue
                let rightSide = (numbers[index + 1] as NSString).doubleValue
                
                let answer = leftSide / rightSide
                numbers[index] = String(format: "%f", answer).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0")).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "."))
                numbers.removeAtIndex(index + 1)
                operators.removeAtIndex(index)
            }
        }
        
        //Addition and Subtraction -- pemd(AS)
        for oper in operators
        {
            let index = (operators as NSArray).indexOfObject(oper)
            
            if oper == "+"
            {
                let leftSide = (numbers[index] as NSString).doubleValue
                let rightSide = (numbers[index + 1] as NSString).doubleValue
                
                let answer = leftSide + rightSide
                numbers[index] = String(format: "%f", answer).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0")).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "."))
                numbers.removeAtIndex(index + 1)
                operators.removeAtIndex(index)
            }
            else if oper == "-"
            {
                let leftSide = (numbers[index] as NSString).doubleValue
                let rightSide = (numbers[index + 1] as NSString).doubleValue
                
                let answer = leftSide - rightSide
                numbers[index] = String(format: "%f", answer).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0")).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "."))
                numbers.removeAtIndex(index + 1)
                operators.removeAtIndex(index)
            }
        }
        
        finalAnswer = (numbers[0] as NSString).doubleValue
        
        return finalAnswer
    }
}

///Returns a string for the current grade given the key.  This application handles six different grades
extension String
{
    static func stringForKey(key: String) -> String
    {
        guard CurrentUser.currentUser().grade != Grade.None else { return key }
        
        let newKey = key + "-\(CurrentUser.currentUser().grade.rawValue)"
        
        return NSBundle.mainBundle().localizedStringForKey(newKey, value: "", table: "PhrasesPerGrade")
    }
}

extension NSString
{
    static func stringForKey(key: String) -> String
    {
        guard CurrentUser.currentUser().grade != Grade.None else { return key }
        
        let newKey = key + "-\(CurrentUser.currentUser().grade.rawValue)"
        
        return NSBundle.mainBundle().localizedStringForKey(newKey, value: "", table: "PhrasesPerGrade")
    }
}
