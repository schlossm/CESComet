//
//  CESDatabase.swift
//  FloraDummy
//
//  Created by Michael Schloss on 12/12/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//


//--------------------------------------------------------------------------------\\
//---------------------------------------------------------------------------------\\
//  Please see the CESDatabaseProtocols file for an expanation of the CESDatabase  ||
//-------------------------------------------------------------------------------- //
//--------------------------------------------------------------------------------//

import Foundation
import CoreData

private let databaseEncryptionKey   = "I1rObD475i"

private var databaseManagerInstance : CESDatabase!

///The Database Manager that manages all other databases
class CESDatabase : NSObject
{
    private var activityCreationDatabaseManager : ActivityCreationDatabase!
    private var activityManagerDatabaseManager  : ActivityManagerVCDatabase!
    private var userAccountsDatabaseManager     : UserAccountsDatabase!
    private var mainActivitiesDatabaseManager   : MainActivitiesDatabase!
    
    private override init()
    {
        super.init()
        
        activityCreationDatabaseManager = ActivityCreationDatabaseManager()
        activityManagerDatabaseManager  = ActivityManagerDatabaseManager()
        userAccountsDatabaseManager     = UserAccountsDatabaseManager()
        mainActivitiesDatabaseManager   = MainActivitiesDatabaseManager()
    }
    
    private class func sharedManager() -> CESDatabase
    {
        guard databaseManagerInstance != nil else { databaseManagerInstance = CESDatabase(); return databaseManagerInstance }
        return databaseManagerInstance
    }
    
    class func databaseManagerForPageManagerClass() -> ActivityManagerVCDatabase
    {
        return CESDatabase.sharedManager().activityManagerDatabaseManager
    }
    
    class func databaseManagerForCreationClass() -> ActivityCreationDatabase
    {
        return CESDatabase.sharedManager().activityCreationDatabaseManager
    }
    
    class func databaseManagerForPasswordVCClass() -> UserAccountsDatabase
    {
        return CESDatabase.sharedManager().userAccountsDatabaseManager
    }
    
    class func databaseManagerForMainActivitiesClass() -> MainActivitiesDatabase
    {
        return CESDatabase.sharedManager().mainActivitiesDatabaseManager
    }
}

//Private Database for Activity Creation
private class ActivityCreationDatabaseManager : ActivityCreationDatabase
{
    private init() { }
    
    @objc func uploadNewActivity(activity: Activity, completion: (activityID: String?) -> Void)
    {
        guard isValidActivity(activity) else { completion(activityID: nil); return }
        let SQLStatementGetMaxActivityID = NASQL().select("MAX(activityID)").from("Activity")
        
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetMaxActivityID) { (returnArray, error) -> Void in
            var activityID = 0
            
            guard error == nil || error?.code == 1 else
            {
                completion(activityID: nil)
                return
            }
            
            guard let downloadedActivityID = returnArray as? [NSDictionary] else { completion(activityID: nil); return }
            guard downloadedActivityID.count == 1 else { completion(activityID: nil); return }
            
            if error?.code == 1
            {
                activityID = 1
            }
            else
            {
                let ID = downloadedActivityID.first!["MAX(activityID)"] as! Int
                activityID = ID + 1
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            archiver.encodeObject(activity.activityData, forKey: "activityData")
            archiver.finishEncoding()
            
            let SQLStatementInsertNewActivity = NASQL(rawSQL: "INSERT INTO `Activity`(activityID, name, description, totalPoints, Quiz, releaseDate, dueDate, activityData, classID) VALUES ('\(activityID)','\(activity.name)','\(activity.activityDescription)','\(activity.totalPoints)','\(Int(activity.quizMode))','\(dateFormatter.stringFromDate(activity.releaseDate))','\(dateFormatter.stringFromDate(activity.dueDate))','\(data.hexRepresentationWithSpaces(false, capitals: false))','\(activity.classID)')")
            
            NADatabase.sharedDatabase().dataUploader.uploadDataWithSQLStatement(SQLStatementInsertNewActivity, completion: { (success) -> Void in
                if success == true
                {
                    completion(activityID: String(activityID))
                }
                else
                {
                    completion(activityID: nil)
                }
            })
        }
    }
    
    private func isValidActivity(activityInformation: Activity) -> Bool
    {
        return activityInformation.name != "" && activityInformation.activityDescription != "" && activityInformation.totalPoints != -1 && activityInformation.releaseDate != NSDate() && activityInformation.dueDate != NSDate() && activityInformation.releaseDate.isEqualToDate(activityInformation.dueDate) == false && activityInformation.activityData.count > 0 && activityInformation.classID != ""
    }
}

