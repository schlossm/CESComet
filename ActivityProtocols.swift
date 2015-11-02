//
//  ActivityProtocols.swift
//  CES
//
//  Created by Michael Schloss on 10/31/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit
import CoreData

@objc enum QuizMode : Int
{
    case No, Yes
}

@objc enum ActivitySessionStatus : Int
{
    case NotStarted, Started, Finished
}

@objc protocol Activity
{
    var activityID : Int { get }
    
    var name : String { get }
    
    var activityDescription : String { get }
    
    var totalPoints : Int { get }
    
    var releaseDate : NSDate { get }
    
    var dueDate : NSDate { get }
    
    var activityData : [[Int:AnyObject]]? { get }
    
    var quizMode : QuizMode { get }
    
    var classID : Int { get }
}

@objc protocol ActivitySession
{
    var activitySessionID : Int { get }
    
    var activityID : Int { get }
    
    var grade : Double { get set }
    
    var activityData : [[Int:AnyObject]]? { get set }
    
    var startDate : NSDate { get set }
    
    var endDate : NSDate? { get set }
    
    var status : ActivitySessionStatus { get set }
}