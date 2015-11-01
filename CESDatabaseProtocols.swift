//
//  CESDatabaseProtocols.swift
//  FloraDummy
//
//  Created by Michael Schloss on 1/21/15.
//  Copyright (c) 2015 SGSC. All rights reserved.
//

//--These are the protocols for the CESComet--\\

import Foundation
import UIKit

enum CESDatabaseError : ErrorType
{
    case NoActivitySessionForActivityID
}

@objc protocol ActivityCreation
{
    /**
     The settings for the activity, returned in an NSDictionary
     
     When returning the settings, please format the dictionary as such:
     * Key: SettingName
     * Value: Setting Type
     
     (i.e.) [NSDictionary dictionaryWithObjectsAndKeys:"BOOL", "Should Present Horizontally", "String", "Text For Introduction", nil]
     */
    func settingsForActivity() -> NSDictionary
}

@objc protocol CESActivityManager
{
    var margins : UIEdgeInsets { get }
    var currentActivity: Activity! { get set }
    
    func frameForType(frameType: FrameType) -> CGRect
}

@objc protocol CESDatabaseActivity
{
    /**
     The reference to the PageManager instance that is holding your activity.
     */
    @available(*, deprecated=9.0, message="PageManager is deprecated.  Use `activityManager` instead.")
    var pageManager: PageManager? { get set }
    
    /**
     The reference to the ActivityManager instance that is holding your activity.
     */
    var activityManager: CESActivityManager? { get set }
    
    ///Variable used to show whether VC in being loaded in the Table Of Contents versus the current Activity
    var renderingView : RenderingView { get set }
    
    /**
     Saves the Activity's state.  Any user inputted data, taps, and movements (if necessary) should be saved into an object of your choice
     
     This method is optional to implement
     
     - returns: An copy of an object the activity used to store its information
     */
    optional func saveActivityState() -> AnyObject
    
    /**
     Restores the activity's state to what the user last left it as.  Any changes should be decoded from 'object' and updated on screen.
     
     This method is optional to implement
     
     - parameter object: The object given in `saveActivityState`.
     */
    optional func restoreActivityState(object: AnyObject)
    
    ///The settings for the specific activity.  This method should return a dictionary in the ["Setting Name":"Setting Type"] format.  Supported Setting Types are:
    ///- `String`
    ///- `Boolean`
    ///- `Integer` OR `NSInteger`
    ///- `Double` OR `Float` OR `CGFloat`
    ///- `Rect`
    ///- `Point`
    ///- `Picker - X, X[, X ...]` (Each X is a picker option)
    optional func settings() -> NSDictionary
    
    /**
     When your Activity is about to be presented, this method is called to determine the size of the activity on screen.  By default, PageManager resizes each Activity to wrap inbetween buttons onscreen.  If `true` is returned from this method, the Activity is then sized to the full screen of the device, with the navigation buttons overlayed on top.
     */
    func activityWantsFullScreen() -> Bool
}

@objc protocol ActivityManagerVCDatabase
{
    func activitySessionForActivity(activity: Activity) -> ActivitySession
    func uploadActivitySession(activitySession: ActivitySession, completion: ((uploadSuccess: Bool) -> Void))
}

@objc protocol ActivityCreationDatabase
{
    func uploadNewActivity(activity: Activity, completion: ((activityID: String?) -> Void))
}

@objc protocol UserAccountsDatabase
{
    func inputtedUsernameIsValid(user: String?, andPassword pass: String?, completion: (Bool) -> Void)
    
    func downloadUserInformationForUser(user: String?, andPassword pass: String?, completion: (Bool) -> Void)
}

@objc protocol MainActivitiesDatabase
{
    var activityDataIsLoaded : Bool { get set }
    
    func loadUserActivities()
    
    func activityForActivityID(activityID: String) -> Activity
}