//Private Database for Page Manager
private class ActivityManagerDatabaseManager: ActivityManagerVCDatabase
{
    private init() { }
    
    @objc func activitySessionForActivityID(activityID: String, activity: Activity) -> ActivitySession
    {
        let newActivitySession = ActivitySession()
        newActivitySession.activityID = activityID
        
        let request = NSFetchRequest(entityName: "ActivitySession")
        request.predicate = NSPredicate(format: "activityID==%@", activityID)
        let foundActivitySession = try? NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
        
        guard let activitySession = foundActivitySession?.first else
        {
            newActivitySession.activityData = activity.activityData as! [[NSNumber : AnyObject]]
            
            return newActivitySession
        }
        
        newActivitySession.score = activitySession.valueForKey("score") as! String
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        newActivitySession.startDate = dateFormatter.dateFromString(activitySession.valueForKey("startDate") as! String)!
        newActivitySession.endDate = dateFormatter.dateFromString(activitySession.valueForKey("finishDate") as! String)!
        
        newActivitySession.status = activitySession.valueForKey("status") as! String
        
        let decryptedData = NADatabase.sharedDatabase().decryptObject(activitySession.valueForKey("activityData") as! String) as! [[NSNumber : AnyObject]]
        newActivitySession.activityData = decryptedData
        
        return newActivitySession
    }
    
    @objc func uploadActivitySession(activitySession: ActivitySession, completion: (uploadSuccess: Bool) -> Void)
    {
        guard isValidActivitySession(activitySession) else { completion(uploadSuccess: false); return }
        
        let request = NSFetchRequest(entityName: "ActivitySession")
        if activitySession.activitySessionID != "000000"
        {
            request.predicate = NSPredicate(format: "activitySessionID==%@", activitySession.activitySessionID)
        }
        else
        {
            request.predicate = NSPredicate(format: "activityID==%@ && userID==%@ && status==%@", activitySession.activityID, CurrentUser.currentUser().userID, "In Progress")
        }
        let results = try? NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
        
        var SQLStatementUploadActivitySession = NASQL()
        
        let data = NADatabase.sharedDatabase().encryptObject(activitySession.activityData)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        if let foundActivitySession = results?.first //Update the found activitySession
        {
            if activitySession.endDate == nil
            {
                SQLStatementUploadActivitySession = NASQL(rawSQL: "UPDATE `ActivitySession` SET `startDate`=`\(dateFormatter.stringFromDate(activitySession.startDate))`,`score`=`\(activitySession.score)`,`activityData`=`\(data)`,`status`=`\(activitySession.status)` WHERE `activitySessionID`='\(activitySession.activitySessionID)'")
                foundActivitySession.setValue(data, forKey: "activityData")
                foundActivitySession.setValue(activitySession.status, forKey: "status")
            }
            else
            {
                SQLStatementUploadActivitySession = NASQL(rawSQL: "UPDATE `ActivitySession` SET `startDate`=`\(dateFormatter.stringFromDate(activitySession.startDate))`,`finishDate`=`\(dateFormatter.stringFromDate(activitySession.endDate!))`,`score`=`\(activitySession.score)`,`activityData`=`\(data)`,`status`=`\(activitySession.status)` WHERE `activitySessionID`='\(activitySession.activitySessionID)'")
                
                foundActivitySession.setValue(data, forKey: "activityData")
                foundActivitySession.setValue(activitySession.score, forKey: "score")
                foundActivitySession.setValue(dateFormatter.stringFromDate(activitySession.endDate!), forKey: "finishDate")
                foundActivitySession.setValue(activitySession.status, forKey: "status")
            }
            
            try! saveCoreData()
            
            NADatabase.sharedDatabase().dataUploader.uploadDataWithSQLStatement(SQLStatementUploadActivitySession) { (success) -> Void in
                completion(uploadSuccess: success)
            }
        }
        else
        {
            let SQLStatementGetMaxActivitySessionID = NASQL().select("MAX(activitySessionID)").from("ActivitySession")
            NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetMaxActivitySessionID, completion: { (returnArray, error) -> Void in
                var activitySessionID = 0
                
                guard error == nil || error?.code == 1 else
                {
                    completion(uploadSuccess: false)
                    return
                }
                
                guard let downloadedActivitySessionID = returnArray as? [NSDictionary] else { completion(uploadSuccess: false); return }
                guard downloadedActivitySessionID.count == 1 else { completion(uploadSuccess: false); return }
                
                if error?.code == 1
                {
                    activitySessionID = 1
                }
                else
                {
                    let ID = downloadedActivitySessionID.first!["MAX(activitySessionID)"] as! Int
                    activitySessionID = ID + 1
                }
                
                let entity = NSEntityDescription.entityForName("ActivitySession", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!
                let newActivitySession = NSManagedObject(entity: entity, insertIntoManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)
                newActivitySession.setValue(activitySessionID, forKey: "activitySessionID")
                newActivitySession.setValue(activitySession.activityID, forKey: "activityID")
                newActivitySession.setValue(CurrentUser.currentUser().userID, forKey: "userID")
                newActivitySession.setValue(dateFormatter.stringFromDate(activitySession.startDate), forKey: "startDate")
                newActivitySession.setValue(activitySession.status, forKey: "status")
                newActivitySession.setValue(activitySession.score, forKey: "score")
                newActivitySession.setValue(data, forKey: "activityData")
                
                if activitySession.endDate != nil
                {
                    SQLStatementUploadActivitySession = NASQL(rawSQL:"INSERT INTO ActivitySession(activitySessionID, activityID, userID, score, activityData, startDate, finishDate, status) VALUES ('\(activitySessionID)','\(activitySession.activityID)','\(CurrentUser.currentUser().userID)','\(activitySession.score)','\(data)','\(dateFormatter.stringFromDate(activitySession.startDate))','\(dateFormatter.stringFromDate(activitySession.endDate!))','\(activitySession.status)')")
                    newActivitySession.setValue(dateFormatter.stringFromDate(activitySession.endDate!), forKey: "finishDate")
                }
                else
                {
                    SQLStatementUploadActivitySession = NASQL(rawSQL:"INSERT INTO ActivitySession(activitySessionID, activityID, userID, score, activityData, startDate, status) VALUES ('\(activitySessionID)','\(activitySession.activityID)','\(CurrentUser.currentUser().userID)','\(activitySession.score)','\(data)','\(dateFormatter.stringFromDate(activitySession.startDate))','\(activitySession.status)')")
                }
                
                try! saveCoreData()
                
                NADatabase.sharedDatabase().dataUploader.uploadDataWithSQLStatement(SQLStatementUploadActivitySession) { (success) -> Void in
                    completion(uploadSuccess: success)
                }
            })
        }
    }
    
