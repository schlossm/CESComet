//
//  ClockDragVC.swift
//  FloraDummy
//
//  Created by Michael Schloss on 11/22/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

import UIKit
import QuartzCore

enum MinuteHandRounding : Int
{
    case None = 0
    case NearestFiveMinutes = 1
    case NearestQuarterHour = 2
    case NearestHalfHour = 3
}

class ClockDragVC: FormattedVC, ClockDelegate
{
    /**
    The time to initially show on the clock.
    
    By default, this is 00:00:00
    
    - parameter HH:MM:SS: The time format
    */
    private var startTime = "00:00:00"
    
    /**
    The time to be set on the clock by the user.
    
    This cannot be NULL.  If a value is not provided, self will dismiss.
    
    - parameter HH:MM:SS: The time format
    */
    private var endTime : String!
    
    /**
    The buffer zone for how incorrect each hand can be.
    
    By default, this is 00:02:02
    
    - parameter HH:MM:SS: The time format
    */
    private var bufferZone = "00:02:02"
    
    /**
    Determines whether the hands will move independently of each other
    
    By default, this is set to 'true'.  Setting to 'false' disables the time-link between each hand.
    */
    private var handsMoveDependently = true
    
    /**
    Determines whether the Seconds Hand will be displayed on screen
    
    By default, this is set to 'true'.  Setting to 'false' will disable the Seconds Hand.
    */
    private var showSecondsHand = true
    
    private var minuteHandRounding = MinuteHandRounding.None
    
    private var didCheckAnswer = false
    private var tempTime : String?
    
    //The clock itself
    private var clock : Clock!
    
    //The current time label
    private var currentTimeLabel : UILabel!
    private var instructions : UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createAndDisplayClockForStartTime()
        
        instructions = CESOutlinedLabel()
        instructions.font = UIFont(name: "Marker Felt", size: 32)
        if showSecondsHand
        {
            instructions.text = "Please set the time on the clock to:\n\(endTime)"
        }
        else
        {
            let concattedTime = endTime.substringToIndex(endTime.startIndex.advancedBy(5))
            instructions.text = "Please set the time on the clock to:\n\(concattedTime)"
        }
        instructions.textColor = ColorScheme.currentColorScheme().primaryColor
        instructions.textAlignment = .Center
        instructions.numberOfLines = 0
        instructions.sizeToFit()
        instructions.center = CGPointMake(clock.center.x, clock.frame.origin.y - 8 - instructions.frame.size.height/2.0)
        view.addSubview(instructions)
        
        currentTimeLabel = CESOutlinedLabel()
        currentTimeLabel.font = UIFont(name: "Marker Felt", size: 32)
        if showSecondsHand
        {
            currentTimeLabel.text = "Current time set:\n\(tempTime != nil ? tempTime! : startTime)"
        }
        else
        {
            let time : String = tempTime != nil ? tempTime! : startTime
            let concattedTime = time.substringToIndex(startTime.startIndex.advancedBy(5))
            currentTimeLabel.text = "Current time set:\n\(concattedTime)"
        }
        currentTimeLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        currentTimeLabel.textAlignment = .Center
        currentTimeLabel.numberOfLines = 0
        currentTimeLabel.sizeToFit()
        currentTimeLabel.center = CGPointMake(clock.center.x, clock.frame.origin.y + clock.frame.size.height + 8 + currentTimeLabel.frame.size.height/2.0)
        view.addSubview(currentTimeLabel)
        
        let checkAnswerTap = UITapGestureRecognizer(target: self, action: "checkAnswer")
        clock.addGestureRecognizer(checkAnswerTap)
        
