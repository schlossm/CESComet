//
//  AppDelegate.swift
//  Flora Dummy
//
//  Created by Michael Schloss on 10/25/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIViewControllerTransitioningDelegate
{
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
        let userDefaults : [String : AnyObject] = ["calculatorPosition":"Left", "showsDevTab":true]
        NSUserDefaults.standardUserDefaults().registerDefaults(userDefaults)
        
        ColorScheme.currentColorScheme().loadCurrentColor()
        
        return true
    }
}