    private func isValidActivitySession(activityInformation: ActivitySession) -> Bool
    {
        return activityInformation.activityID != "000000" && activityInformation.score != "000" && activityInformation.activityData.isEmpty != false && activityInformation.startDate != NSDate() && activityInformation.endDate != NSDate() && activityInformation.status != "Not Started"
    }
}

//Private Database for user account information and comparing
private class UserAccountsDatabaseManager : UserAccountsDatabase
{
    private var inputtedInfoIsValid = false
    
    private init() { }
    
    @objc func inputtedUsernameIsValid(username: String, andPassword password: String, completion: (Bool) -> Void)
    {
        let newCompletion = { (success: Bool) -> Void in
            self.inputtedInfoIsValid = success
            completion(success)
        }
        
        let encryptedUserName = NADatabase.sharedDatabase().encryptString(username)
        let encryptedPassword = NADatabase.sharedDatabase().encryptString(password)
        
        let SQLStatementCheckValidUser = try! NASQL().select("SUM(userID)").from("User").whereAND(["username", "password"], [encryptedUserName, encryptedPassword])
        
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementCheckValidUser) { (returnArray, error) -> Void in
            guard error == nil else { newCompletion(false); return }
            
            guard let downloadedUserID = returnArray as? [NSDictionary] else { newCompletion(false); return }
            guard downloadedUserID.count == 1 else { newCompletion(false); return }
            
            newCompletion((downloadedUserID.first!["SUM(userID)"] as! Int) == 1)
        }
    }
    
    @objc func downloadUserInformationForUser(username: String, andPassword password: String, completion: (Bool) -> Void)
    {
        guard inputtedInfoIsValid else { completion(false); return }
        
        let encryptedUserName = NADatabase.sharedDatabase().encryptString(username)
        let encryptedPassword = NADatabase.sharedDatabase().encryptString(password)
        
        let SQLStatementGetUserInformation = try! NASQL().select().from("User").whereAND(["username", "password"], [encryptedUserName, encryptedPassword])
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetUserInformation) { (returnArray, error) -> Void in
            guard error == nil else { completion(false); return }
            guard let downloadedUserInfo = returnArray as? [NSDictionary] else { completion(false); return }
            
            let downloadedUser = downloadedUserInfo.first!
            var SQLStatementGetSpecificUserInformation = NASQL()
            
            switch downloadedUser["userType"] as! Int
            {
            case 0:
                SQLStatementGetSpecificUserInformation = NASQL().select().from("Student").whereEquals("userID", downloadedUser["userID"] as! String)
                
            case 1:
                SQLStatementGetSpecificUserInformation = NASQL().select().from("Teacher").whereEquals("userID", downloadedUser["userID"] as! String)
                
            default: break
            }
            
            NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetSpecificUserInformation, completion: { (returnArray, error) -> Void in
                guard error == nil else { completion(false); return }
                guard let downloadedSpecificUserInfo = returnArray as? [NSDictionary] else { completion(false); return }
                let downloadedSpecificUser = downloadedSpecificUserInfo.first!
                
                let entity = NSEntityDescription.entityForName("CurrentUser", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!
                let currentUser = NSManagedObject(entity: entity, insertIntoManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)
                currentUser.setValue(downloadedUser.valueForKey("userID") as! String, forKey: "userID")
                currentUser.setValue(downloadedUser.valueForKey("username") as! String, forKey: "username")
                currentUser.setValue(downloadedUser.valueForKey("password") as! String, forKey: "password")
                currentUser.setValue(downloadedUser.valueForKey("firstName") as! String, forKey: "firstName")
                currentUser.setValue(downloadedUser.valueForKey("lastName") as! String, forKey: "lastName")
                currentUser.setValue(downloadedUser.valueForKey("userType") as! String, forKey: "userType")
                currentUser.setValue(downloadedSpecificUser.valueForKey("grade") as? String, forKey: "grade")
                currentUser.setValue(downloadedSpecificUser.valueForKey("colorID") as? String, forKey: "grade")
                currentUser.setValue(downloadedSpecificUser.valueForKey("homeScreenLayout") as? String, forKey: "grade")
                
                do
                {
                    try saveCoreData()
                    completion(true)
                }
                catch
                {
                    completion(false)
                }
            })
        }
    }
}

