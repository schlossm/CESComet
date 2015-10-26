//
//  CurrentUser.swift
//  CES
//
//  Created by Michael Schloss on 10/1/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit
import CoreData

@objc enum Grade : UInt
{
    case Kindergarten, First, Second, Third, Fourth, Fixth, Sixth
}

@objc enum UserType : UInt
{
    case Student, Teacher, Admin, Owner, Invalid
}

@objc enum HomeScreenLayout : UInt
{
    case Expanded, Compact
}

private var currentUserInstance : CurrentUser!

class CurrentUser : NSObject
{
    private var currentUserObject : NSManagedObject!
    
    var grade : Grade?
        {
        get
        {
            guard currentUserObject.valueForKey("grade") != nil else { return nil }
            return Grade(rawValue: UInt(currentUserObject.valueForKey("grade") as! String)!)
        }
    }
    
    var userType : UserType
        {
        get
        {
            return UserType(rawValue: UInt(currentUserObject.valueForKey("userType") as! String)!)!
        }
    }
    
    var userID : String
        {
        get
        {
            return currentUserObject.valueForKey("userID") as! String
        }
    }
    
    var firstName : String
        {
        get
        {
            return currentUserObject.valueForKey("firstName") as! String
        }
    }
    
    var lastName : String
        {
        get
        {
            return currentUserObject.valueForKey("lastName") as! String
        }
    }
    
    var colorID : Int?
        {
        get
        {
            guard currentUserObject.valueForKey("colorID") != nil else { return nil }
            return Int(currentUserObject.valueForKey("colorID") as! String)!
        }
    }
    
    var homeScreenLayout : HomeScreenLayout?
        {
        get
        {
            guard currentUserObject.valueForKey("homeScreenLayout") != nil else { return nil }
            return HomeScreenLayout(rawValue: currentUserObject.valueForKey("homeScreenLayout") as! UInt)
        }
    }
    
    private override init()
    {
        super.init()
    }
    
    class func hasSavedUserInformation() -> Bool
    {
        let results = try? NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "CurrentUser")).count
        return results == 1
    }
    
    class func currentUser() -> CurrentUser
    {
        guard currentUserInstance != nil else { currentUserInstance = CurrentUser(); return currentUserInstance }
        return currentUserInstance
    }
    
    func loadSavedUser()
    {
        let results = try! NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "CurrentUser")) as! [NSManagedObject]
        currentUserObject = results[0]
    }
}