        clock.rotateHandsToTime(tempTime != nil ? tempTime! : startTime, animated: didCheckAnswer == true || renderingView == RenderingView.Yes ? false:true)
        if didCheckAnswer == true
        {
            checkAnswer(false)
        }
    }
    
    //MARK: - Save and Restore and Settings
    
    func restoreActivityState(object: AnyObject)
    {
        let data = object as! [AnyObject]
        
        let settings = data.first! as! [String : AnyObject]
        startTime = settings["StartTime"] as! String
        endTime = settings["EndTime"] as! String
        bufferZone = settings["BufferZone"] as! String
        handsMoveDependently = (settings["HandsMoveDependently"] as! NSNumber).boolValue
        showSecondsHand = (settings["ShowSecondsHand"] as! NSNumber).boolValue
        minuteHandRounding = MinuteHandRounding(rawValue: (settings["MinuteHandRounding"] as! NSNumber).integerValue)!
        if let checkedAnswer = (settings["DidCheckAnswer"] as? NSNumber)?.boolValue
        {
            didCheckAnswer = checkedAnswer
        }
        
        if data.count > 1
        {
            tempTime = data.last as? String
        }
        if clock != nil
        {
            if showSecondsHand
            {
                instructions.text = "Please set the time on the clock to:\n\(endTime)"
            }
            else
            {
                let concattedTime = endTime.substringToIndex(endTime.startIndex.advancedBy(5))
                instructions.text = "Please set the time on the clock to:\n\(concattedTime)"
            }
            if showSecondsHand
            {
                currentTimeLabel.text = "Current time set:\n\(tempTime != nil ? tempTime! : startTime)"
            }
            else
            {
                let time : String = tempTime != nil ? tempTime! : startTime
                let concattedTime = time.substringToIndex(startTime.startIndex.advancedBy(5))
                currentTimeLabel.text = "Current time set:\n\(concattedTime)"
            }
            clock.handsMoveDependently = handsMoveDependently
            clock.showSecondsHand = showSecondsHand
            clock.minuteHandRounding = minuteHandRounding
        }
    }
    
    func saveActivityState() -> AnyObject
    {
        var returnArray = Array<AnyObject>()
        
        var settings = Dictionary<String, AnyObject>()
        settings.updateValue(startTime, forKey: "StartTime")
        settings.updateValue(endTime, forKey: "EndTime")
        settings.updateValue(bufferZone, forKey: "BufferZone")
        settings.updateValue(NSNumber(bool: handsMoveDependently), forKey: "HandsMoveDependently")
        settings.updateValue(NSNumber(bool: showSecondsHand), forKey: "ShowSecondsHand")
        settings.updateValue(NSNumber(integer: minuteHandRounding.rawValue), forKey: "MinuteHandRounding")
        
        if clock.currentTime != startTime
        {
            settings.updateValue(NSNumber(bool: didCheckAnswer), forKey: "DidCheckAnswer")
            returnArray.append(settings)
            
            returnArray.append(clock.currentTime)
        }
        else
        {
            returnArray.append(settings)
        }
        
        return returnArray
    }
    
    func settings() -> [NSObject : AnyObject]
    {
        return ["Start Time" : "String",
            "End Time" : "String",
            "Buffer Zone" : "String",
            "Hands Move Dependently" : "Boolean",
            "Show Seconds Hand" : "Boolean",
            "Minute Hand Rounding - None, Five, Quarter, Half" : "Picker"]
    }
    
    //MARK: - Create Clock
    
    private func createAndDisplayClockForStartTime()
    {
        clock = Clock(frame: CGRectMake(0, 0, 400, 400), andBorderWidth: 8.0)
        clock.showSecondsHand = showSecondsHand
        clock.handsMoveDependently = handsMoveDependently
        clock.minuteHandRounding = minuteHandRounding
        clock.delegate = self
        clock.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        view.addSubview(clock!)
    }
    
    //MARK: - UI Update Methods
    
    func checkAnswer()
    {
        checkAnswer(true)
    }
    
    //Checks the answer and displays the response
    private func checkAnswer(animated: Bool)
    {
        clock!.userInteractionEnabled = false
        
        let currentTimeComponents = clock!.currentTime.componentsSeparatedByString(":")
        
        let currentHours = (currentTimeComponents[0] as NSString).integerValue
        let currentMinutes = (currentTimeComponents[1] as NSString).integerValue
        var currentSeconds = 0
        
        
        let endTimeComponents = endTime.componentsSeparatedByString(":")
        
        let endHours = (endTimeComponents[0] as NSString).integerValue
        let endMinutes = (endTimeComponents[1] as NSString).integerValue
        var endSeconds = 0
        
        
        let bufferTimeComponents = bufferZone.componentsSeparatedByString(":")
        
        let bufferHours = (bufferTimeComponents[0] as NSString).integerValue
        let bufferMinutes = (bufferTimeComponents[1] as NSString).integerValue
        var bufferSeconds = 0
        
        
        if showSecondsHand
        {
            currentSeconds = (currentTimeComponents[2] as NSString).integerValue
            endSeconds = (endTimeComponents[2] as NSString).integerValue
            bufferSeconds = (bufferTimeComponents[2] as NSString).integerValue
        }
        
        let dimView = UIView(frame: clock!.frame)
        dimView.clipsToBounds = true
        dimView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        dimView.layer.cornerRadius = dimView.frame.size.width/2.0
        dimView.alpha = 0.0
        view.addSubview(dimView)
        
        var checkStatement = (endHours >= currentHours - bufferHours && endHours <= currentHours + bufferHours) &&
            (endMinutes >= currentMinutes - bufferMinutes && endMinutes <= currentMinutes + bufferMinutes)
        if showSecondsHand == true
        {
            checkStatement = checkStatement && (endSeconds >= currentSeconds - bufferSeconds && endSeconds <= currentSeconds + bufferSeconds)
        }
        
        switch  checkStatement
        {
        case true:
            didCheckAnswer = true
            dimView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.4)
            
            let correctLabel = CESOutlinedLabel()
            correctLabel.alpha = 0.0
            correctLabel.text = "Correct!"
            correctLabel.textColor = ColorScheme.currentColorScheme().primaryColor
            correctLabel.font = UIFont(name: "Marker Felt", size: 72)
            correctLabel.sizeToFit()
            correctLabel.center = CGPointMake(dimView.frame.size.width/2.0, dimView.frame.size.height/2.0)
            dimView.addSubview(correctLabel)
            correctLabel.transform = CGAffineTransformMakeScale(0.3, 0.3)
            
            UIView.animateWithDuration(animated == true ? 0.3: 0.0, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                
                dimView.alpha = 1.0
                
                }, completion: { (finished) -> Void in
                    
                    UIView.animateWithDuration(animated == true ? 0.3: 0.0, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                        
                        correctLabel.alpha = 1.0
                        
                        }, completion: nil)
                    UIView.animateWithDuration(animated == true ? 0.5: 0.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                        
                        correctLabel.transform = CGAffineTransformIdentity
                        
                        }, completion: nil)
                    
            })
            break
            
        case false:
            dimView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4)
            
            let incorrectLabel = CESOutlinedLabel()
            incorrectLabel.alpha = 0.0
            incorrectLabel.text = "Incorrect!\nPlease try again!"
            incorrectLabel.numberOfLines = 0
            incorrectLabel.textAlignment = .Center
            incorrectLabel.textColor = ColorScheme.currentColorScheme().primaryColor
            incorrectLabel.font = UIFont(name: "Marker Felt", size: 42)
            incorrectLabel.sizeToFit()
            incorrectLabel.center = CGPointMake(dimView.frame.size.width/2.0, dimView.frame.size.height/2.0)
            dimView.addSubview(incorrectLabel)
            incorrectLabel.transform = CGAffineTransformMakeScale(0.3, 0.3)
            
            UIView.animateWithDuration(animated == true ? 0.3: 0.0, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                
                dimView.alpha = 1.0
                
                }, completion: { (finished) -> Void in
                    
                    UIView.animateWithDuration(animated == true ? 0.3: 0.0, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                        
                        incorrectLabel.alpha = 1.0
                        
                        }, completion: nil)
                    UIView.animateWithDuration(animated == true ? 0.5: 0.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                        
                        incorrectLabel.transform = CGAffineTransformIdentity
                        
                        }, completion: { (finished) -> Void in
                            
                            UIView.animateWithDuration(animated == true ? 0.3: 0.0, delay: 1.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                                
                                dimView.alpha = 0.0
                                incorrectLabel.transform = CGAffineTransformMakeScale(2.0, 2.0)
                                
                                }, completion: { (finished) -> Void in
                                    
                                    dimView.removeFromSuperview()
                                    self.clock!.userInteractionEnabled = true
                            })
                    })
            })
            break
        }
    }
    
    //Updates the current time label on screen
    func updateCurrentTimeLabel()
    {
        currentTimeLabel!.text = "Current time set:\n\(clock!.currentTime)"
    }
    
}