//Private Database for the Main Activity Pages
private class MainActivitiesDatabaseManager : MainActivitiesDatabase
{
    private init() { }
    
    private func loadActivitySessions()
    {
        print("Loading Activity Sessions...")
        
        let SQLStatementGetActivitySessions = NASQL().select().from("ActivitySession").whereEquals("userID", CurrentUser.currentUser().userID)
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetActivitySessions) { (returnArray, error) -> Void in
            guard error == nil || error?.code == 1 else
            {
                //TODO: Error
                return
            }
            
            guard let downloadedActivitySessions = returnArray as? [NSDictionary] else {/*//TODO: Error*/ return }
            for downloadedActivitySession in downloadedActivitySessions
            {
                guard NADatabase.sharedDatabase().keyValuePairIsNewForEntity("ActivitySession", keyValuePair: ("activitySessionID", downloadedActivitySession["activitySessionID"] as! String)) else { continue }
                
                let entity = NSEntityDescription.entityForName("ActivitySession", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!
                let activitySession = NSManagedObject(entity: entity, insertIntoManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)
                activitySession.setValue(downloadedActivitySession["activitySessionID"], forKey: "activitySessionID")
                activitySession.setValue(downloadedActivitySession["activityID"], forKey: "activityID")
                activitySession.setValue(downloadedActivitySession["userID"], forKey: "userID")
                activitySession.setValue(downloadedActivitySession["activityData"], forKey: "activityData")
                activitySession.setValue(downloadedActivitySession["startDate"], forKey: "startDate")
                activitySession.setValue(downloadedActivitySession["finishDate"], forKey: "finishDate")
                activitySession.setValue(downloadedActivitySession["score"], forKey: "score")
                activitySession.setValue(downloadedActivitySession["status"], forKey: "status")
                
                do
                {
                    try saveCoreData()
                }
                catch
                {
                    //TODO: Error
                }
            }
            
            self.checkForActivityInformationLoaded()
        }
    }
    
