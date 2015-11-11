//
//  HomeVC.swift
//  Flora Dummy
//
//  Created by Michael Schloss on 10/25/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

import UIKit

class HomeVC: FormattedVC//, NewsFeedDelegate
{
    @IBOutlet private var titleLabel : CESOutlinedLabel!
        {
        didSet
        {
            titleLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        }
    }
    
    @IBOutlet private var languageArts : HomeButton!
        {
        didSet
        {
            languageArts.actionHandler = { [unowned self] in
                self.performSegueWithIdentifier("languageArts", sender: self)
            }
        }
    }
    @IBOutlet private var math : HomeButton!
        {
        didSet
        {
            math.actionHandler = { [unowned self] in
                self.performSegueWithIdentifier("math", sender: self)
            }
        }
    }
    @IBOutlet private var history : HomeButton!
        {
        didSet
        {
            history.actionHandler = { [unowned self] in
                self.performSegueWithIdentifier("history", sender: self)
            }
        }
    }
    @IBOutlet private var science : HomeButton!
        {
        didSet
        {
            science.actionHandler = { [unowned self] in
                self.performSegueWithIdentifier("science", sender: self)
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = ColorScheme.currentColorScheme().backgroundColor
        
        if CurrentUser.hasSavedUserInformation()
        {
            CurrentUser.currentUser().loadSavedUser()
            dispatch_async(dispatch_queue_create("Activity Loading Queue", nil)) { () -> Void in
                CESDatabase.databaseManagerForMainActivitiesClass().loadUserActivities()
            }
        }
        
        var statusBarViewBackgroundColor : UIColor
        if ColorScheme.currentColorScheme().backgroundColor.lighter == UIColor.whiteColor() || ColorScheme.currentColorScheme().backgroundColor.lighter == UIColor.clearColor()
        {
            statusBarViewBackgroundColor = ColorScheme.currentColorScheme().backgroundColor.darker
        }
        else
        {
            statusBarViewBackgroundColor = ColorScheme.currentColorScheme().backgroundColor.lighter
        }
        
        let statusBarView = UIView()
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        statusBarView.backgroundColor = statusBarViewBackgroundColor
        view.addSubview(statusBarView)
        view.addConstraint(NSLayoutConstraint(item: statusBarView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: statusBarView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: statusBarView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[statusBarView(20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["statusBarView":statusBarView]))
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if CurrentUser.hasSavedUserInformation() == false
        {
            performSegueWithIdentifier("loginScreen", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        guard let subjectSegue = segue as? CESSubjectSegue else { return }
        
        switch subjectSegue.identifier!
        {
        case "languageArts":
            subjectSegue.sourceRect = languageArts.iconRect
            subjectSegue.sourceView = languageArts
            
        case "history":
            subjectSegue.sourceRect = history.iconRect
            subjectSegue.sourceView = history
            
        case "math":
            subjectSegue.sourceRect = math.iconRect
            subjectSegue.sourceView = math
            
        case "science":
            subjectSegue.sourceRect = science.iconRect
            subjectSegue.sourceView = science
            
        default: break
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        if ColorScheme.currentColorScheme().backgroundColor.lighter == UIColor.whiteColor() || ColorScheme.currentColorScheme().backgroundColor.lighter == UIColor.clearColor()
        {
            if ColorScheme.currentColorScheme().backgroundColor.darker.shouldUseWhiteText == true
            {
                return .LightContent
            }
            else
            {
                return .Default
            }
        }
        else
        {
            if ColorScheme.currentColorScheme().backgroundColor.lighter.shouldUseWhiteText == true
            {
                return .LightContent
            }
            else
            {
                return .Default
            }
        }
    }
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue)
    {
        //This method is purposefully blank
    }
}
