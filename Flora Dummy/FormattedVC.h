//
//  FormattedVC.h
//  Flora Dummy
//
//  Created by Zach Nichols on 2/15/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageManager;
@protocol CESActivityManager;

@interface FormattedVC : UIViewController
{
    BOOL isPresented;
}

///Variable used to show whether VC in being loaded in the Table Of Contents versus the
@property (nonatomic) BOOL renderingView;
@property (nonatomic, weak) NSObject<CESActivityManager> * _Nullable activityManager;

@property (nonatomic, strong) PageManager * _Nullable pageManager __deprecated;

/// Updates colors in view
///
/// Subclasses should override this method to perform custom color updating
- (void) updateColors NS_REQUIRES_SUPER DEPRECATED_MSG_ATTRIBUTE("User can not update colors while in an activity");

///Restores the activity's state.\n This method should process the received object, update the ViewController's display, and then call the notification \p'PageManagerShouldContinuePresentation'
///\param object The object given to the activity that was returned after a call to \p'saveActivityState'
- (void) restoreActivityState:(nonnull id)object;

///Saves the activity's state.  This method should process all settings and user-entered data into an object.
///\returns An object of type \p(id) -- \p(AnyObject) in Swift -- that contains the necessary information to be able to restore the activity's state.
- (nonnull id) saveActivityState;

///The settings for the specific activity.  This method should return a dictionary in the ["Setting Name":"Setting Type"] format.  Supported Setting Types are:
///
/// \p String
///
/// \p Boolean
///
/// \p Integer OR \p NSInteger
///
/// \p Double OR \p Float OR \p CGFloat
///
/// \p Rect
///
/// \p Point
///
/// \p Picker - X, X[, X ...] (Each X is a picker option)
- (NSDictionary  * _Nonnull) settings;

@end
