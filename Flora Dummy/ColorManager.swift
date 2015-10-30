//
//  ColorManager.swift
//  FloraDummy
//
//  Created by Michael Schloss on 2/8/15.
//  Copyright (c) 2015 SGSC. All rights reserved.
//

import UIKit
import CoreData

private var colorInstance : ColorScheme!
class ColorScheme : NSObject
{
    private var currentColor: NSManagedObject!
    
    var primaryColor : UIColor
        {
        get
        {
            return UIColor(hexString: currentColor.valueForKey("primaryColor") as! String)
        }
    }
    
    var secondaryColor : UIColor
        {
        get
        {
            return UIColor(hexString: currentColor.valueForKey("secondaryColor") as! String)
        }
    }
    
    var backgroundColor : UIColor
        {
        get
        {
            return UIColor(hexString: currentColor.valueForKey("backgroundColor") as! String)
        }
    }
    
    class func currentColorScheme() -> ColorScheme
    {
        guard colorInstance != nil else { colorInstance = ColorScheme(); return colorInstance}
        return colorInstance
    }
    
    func loadCurrentColor()
    {
        guard let results = (try? NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "CurrentColor")) as! [NSManagedObject]) ?? (try? NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "Color")) as! [NSManagedObject]) else
        {
            let defaultColor = NSManagedObject(entity: NSEntityDescription.entityForName("Color", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!, insertIntoManagedObjectContext: nil)
            defaultColor.setValue("FFFFFF", forKey: "primaryColor")
            defaultColor.setValue("888888", forKey: "secondaryColor")
            defaultColor.setValue("333333", forKey: "backgroundColor")
            currentColor = defaultColor
            return
        }
        guard results.count != 0 else
        {
            let defaultColor = NSManagedObject(entity: NSEntityDescription.entityForName("Color", inManagedObjectContext: NADatabase.sharedDatabase().managedObjectContext)!, insertIntoManagedObjectContext: nil)
            defaultColor.setValue("FFFFFF", forKey: "primaryColor")
            defaultColor.setValue("888888", forKey: "secondaryColor")
            defaultColor.setValue("333333", forKey: "backgroundColor")
            currentColor = defaultColor
            return
        }
        currentColor = results.first!
    }
}