    private func loadClasses()
    {
        print("Loading Classes...")
        
        let SQLStatementGetActivitySessions = NASQL(rawSQL: "SELECT * FROM Class Join StudentClass ON StudentClass.classID=Class.classID WHERE StudentClass.userID=\(CurrentUser.currentUser().userID)")
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetActivitySessions) { (returnArray, error) -> Void in
            guard error == nil || error?.code == 1 else
            {
                //TODO: Error
                return
            }
            
            guard let downloadedClasses = returnArray as? [NSDictionary] else {/*//TODO: Error*/ return }
            for downloadedClass in downloadedClasses
            {
                guard NADatabase.sharedDatabase().keyValuePairIsNewForEntity("Class", keyValuePair: ("classID", downloadedClass["classID"] as! String)) else { continue }
                
                let entity = NSEntityDescription.entityForName("Class", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!
                let activitySession = NSManagedObject(entity: entity, insertIntoManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)
                activitySession.setValue(downloadedClass["schoolYear"], forKey: "schoolYear")
                activitySession.setValue(downloadedClass["classID"], forKey: "classID")
                activitySession.setValue(downloadedClass["subjectID"], forKey: "subjectID")
                
                do
                {
                    try saveCoreData()
                }
                catch
                {
                    //TODO: Error
                }
            }
            
            self.checkForActivityInformationLoaded()
        }
    }
    
    private func loadActivities()
    {
        print("Loading Activities...")
        
        let SQLStatementGetActivities = NASQL(rawSQL: "SELECT * FROM Activity Join StudentClass ON Activity.classID=StudentClass.classID WHERE StudentClass.userID=\(CurrentUser.currentUser().userID)")
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetActivities) { (returnArray, error) -> Void in
            guard error == nil || error?.code == 1 else
            {
                //TODO: Error
                return
            }
            
            guard let downloadedActivities = returnArray as? [NSDictionary] else {/*//TODO: Error*/ return }
            for downloadedActivity in downloadedActivities
            {
                guard NADatabase.sharedDatabase().keyValuePairIsNewForEntity("Activity", keyValuePair: ("activityID", downloadedActivity["activityID"] as! String)) else { continue }
                
                let entity = NSEntityDescription.entityForName("Activity", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!
                let activity = NSManagedObject(entity: entity, insertIntoManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)
                activity.setValue(downloadedActivity["activityID"], forKey: "activityID")
                activity.setValue(downloadedActivity["name"], forKey: "name")
                activity.setValue(downloadedActivity["description"], forKey: "activityDescription")
                activity.setValue(downloadedActivity["totalPoints"], forKey: "totalPoints")
                activity.setValue(downloadedActivity["releaseDate"], forKey: "releaseDate")
                activity.setValue(downloadedActivity["dueDate"], forKey: "dueDate")
                activity.setValue(downloadedActivity["activityData"], forKey: "activityData")
                activity.setValue(downloadedActivity["quiz"], forKey: "quiz")
                activity.setValue(downloadedActivity["classID"], forKey: "classID")
                
                do
                {
                    try saveCoreData()
                }
                catch
                {
                    //TODO: Error
                }
            }
            
            self.checkForActivityInformationLoaded()
        }
    }
    
    private var count = 0
    private var totalCount = 0
    
    @objc func loadUserActivities()
    {
        if NSUserDefaults.standardUserDefaults().stringForKey("defaultLogin") == "Student"
        {
            totalCount = 3
            loadActivities()
            loadClasses()
            loadActivitySessions()
        }
    }
    
    private func checkForActivityInformationLoaded()
    {
        count++
        guard count == totalCount else { return }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ActivityDataLoaded, object: nil)
    }
    
    @objc func activityForActivityDictionary(activityDict: NSDictionary) -> Activity
    {
        let activityToReturn = Activity()
        
        activityToReturn.activityID = activityDict["activityID"] as! String
        activityToReturn.activityDescription = activityDict["description"] as! String
        activityToReturn.name = activityDict["name"] as! String
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        activityToReturn.releaseDate = dateFormatter.dateFromString(activityDict["releaseDate"] as! String)
        activityToReturn.dueDate = dateFormatter.dateFromString(activityDict["dueDate"] as! String)
        
        let activityData = activityDict["activityData"] as! String?
        if activityData != "Null"
        {
            let data = NSData().dataFromHexString(activityData)
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            activityToReturn.activityData = unarchiver.decodeObjectForKey("activityData") as! Array<Dictionary<NSNumber, AnyObject>>
            unarchiver.finishDecoding()
        }
        
        if Int((activityDict["quiz"] as! String)) == 0
        {
            activityToReturn.quizMode = false
        }
        else
        {
            activityToReturn.quizMode = true
        }
        
        activityToReturn.classID = activityDict["classID"] as! String
        activityToReturn.totalPoints = Int((activityDict["totalPoints"] as! String))!
        
        return activityToReturn
    }
}