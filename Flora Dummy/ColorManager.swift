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
            if currentColor != nil
            {
            return UIColor(hexString: currentColor.valueForKey("primaryColor") as! String)
            }
            return UIColor(hexString: "FFFFFF")
        }
    }
    
    var secondaryColor : UIColor
        {
        get
        {
            if currentColor != nil
            {
            return UIColor(hexString: currentColor.valueForKey("secondaryColor") as! String)
            }
            return UIColor(hexString: "888888")
        }
    }
    
    var backgroundColor : UIColor
        {
        get
        {
            if currentColor != nil
            {
            return UIColor(hexString: currentColor.valueForKey("backgroundColor") as! String)
            }
            return UIColor(hexString: "333333")
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
            return
        }
        guard results.count != 0 else
        {
            return
        }
        currentColor = results.first!
    }
}
