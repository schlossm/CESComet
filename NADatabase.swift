//
//  NADatabase.swift
//  NicholsApp
//
//  Created by Michael Schloss on 6/27/15.
//  Copyright © 2015 Michael Schloss. All rights reserved.
//

import UIKit
import CoreData

private var NADatabaseInstance : NADatabase!

public class NADatabase: NSObject
{
    internal var dataDownloader : NADataDownloader
    internal var dataUploader : NADataUploader
    
    internal static let websiteUserName = "CESComet"
    internal static let websiteUserPass = "7AZ-hSz-X7p-HGB"
    
    internal static let databaseUserPass = "7AZ-hSz-X7p-HGB"
    
    internal static let website = "http://cescomet.michaelschlosstech.com"
    internal static let readFile = "appdatabase.php"
    internal static let writeFile = "uploaddatabase.php"
    
    internal var naCoreDataStack = NACoreDataStack()
    
    internal let managedObjectContext : NSManagedObjectContext!
    
    var networkActivityIndicatorManager = NANetworkActivityIndicatorManager()
    
    override init()
    {
        managedObjectContext = naCoreDataStack.managedObjectContext
        
        dataDownloader = NADataDownloader()
        dataUploader = NADataUploader()
    }
    
    class func sharedDatabase() -> NADatabase
    {
        if NADatabaseInstance == nil
        {
            NADatabaseInstance = NADatabase()
        }
        
        return NADatabaseInstance
    }
    
    func keyValuePairIsNewForEntity(entity: String, keyValuePair: (key: String, value: String)) -> Bool
    {
        let request = NSFetchRequest(entityName: entity)
        request.predicate = NSPredicate(format: "\(keyValuePair.key) ==[c] %@", keyValuePair.value)
        
        let results = try! managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
        
        return results.isEmpty
    }
}

//MARK: - Object Encrypt/Decrypt

extension NADatabase
{
    func decryptString(encryptedString: String) -> String
    {
        let data = try! NSData().dataFromHexString(encryptedString).decryptedAES256DataUsingKey(")UdU@!:)S*)h\\.3K0R8I")
        return NSString(data: data, encoding: NSASCIIStringEncoding)! as String
    }
    
    func encryptString(decryptedString: String) -> String
    {
        let data = try! decryptedString.dataUsingEncoding(NSASCIIStringEncoding)!.AES256EncryptedDataUsingKey(")UdU@!:)S*)h\\.3K0R8I")
        return data.hexRepresentationWithSpaces(false, capitals: false)
    }
    
    func encryptObject(decryptedObject: AnyObject) -> String
    {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(decryptedObject, forKey: "object")
        archiver.finishEncoding()
        
        let encryptedData = try! data.AES256EncryptedDataUsingKey(")UdU@!:)S*)h\\.3K0R8I")
        return encryptedData.hexRepresentationWithSpaces(false, capitals: false)
    }
    
    func decryptObject(encryptedString: String) -> AnyObject?
    {
        guard let data = try? NSData().dataFromHexString(encryptedString).decryptedAES256DataUsingKey(")UdU@!:)S*)h\\.3K0R8I") else { return nil }
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        let object = unarchiver.decodeObjectForKey("object")
        unarchiver.finishDecoding()
        return object
    }
}

//HSS Notifications
extension NADatabase
{
    internal var HSSMatchInformationDownloadedNotification : String
        {
        get
        {
            return "Schedule Data Was Downloaded"
        }
    }
    
    internal var HSSRosterInformationDownloadedNotification : String
        {
        get
        {
            return "Scores Data Was Downloaded"
        }
    }
    
    internal var HSSSportInformationDownloadedNotification : String
        {
        get
        {
            return "Sports Data Was Downloaded"
        }
    }
    
    internal var HSSInitialInformationDownloadedNotification : String
        {
        get
        {
            return "Initial Data Was Downloaded"
        }
    }
    
    internal var HSSInternalDataDownloadErrorNotification : String
        {
        get
        {
            return "internal Error Downloading Data"
        }
    }
}

//MARK: - Clear Core Data
extension NADatabase
{
    func clearAllCoreData()
    {
        let entities = ["Athlete", "Admin", "Coach", "LoggedInUser", "BodyWeight", "Class", "Sport", "School", "Color", "Lift"]
        
        for entity in entities
        {
            let fetchRequest = NSFetchRequest(entityName: entity)
            do
            {
                let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
                
                for object in fetchResults
                {
                    managedObjectContext.deleteObject(object)
                    try! managedObjectContext.save()
                }
            }
            catch
            {
                
            }
        }
    }
}

extension NADatabase
{
    //MARK: - Other
    
    func retrieveListOfProperty(property: String, onEntity entity: String) -> [AnyObject]
    {
        let fetchRequest = NSFetchRequest(entityName: entity)
        let fetchResults = try! managedObjectContext.executeFetchRequest(fetchRequest)
        
        var list = [AnyObject]()
        for fetchResult in fetchResults as! [NSManagedObject]
        {
            if fetchResult.valueForKey(property) != nil
            {
                list.append(fetchResult.valueForKey(property)!)
            }
            else
            {
                list.append("")
            }
        }
        
        return list
    }
}

func saveCoreData() throws
{
    try NADatabase.sharedDatabase().managedObjectContext.save()
}
