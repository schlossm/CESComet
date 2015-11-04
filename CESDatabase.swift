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
            
            let data = NADatabase.sharedDatabase().encryptObject(activity.activityData!)
            
            let SQLStatementInsertNewActivity = NASQL(rawSQL: "INSERT INTO `Activity`(activityID, name, description, totalPoints, Quiz, releaseDate, dueDate, activityData, classID) VALUES ('\(activityID)','\(activity.name)','\(activity.activityDescription)','\(activity.totalPoints)','\(activity.quizMode.rawValue)','\(dateFormatter.stringFromDate(activity.releaseDate))','\(dateFormatter.stringFromDate(activity.dueDate))','\(data)','\(activity.classID)')")
            
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
        return activityInformation.name != "" && activityInformation.activityDescription != "" && activityInformation.totalPoints != -1 && activityInformation.releaseDate != NSDate() && activityInformation.dueDate != NSDate() && activityInformation.releaseDate.isEqualToDate(activityInformation.dueDate) == false && activityInformation.activityData!.count > 0 && activityInformation.classID != -1
    }
}

//Private Database for Page Manager
private class ActivityManagerDatabaseManager: ActivityManagerVCDatabase
{
    private init() { }
    
    @objc func activitySessionForActivity(activity: Activity) -> ActivitySession
    {
        let request = NSFetchRequest(entityName: "ActivitySession")
        request.predicate = NSPredicate(format: "activityID == %d", activity.activityID)
        let foundActivitySession = try? NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
        
        guard let activitySession = foundActivitySession?.first else
        {
            return CESDatabaseActivitySessionObject(activitySessionID: nil, activityID: activity.activityID, grade: -1.0, activityData: activity.activityData ?? [[Int : AnyObject]](), startDate: NSDate(), endDate: nil, status: ActivitySessionStatus.Started)
        }
        
        let score = Double(activitySession.valueForKey("score") as! String)!
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let startDate = dateFormatter.dateFromString(activitySession.valueForKey("startDate") as! String)!
        let endDate = dateFormatter.dateFromString(activitySession.valueForKey("finishDate") as! String)!
        
        let status = ActivitySessionStatus(rawValue: Int(activitySession.valueForKey("status") as! String)!)!
        
        let decryptedData = NADatabase.sharedDatabase().decryptObject(activitySession.valueForKey("activityData") as! String) as! [[Int : AnyObject]]
        
        return CESDatabaseActivitySessionObject(activitySessionID: Int(activitySession.valueForKey("activitySessionID") as! String)!, activityID: activity.activityID, grade: score, activityData: decryptedData, startDate: startDate, endDate: endDate, status: status)
    }
    
    @objc func uploadActivitySession(activitySession: ActivitySession, completion: (uploadSuccess: Bool) -> Void)
    {
        guard isValidActivitySession(activitySession) else { completion(uploadSuccess: false); return }
        
        let request = NSFetchRequest(entityName: "ActivitySession")
        if activitySession.activitySessionID != -1
        {
            request.predicate = NSPredicate(format: "activitySessionID==%@", activitySession.activitySessionID)
        }
        else
        {
            request.predicate = NSPredicate(format: "activityID==%@ && userID==%@", activitySession.activityID, CurrentUser.currentUser().userID)
        }
        let results = try? NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
        
        var SQLStatementUploadActivitySession = NASQL()
        
        let data = NADatabase.sharedDatabase().encryptObject(activitySession.activityData!)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        if let foundActivitySession = results?.first //Update the found activitySession
        {
            if activitySession.endDate == nil
            {
                SQLStatementUploadActivitySession = NASQL(rawSQL: "UPDATE `ActivitySession` SET `startDate`=`\(dateFormatter.stringFromDate(activitySession.startDate))`,`score`=`\(activitySession.grade)`,`activityData`=`\(data)`,`status`=`\(activitySession.status)` WHERE `activitySessionID`='\(activitySession.activitySessionID)'")
                foundActivitySession.setValue(data, forKey: "activityData")
                foundActivitySession.setValue(activitySession.status.rawValue, forKey: "status")
            }
            else
            {
                SQLStatementUploadActivitySession = NASQL(rawSQL: "UPDATE `ActivitySession` SET `startDate`=`\(dateFormatter.stringFromDate(activitySession.startDate))`,`finishDate`=`\(dateFormatter.stringFromDate(activitySession.endDate!))`,`score`=`\(activitySession.grade)`,`activityData`=`\(data)`,`status`=`\(activitySession.status.rawValue)` WHERE `activitySessionID`='\(activitySession.activitySessionID)'")
                
                foundActivitySession.setValue(data, forKey: "activityData")
                foundActivitySession.setValue(activitySession.grade, forKey: "score")
                foundActivitySession.setValue(dateFormatter.stringFromDate(activitySession.endDate!), forKey: "finishDate")
                foundActivitySession.setValue(String(activitySession.status.rawValue), forKey: "status")
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
                newActivitySession.setValue(String(activitySession.status.rawValue), forKey: "status")
                newActivitySession.setValue(activitySession.grade, forKey: "score")
                newActivitySession.setValue(data, forKey: "activityData")
                
                if activitySession.endDate != nil
                {
                    SQLStatementUploadActivitySession = NASQL(rawSQL:"INSERT INTO ActivitySession(activitySessionID, activityID, userID, score, activityData, startDate, finishDate, status) VALUES ('\(activitySessionID)','\(activitySession.activityID)','\(CurrentUser.currentUser().userID)','\(activitySession.grade)','\(data)','\(dateFormatter.stringFromDate(activitySession.startDate))','\(dateFormatter.stringFromDate(activitySession.endDate!))','\(activitySession.status.rawValue)')")
                    newActivitySession.setValue(dateFormatter.stringFromDate(activitySession.endDate!), forKey: "finishDate")
                }
                else
                {
                    SQLStatementUploadActivitySession = NASQL(rawSQL:"INSERT INTO ActivitySession(activitySessionID, activityID, userID, score, activityData, startDate, status) VALUES ('\(activitySessionID)','\(activitySession.activityID)','\(CurrentUser.currentUser().userID)','\(activitySession.grade)','\(data)','\(dateFormatter.stringFromDate(activitySession.startDate))','\(activitySession.status.rawValue)')")
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
        return activityInformation.activityID != -1 && activityInformation.grade != -1.0
    }
}

//Private Database for user account information and comparing
private class UserAccountsDatabaseManager : UserAccountsDatabase
{
    private var inputtedInfoIsValid = false
    
    private init() { }
    
    @objc func inputtedUsernameIsValid(user: String?, andPassword pass: String?, completion: (Bool) -> Void)
    {
        guard let username = user  else { completion(false); return }
        guard let password = pass  else { completion(false); return }
        
        let newCompletion = { [unowned self] (success: Bool) -> Void in
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
            
            newCompletion(Int(downloadedUserID.first!["SUM(userID)"] as! String)! == 1)
        }
    }
    
    @objc func downloadUserInformationForUser(user: String?, andPassword pass: String?, completion: (Bool) -> Void)
    {
        guard let username = user else { completion(false); return }
        guard let password = pass else { completion(false); return }
        guard inputtedInfoIsValid else { completion(false); return }
        
        let encryptedUserName = NADatabase.sharedDatabase().encryptString(username)
        let encryptedPassword = NADatabase.sharedDatabase().encryptString(password)
        
        let SQLStatementGetUserInformation = try! NASQL().select().from("User").whereAND(["username", "password"], [encryptedUserName, encryptedPassword])
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetUserInformation) { (returnArray, error) -> Void in
            guard error == nil else { completion(false); return }
            guard let downloadedUserInfo = returnArray as? [NSDictionary] else { completion(false); return }
            
            let downloadedUser = downloadedUserInfo.first!
            var SQLStatementGetSpecificUserInformation = NASQL()
            
            switch Int(downloadedUser["userType"] as! String)!
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
    
    @objc var activityDataIsLoaded = false
    
    private func loadActivitySessions()
    {
        print("Loading Activity Sessions...")
        
        let SQLStatementGetActivitySessions = NASQL().select().from("ActivitySession").whereEquals("userID", CurrentUser.currentUser().userID)
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetActivitySessions) { [unowned self] (returnArray, error) -> Void in
            guard error == nil || error?.code == 1 else
            {
                print("ActivitySession Error 2")
                //TODO: Error
                return
            }
            
            guard returnArray != nil else { self.checkForActivityInformationLoaded(); return }
            guard let downloadedActivitySessions = returnArray as? [NSDictionary] else {print("ActivitySession Error 2"); /*//TODO: Error*/ return }
            for downloadedActivitySession in downloadedActivitySessions
            {
                guard NADatabase.sharedDatabase().keyValuePairIsNewForEntity("ActivitySession", keyValuePair: ("activitySessionID", downloadedActivitySession["activitySessionID"] as! String)) else { continue }
                
                let entity = NSEntityDescription.entityForName("ActivitySession", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!
                let activitySession = NSManagedObject(entity: entity, insertIntoManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)
                activitySession.setValue(downloadedActivitySession["activitySessionID"] as! String, forKey: "activitySessionID")
                activitySession.setValue(downloadedActivitySession["activityID"] as! String, forKey: "activityID")
                activitySession.setValue(downloadedActivitySession["userID"] as! String, forKey: "userID")
                activitySession.setValue(downloadedActivitySession["activityData"] as! String, forKey: "activityData")
                activitySession.setValue(downloadedActivitySession["startDate"] as! String, forKey: "startDate")
                activitySession.setValue(downloadedActivitySession["finishDate"] as! String, forKey: "finishDate")
                activitySession.setValue(downloadedActivitySession["score"] as! String, forKey: "score")
                activitySession.setValue(downloadedActivitySession["status"] as! String, forKey: "status")
                
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
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetActivitySessions) { [unowned self] (returnArray, error) -> Void in
            guard error == nil || error?.code == 1 else
            {
                print("Class Error 1")
                //TODO: Error
                return
            }
            
            guard let downloadedClasses = returnArray as? [NSDictionary] else {print("Class Error 2"); /*//TODO: Error*/ return }
            for downloadedClass in downloadedClasses
            {
                guard NADatabase.sharedDatabase().keyValuePairIsNewForEntity("Class", keyValuePair: ("classID", downloadedClass["classID"] as! String)) else
                {
                    let fetch = NSFetchRequest(entityName: "Class")
                    fetch.predicate = NSPredicate(format: "classID ==[c] %@", downloadedClass["classID"] as! String)
                    let results = try! NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(fetch) as! [NSManagedObject]
                    let classObject = results.first!
                    classObject.setValue(downloadedClass["notifications"] as? String, forKey: "notifications")
                    try! saveCoreData()
                    continue
                }
                
                let entity = NSEntityDescription.entityForName("Class", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!
                let classObject = NSManagedObject(entity: entity, insertIntoManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)
                classObject.setValue(downloadedClass["notifications"] as? String, forKey: "notifications")
                classObject.setValue(downloadedClass["schoolYear"] as! String, forKey: "schoolYear")
                classObject.setValue(downloadedClass["classID"] as! String, forKey: "classID")
                classObject.setValue(downloadedClass["subjectID"] as! String, forKey: "subjectID")
                
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
        NADatabase.sharedDatabase().dataDownloader.downloadDataWithSQLStatement(SQLStatementGetActivities) { [unowned self] (returnArray, error) -> Void in
            guard error == nil || error?.code == 1 else
            {
                print("Activity Error 1")
                //TODO: Error
                return
            }
            
            guard let downloadedActivities = returnArray as? [NSDictionary] else {print("Activity Error 2"); /*//TODO: Error*/ return }
            for downloadedActivity in downloadedActivities
            {
                guard NADatabase.sharedDatabase().keyValuePairIsNewForEntity("Activity", keyValuePair: ("activityID", downloadedActivity["activityID"] as! String)) else { continue }
                
                let entity = NSEntityDescription.entityForName("Activity", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!
                let activity = NSManagedObject(entity: entity, insertIntoManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)
                activity.setValue(downloadedActivity["activityID"] as! String, forKey: "activityID")
                activity.setValue(downloadedActivity["name"] as! String, forKey: "name")
                activity.setValue(downloadedActivity["description"] as! String, forKey: "activityDescription")
                activity.setValue(downloadedActivity["totalPoints"] as! String, forKey: "totalPoints")
                activity.setValue(downloadedActivity["releaseDate"] as! String, forKey: "releaseDate")
                activity.setValue(downloadedActivity["dueDate"] as! String, forKey: "dueDate")
                activity.setValue(downloadedActivity["activityData"]!.classForCoder == NSNull.classForCoder() ? "Null" : (downloadedActivity["activityData"] as! String), forKey: "activityData")
                activity.setValue(downloadedActivity["quiz"] as! String, forKey: "quiz")
                activity.setValue(downloadedActivity["classID"] as! String, forKey: "classID")
                
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
        if CurrentUser.currentUser().userType == .Student
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
        
        activityDataIsLoaded = true
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(ActivityDataLoaded, object: nil)
        }
    }
    
    @objc func activityForActivityID(activityID: String) -> Activity
    {
        let fetchRequest = NSFetchRequest(entityName: "Activity")
        fetchRequest.predicate = NSPredicate(format: "activityID==%@", activityID)
        let coreDataActivity = try! NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        let activity = coreDataActivity.first!
        
        return CESDatabaseActivityObject(managedObject: activity)
    }
}

private class CESDatabaseActivityObject : Activity
{
    var _activityID : Int!
    var _name : String!
    var _activityDescription : String!
    var _totalPoints : Int!
    var _releaseDate : NSDate!
    var _dueDate : NSDate!
    var _activityData : [[Int:AnyObject]]!
    var _quizMode : QuizMode!
    var _classID : Int!
    
    @objc var activityID : Int { get { return _activityID } }
    
    @objc var name : String { get { return _name } }
    
    @objc var activityDescription : String { get { return _activityDescription } }
    
    @objc var totalPoints : Int { get { return _totalPoints } }
    
    @objc var releaseDate : NSDate { get { return _releaseDate } }
    
    @objc var dueDate : NSDate { get { return _dueDate } }
    
    @objc var activityData : [[Int:AnyObject]]? { get { return _activityData } }
    
    @objc var quizMode : QuizMode { get { return _quizMode } }
    
    @objc var classID : Int { get { return _classID } }
    
    private init(managedObject: NSManagedObject)
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        _activityID = Int(managedObject.valueForKey("activityID") as! String)!
        _name = managedObject.valueForKey("name") as! String
        _activityDescription = managedObject.valueForKey("activityDescription") as! String
        _totalPoints = Int(managedObject.valueForKey("totalPoints") as! String)!
        _releaseDate = dateFormatter.dateFromString(managedObject.valueForKey("releaseDate") as! String)
        _dueDate = dateFormatter.dateFromString(managedObject.valueForKey("dueDate") as! String)
        
        _activityData = NADatabase.sharedDatabase().decryptObject(managedObject.valueForKey("activityData") as? String ?? "") as? [[Int:AnyObject]] ?? nil
        
        _quizMode = QuizMode(rawValue: Int(managedObject.valueForKey("quiz") as! String)!)
        _classID = Int(managedObject.valueForKey("classID") as! String)!
    }
}

private class CESDatabaseActivitySessionObject : ActivitySession
{
    var _activitySessionID : Int!
    @objc var activitySessionID : Int { get { return _activitySessionID ?? -1 } }
    
    var _activityID : Int!
    @objc var activityID : Int { get { return _activityID } }
    
    @objc var grade : Double
    
    @objc var activityData : [[Int:AnyObject]]?
    
    @objc var startDate : NSDate
    
    @objc var endDate : NSDate?
    
    @objc var status : ActivitySessionStatus
    
    private init(activitySessionID: Int?, activityID: Int, grade: Double, activityData: [[Int:AnyObject]], startDate: NSDate, endDate: NSDate?, status: ActivitySessionStatus)
    {
        _activitySessionID = activitySessionID
        _activityID = activityID
        self.grade = grade
        self.activityData = activityData
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
    }
}