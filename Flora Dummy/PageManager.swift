//
//  PageManager.swift
//  FloraDummy
//
//  Created by Michael Schloss on 1/9/15.
//  Copyright (c) 2015 SGSC. All rights reserved.
//

import UIKit

@objc enum PageManagerDirection : Int
{
    case Forward, Backward
}

@available(*, deprecated=9.0, message="PageManager is deprecated.  Use 'ActivityManagerVC' class instead.")
class PageManager: FormattedVC
{
    private var databaseManager = CESDatabase.databaseManagerForPageManagerClass()
    
    private var previousButton : UIButton_Typical!
    private var nextButton : UIButton_Typical!
    private var saveButton : UIButton_Typical!
    
    var canGoForward : Bool
        {
        get
        {
            return nextButton.userInteractionEnabled
        }
        set
        {
            self.nextButton.userInteractionEnabled = newValue
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: .AllowUserInteraction, animations: { () -> Void in
                
                switch newValue
                {
                case false:
                    self.nextButton.alpha = 0.0
                    break
                    
                case true:
                    self.nextButton.alpha = 1.0
                }
                }, completion: nil)
        }
    }
    
    var previousButtonFrame : CGRect
        {
        get
        {
            return previousButton.frame
        }
    }
    var saveButtonFrame : CGRect
        {
        get
        {
            return saveButton.frame
        }
    }
    var nextButtonFrame : CGRect
        {
        get
        {
            return nextButton.frame
        }
    }
    
    var topMargin : CGFloat
        {
        get
        {
            return exitButton.frame.size.height + exitButton.frame.origin.y + 8.0
        }
    }
    
    var bottomMargin : CGFloat
        {
        get
        {
            return topMargin
        }
    }
    var leftMargin : CGFloat
        {
        get
        {
            return previousButton.frame.origin.x + previousButton.frame.size.width + 8.0
        }
    }
    var rightMargin : CGFloat
        {
        get
        {
            return leftMargin
        }
    }
    
    private var pageNumberLabel : CESOutlinedLabel!
    
    //Button Constraints
    lazy private var previousButtonConstraints = [NSLayoutConstraint]()
    lazy private var saveButtonConstraints = [NSLayoutConstraint]()
    lazy private var nextButtonConstraints = [NSLayoutConstraint]()
    
    //Current Index
    private var currentIndex = -1
    private var oldIndex = -1
    
    //Current Activity (Session) Information
    var currentActivity : Activity!
    
    private var currentActivitySession : ActivitySession!
    private var activityID : Int
        {
        get
        {
            return currentActivitySession.activityID
        }
    }
    
    private var isPresented : Bool
        {
        get
        {
            return presentingViewController != nil
        }
    }
    private var newActivityData = [[NSNumber:AnyObject]]()
    
    //Transition Direction
    private var direction = "Forward" //PageManagerDirection.Forward
    
    //View Controllers On Screen
    private var oldViewController : CESDatabaseActivity?
    private var currentViewController : CESDatabaseActivity!
    
    //View Controllers On Screen Constraints
    private var oldViewControllerConstraints = [NSLayoutConstraint]()
    private var currentViewControllerConstraints = [NSLayoutConstraint]()
    
    //The Subject that presented this Page Manager instance
    var subjectParent : UIViewController!
    
    //Exit and Table of Contents Buttons
    private var exitButton : UIButton_Typical!
    private var TOCButton : UIButton_Typical!
    
    //Table Of Contents
    private var tableOfContentsImages = [UIImage]()
    private var tableOfContentsView : UIScrollView!
    private var tableOfContentsImageViews = [CESCometUIImageView]()
    
    private var lastVisibleIndex = -1
    private var selectedImageView : CESCometUIImageView!
    
    private var isInTOC = false
    
    /*
    //MARK: - View Setup
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, activitySession: ActivitySession, forActivity activity: Activity, withParent parent: UIViewController)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        subjectParent = parent
        currentActivitySession = activitySession
        currentActivity = activity
        
        let introVC = Page_IntroVC(nibName: "Page_IntroVC", bundle: nil)
        introVC.pageManager = self
        introVC.activityTitle = activity.name
        introVC.summary = activity.activityDescription
        
        currentViewController = introVC
        continueWithPresentation()
        
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            weakSelf?.setUpTOC()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        previousButton = UIButton_Typical(frame: CGRectZero)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.setTitle("Back", forState: .Normal)
        previousButton.titleLabel!.font = UIFont(name: "MarkerFelt-Thin", size: 36)
        previousButton.addTarget(self, action: "goBackOnePage:", forControlEvents: .TouchUpInside)
        previousButton.userInteractionEnabled = false
        previousButton.backgroundColor = view.backgroundColor
        previousButton.layer.shadowColor = view.backgroundColor!.CGColor
        previousButton.layer.shadowOpacity = 1.0
        view.addSubview(previousButton)
        
        nextButton = UIButton_Typical(frame: CGRectZero)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", forState: .Normal)
        nextButton.titleLabel!.font = UIFont(name: "MarkerFelt-Thin", size: 36)
        nextButton.addTarget(self, action: "goForwardOnePage:", forControlEvents: .TouchUpInside)
        nextButton.userInteractionEnabled = false
        nextButton.backgroundColor = view.backgroundColor
        nextButton.layer.shadowColor = view.backgroundColor!.CGColor
        nextButton.layer.shadowOpacity = 1.0
        view.addSubview(nextButton)
        
        saveButton = UIButton_Typical(frame: CGRectZero)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", forState: .Normal)
        saveButton.titleLabel!.font = UIFont(name: "MarkerFelt-Thin", size: 36)
        saveButton.addTarget(self, action: "saveActivity:", forControlEvents: .TouchUpInside)
        saveButton.backgroundColor = view.backgroundColor
        saveButton.layer.shadowColor = view.backgroundColor!.CGColor
        saveButton.layer.shadowOpacity = 1.0
        view.addSubview(saveButton)
        
        exitButton = UIButton_Typical(frame: CGRectMake(20, 40, 75, 50))
        exitButton.setTitle("Exit", forState: .Normal)
        exitButton.titleLabel!.font = UIFont(name: "MarkerFelt-Thin", size: 32)
        exitButton.addTarget(self, action: "exitActivity:", forControlEvents: .TouchUpInside)
        exitButton.backgroundColor = view.backgroundColor
        exitButton.layer.shadowColor = view.backgroundColor!.CGColor
        exitButton.layer.shadowOpacity = 1.0
        view.addSubview(exitButton)
        
        TOCButton = UIButton_Typical(frame: CGRectMake(20, 40, 75, 50))
        TOCButton.setTitle("⊞", forState: .Normal)
        TOCButton.titleLabel!.font = UIFont(name: "MarkerFelt-Thin", size: 38)
        TOCButton.addTarget(self, action: "tableOfContents:", forControlEvents: .TouchUpInside)
        TOCButton.center = CGPointMake(view.frame.size.width - 20 - TOCButton.frame.size.width/2.0, 40 + TOCButton.frame.size.height/2.0)
        TOCButton.backgroundColor = view.backgroundColor
        TOCButton.layer.shadowColor = view.backgroundColor!.CGColor
        TOCButton.layer.shadowOpacity = 1.0
        view.addSubview(TOCButton)
        
        setUpButtons()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "continueWithPresentation", name: PageManagerShouldContinuePresentation, object: nil)
    }
    
    ///Disables saving the Activity's Session to the database
    func enablePreviewMode()
    {
        saveButton.hidden = true
    }
    
    private func setUpButtons()
    {
        view.removeConstraints(previousButtonConstraints)
        view.removeConstraints(nextButtonConstraints)
        view.removeConstraints(saveButtonConstraints)
        
        previousButtonConstraints = [NSLayoutConstraint]()
        saveButtonConstraints = [NSLayoutConstraint]()
        nextButtonConstraints = [NSLayoutConstraint]()
        
        if currentIndex == currentActivitySession.activityData.count - 1 //Final Page
        {
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: -10.0))
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
            
            saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 10.0))
            saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
            saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
            saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
            
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: -8.0))
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
            
            view.addConstraints(previousButtonConstraints)
            view.addConstraints(saveButtonConstraints)
            view.addConstraints(nextButtonConstraints)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                self.view.layoutIfNeeded()
                
                self.previousButton.alpha = 1.0
                self.previousButton.userInteractionEnabled = true
                self.nextButton.alpha = 0.0
                self.nextButton.userInteractionEnabled = false
                }, completion: nil)
            
            UIView.transitionWithView(saveButton, duration: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                self.saveButton.setTitle("Finish", forState: .Normal)
                
                self.saveButton.alpha = 1.0
                self.saveButton.userInteractionEnabled = true
                }, completion: nil)
        }
        else if currentIndex == -1    //First Page
        {
            var shouldShowSaveButton = false
            var dataIsSame = true
            
            if currentActivitySession.activityData.count > 0 && newActivityData.count > 0
            {
                for index in 0...newActivityData.count - 1
                {
                    let newActivityDataDict = newActivityData[index] as NSDictionary
                    let currentActivityDataDict = currentActivitySession.activityData[index] as NSDictionary
                    
                    if newActivityDataDict.isEqualToDictionary(currentActivityDataDict as [NSObject : AnyObject]) == false
                    {
                        dataIsSame = false
                        break
                    }
                }
            }
            
            if newActivityData.count > 0 && dataIsSame == false
            {
                shouldShowSaveButton = true
            }
            
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 8.0))
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
            
            if (shouldShowSaveButton)
            {
                saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: -10.0))
                saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
                saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
                saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
                
                nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 10.0))
            }
            else
            {
                saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
                saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
                saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
                saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
                
                nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            }
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
            
            view.addConstraints(previousButtonConstraints)
            view.addConstraints(saveButtonConstraints)
            view.addConstraints(nextButtonConstraints)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.nextButton.alpha = 1.0
                self.nextButton.userInteractionEnabled = true
                self.previousButton.alpha = 0.0
                self.previousButton.userInteractionEnabled = false
                }, completion: nil)
            
            UIView.transitionWithView(saveButton, duration: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                self.saveButton.setTitle("Save", forState: .Normal)
                if shouldShowSaveButton == false
                {
                    self.saveButton.alpha = 0.0
                    self.saveButton.userInteractionEnabled = false
                }
                else
                {
                    self.saveButton.alpha = 1.0
                    self.saveButton.userInteractionEnabled = true
                }
                }, completion: nil)
        }
        else    //Middle Page
        {
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 8.0))
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
            previousButtonConstraints.append(NSLayoutConstraint(item: previousButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
            
            saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
            saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
            saveButtonConstraints.append(NSLayoutConstraint(item: saveButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
            
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: -8.0))
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -8.0))
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.1, constant: 0.0))
            nextButtonConstraints.append(NSLayoutConstraint(item: nextButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.1, constant: 0.0))
            
            view.addConstraints(previousButtonConstraints)
            view.addConstraints(saveButtonConstraints)
            view.addConstraints(nextButtonConstraints)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                self.view.layoutIfNeeded()
                
                self.nextButton.alpha = 1.0
                self.nextButton.userInteractionEnabled = true
                self.previousButton.alpha = 1.0
                self.previousButton.userInteractionEnabled = true
                }, completion: nil)
            
            UIView.transitionWithView(saveButton, duration: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                self.saveButton.setTitle("Save", forState: .Normal)
                self.saveButton.alpha = 1.0
                self.saveButton.userInteractionEnabled = true
                }, completion: nil)
        }
    }
    
    private func displayDismissAlert(customMessage: String?)
    {
        var dismissAlert : UIAlertController
        
        if customMessage != nil
        {
            dismissAlert = UIAlertController(title: customMessage!.componentsSeparatedByString("|")[0], message: customMessage!.componentsSeparatedByString("|")[1], preferredStyle: .Alert)
        }
        else
        {
            dismissAlert = UIAlertController(title: "We're Sorry", message: "There's been an issue starting this activity\n\nPlease contact your teacher for assistance", preferredStyle: .Alert)
        }
        
        dismissAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(dismissAlert, animated: true, completion: nil)
    }
    
    func exitActivity(button: UIButton_Typical)
    {
        let dismissAlert = UIAlertController(title: "Are you sure?", message: "Do you want to leave the activity?\n\nAny work you have done will be lost!", preferredStyle: .Alert)
        
        dismissAlert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        dismissAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
        
        presentViewController(dismissAlert, animated: true, completion: nil)
    }
    
    //MARK: - Table Of Contents
    
    private func updateCurrentViewControllerImage()
    {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        currentViewController.view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tableOfContentsImages[currentIndex + 1] = copied
    }
    
    private func setUpTOC()
    {
        let introVC = Page_IntroVC(nibName: "Page_IntroVC", bundle: nil)
        introVC.pageManager = self
        introVC.activityTitle = currentActivity.name
        introVC.summary = currentActivity.activityDescription
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        introVC.view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tableOfContentsImages.append(copied)
        
        for index in 0...(currentActivitySession.activityData.count - 1)
        {
            //Get the new activity's type
            let currentActivityPage = currentActivitySession.activityData[index]
            let currentActivityType = Array(currentActivityPage.keys)[0]
            
            //Initialize the new activity
            let viewControllerToRender = viewControllerForPageType(ActivityViewControllerType(rawValue: currentActivityType.integerValue)!)!
            viewControllerToRender.pageManager = self
            viewControllerToRender.renderingView = true
            
            if newActivityData.count > index
            {
                let object : AnyObject = Array(newActivityData[index].values)[0]
                
                if object as! String != "<null>"
                {
                    viewControllerToRender.restoreActivityState?(Array(newActivityData[index].values)[0])
                }
                else
                {
                    viewControllerToRender.restoreActivityState?(Array(currentActivityPage.values)[0])
                }
            }
            else    //There isn't any saved session data for this activity, so load the old session data
            {
                viewControllerToRender.restoreActivityState?(Array(currentActivityPage.values)[0])
            }
            
            UIView.transitionWithView((viewControllerToRender as! UIViewController).view, duration: 0.0, options: .AllowUserInteraction, animations: { () -> Void in (viewControllerToRender as! UIViewController).view.layoutIfNeeded() }, completion: { (finished) -> Void in
                
                UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0)
                (viewControllerToRender as! UIViewController).view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
                let copied = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                self.tableOfContentsImages.append(copied)
                
            })
        }
    }
    
    func tableOfContents(button: UIButton_Typical)
    {
        button.userInteractionEnabled = false
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        setNeedsStatusBarAppearanceUpdate()
        
        //Update live image
        updateCurrentViewControllerImage()
        
        let numberOfScreensPerRow = 4.0
        let aspectRatio = 1024.0/768.0
        let bufferY = 47.0
        let bufferX = 47.0
        
        var posX = CGFloat(bufferY)
        var posY = CGFloat(bufferX)
        
        tableOfContentsView = UIScrollView(frame: view.bounds)
        tableOfContentsView.alpha = 0.0
        tableOfContentsView.backgroundColor = .clearColor()
        tableOfContentsView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        tableOfContentsView.alwaysBounceHorizontal = false
        tableOfContentsView.userInteractionEnabled = false
        
        let twoFingerDismiss = UIPanGestureRecognizer(target: self, action: "handlePan:")
        twoFingerDismiss.minimumNumberOfTouches = 2
        twoFingerDismiss.maximumNumberOfTouches = 2
        tableOfContentsView.addGestureRecognizer(twoFingerDismiss)
        
        view.addSubview(tableOfContentsView)
        
        let width = CGFloat((Double(view.bounds.width) - Double(Double(bufferX * numberOfScreensPerRow) + 2.0))/numberOfScreensPerRow)
        
        for index in 0...tableOfContentsImages.count - 1
        {
            let imageView = CESCometUIImageView(frame: CGRectMake(posX, posY, width, CGFloat(Double(width)/aspectRatio)))
            imageView.setImage(tableOfContentsImages[index])
            imageView.layer.cornerRadius = 10.0
            imageView.imageView.layer.cornerRadius = 10.0
            
            if index > 0 && index != currentIndex + 1 && index != lastVisibleIndex + 1 && currentActivity.quizMode == true
            {
                imageView.enableQuizMode()
            }
            
            imageView.setTarget(self, forAction: "tableOfContentsOptionWasSelected:")
            
            tableOfContentsView.addSubview(imageView)
            
            if (index + 1) % 5 == 0
            {
                posY += CGFloat(bufferY)
                posY += imageView.frame.size.height
                
                posX = CGFloat(bufferX)
            }
            else
            {
                posX += CGFloat(bufferX)
                posX += width
            }
            tableOfContentsView.contentSize = CGSizeMake(0, posY)
            
            tableOfContentsImageViews.append(imageView)
            
            let titleLabel = CESOutlinedLabel()
            titleLabel.textColor = .whiteColor()
            titleLabel.font = UIFont(name: "MarkerFelt-Thin", size: 22)
            if index == 0
            {
                titleLabel.text = "Introduction"
            }
            else
            {
                titleLabel.text = "Problem \(index)"
            }
            titleLabel.sizeToFit()
            titleLabel.center = CGPointMake(imageView.center.x, imageView.frame.origin.y - (CGFloat(bufferY) - titleLabel.frame.size.height)/3.0 - titleLabel.frame.size.height/2.0)
            tableOfContentsView.addSubview(titleLabel)
        }
        
        tableOfContentsView.scrollRectToVisible(self.tableOfContentsImageViews[self.currentIndex + 1].frame, animated: false)
        tableOfContentsView.bringSubviewToFront(self.tableOfContentsImageViews[self.currentIndex + 1])
        
        selectedImageView = tableOfContentsImageViews[currentIndex + 1]
        let oldFrame = tableOfContentsImageViews[currentIndex + 1].frame
        
        tableOfContentsImageViews[currentIndex + 1].layer.cornerRadius = 0.001
        tableOfContentsImageViews[currentIndex + 1].frame = CGRectMake(view.bounds.origin.x, view.bounds.origin.y - tableOfContentsView.contentInset.top, view.bounds.size.width, view.bounds.size.height)
        
        UIView.animateWithDuration(0.0, animations: { () -> Void in
            self.tableOfContentsImageViews[self.currentIndex + 1].layoutIfNeeded()
            }, completion: { (finished) -> Void in
                
                UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: .AllowAnimatedContent, animations: { () -> Void in
                    
                    self.tableOfContentsView.alpha = 1.0
                    
                    }, completion: { (finished) -> Void in
                        
                        let animation = CABasicAnimation(keyPath: "cornerRadius")
                        animation.fromValue = NSNumber(double: 0.001)
                        animation.toValue = NSNumber(double: 10.0)
                        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                        animation.duration = 0.3
                        self.tableOfContentsImageViews[self.currentIndex + 1].layer.addAnimation(animation, forKey: "cornerRadius")
                        self.tableOfContentsImageViews[self.currentIndex + 1].layer.cornerRadius = 10.0
                        self.tableOfContentsImageViews[self.currentIndex + 1].imageView.layer.addAnimation(animation.copy() as! CABasicAnimation, forKey: "cornerRadius")
                        self.tableOfContentsImageViews[self.currentIndex + 1].imageView.layer.cornerRadius = 10.0
                        self.tableOfContentsImageViews[self.currentIndex + 1].dimView.layer.addAnimation(animation.copy() as! CABasicAnimation, forKey: "cornerRadius")
                        self.tableOfContentsImageViews[self.currentIndex + 1].dimView.layer.cornerRadius = 10.0
                        
                        self.currentViewController.view.alpha = 0.0
                        self.tableOfContentsView.backgroundColor = .blackColor()
                        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: .AllowAnimatedContent, animations: { () -> Void in
                            
                            self.tableOfContentsImageViews[self.currentIndex + 1].frame = oldFrame
                            self.tableOfContentsImageViews[self.currentIndex + 1].layoutIfNeeded()
                            
                            }, completion: { (finished) -> Void in
                                self.tableOfContentsView.userInteractionEnabled = true
                        })
                })
        })
    }
    
    func tableOfContentsOptionWasSelected(timer: NSTimer)
    {
        selectedImageView = timer.userInfo!["ImageView"] as! CESCometUIImageView
        
        oldIndex = currentIndex
        
        currentIndex = (tableOfContentsImageViews as NSArray).indexOfObject(selectedImageView) - 1
        
        if oldIndex == -1
        {
            direction = "Forward"
        }
        else if oldIndex == currentIndex
        {
            direction = "Same"
        }
        else
        {
            direction = "Jump"
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideTableOfContents", name: PageManagerShouldContinuePresentation, object: nil)
        
        presentNextViewController()
    }
    
    func hideTableOfContents()
    {
        tableOfContentsView.userInteractionEnabled = false
        
        tableOfContentsView.bringSubviewToFront(selectedImageView)
        tableOfContentsView.removeGestureRecognizer(tableOfContentsView.gestureRecognizers![0] )
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        //Setup the new View behind the table of contents
        oldViewController?.removeFromParentViewController()
        oldViewController?.view.removeFromSuperview()
        view.removeConstraints(oldViewControllerConstraints)
        
        currentViewControllerConstraints = Array<NSLayoutConstraint>()
        
        currentViewController.willMoveToParentViewController(self)
        currentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentViewController.view)
        view.sendSubviewToBack(currentViewController.view)
        
        currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        
        view.addConstraints(currentViewControllerConstraints)
        
        currentViewController.didMoveToParentViewController(self)
        
        //Animate out the table of contents
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.fromValue = NSNumber(double: 10.0)
        animation.toValue = NSNumber(double: 0.001)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.duration = 0.3
        self.tableOfContentsImageViews[self.currentIndex + 1].layer.addAnimation(animation, forKey: "cornerRadius")
        self.tableOfContentsImageViews[self.currentIndex + 1].layer.cornerRadius = 0.001
        self.tableOfContentsImageViews[self.currentIndex + 1].imageView.layer.addAnimation(animation.copy() as! CABasicAnimation, forKey: "cornerRadius")
        self.tableOfContentsImageViews[self.currentIndex + 1].imageView.layer.cornerRadius = 0.001
        self.tableOfContentsImageViews[self.currentIndex + 1].dimView.layer.addAnimation(animation.copy() as! CABasicAnimation, forKey: "cornerRadius")
        self.tableOfContentsImageViews[self.currentIndex + 1].dimView.layer.cornerRadius = 0.001
        
        
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: [.AllowAnimatedContent, .AllowUserInteraction, .BeginFromCurrentState], animations: { () -> Void in
            
            self.selectedImageView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y - self.tableOfContentsView.contentInset.top, self.view.bounds.size.width, self.view.bounds.size.height)
            self.selectedImageView.layoutIfNeeded()
            
            self.setUpButtons()
            
            }, completion: { (finished) -> Void in
                
                UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                    
                    self.tableOfContentsView.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                        
                        self.tableOfContentsView.removeFromSuperview()
                        self.tableOfContentsImageViews = Array<CESCometUIImageView>()
                        
                        self.TOCButton.userInteractionEnabled = true
                })
        })
    }
    
    func handlePan(panGesture: UIPanGestureRecognizer)
    {
        switch panGesture.state
        {
        case .Changed:
            if panGesture.translationInView(tableOfContentsView).y > 100
            {
                panGesture.enabled = false
                NSTimer.scheduledTimerWithTimeInterval(0.0, target: self, selector: "tableOfContentsOptionWasSelected:", userInfo: ["ImageView":selectedImageView], repeats: false)
            }
            break
            
        default:
            break
        }
    }
    
    //MARK: - Page Movement
    
    func goBackOnePage(button: UIButton_Typical)
    {
        updateCurrentViewControllerImage()
        
        view.userInteractionEnabled = false
        oldIndex = currentIndex
        currentIndex--
        direction = "Backward"
        
        self.presentNextViewController()
    }
    
    func goForwardOnePage(button: UIButton_Typical)
    {
        updateCurrentViewControllerImage()
        
        view.userInteractionEnabled = false
        oldIndex = currentIndex
        currentIndex++
        direction = "Forward"
        
        self.presentNextViewController()
    }
    
    func saveActivity(button: UIButton_Typical)
    {
        view.userInteractionEnabled = false
        
        let savedObject: AnyObject? = currentViewController.saveActivityState()
        
        let currentActivityPage = currentActivitySession.activityData[currentIndex]
        let currentActivityType = Array(currentActivityPage.keys)[0]
        
        if newActivityData.count <= currentIndex
        {
            newActivityData.append(Dictionary<NSNumber, AnyObject>())
        }
        
        if savedObject == nil
        {
            newActivityData[currentIndex].updateValue("<null>", forKey: currentActivityType)
        }
        else //If the activity actually returned a saved object, save it
        {
            newActivityData[currentIndex].updateValue(savedObject!, forKey: currentActivityType)
        }
        
        //CHECKS FOR CURRENT ACTIVITY
        
        let currentActivitySessionCopy = currentActivitySession.copy() as! ActivitySession
        
        //Update the currentActivity values with the newActivityData values
        for index in 0...(newActivityData.count - 1)
        {
            currentActivitySessionCopy.activityData[index].updateValue(Array(newActivityData[index].values)[0], forKey: Array(currentActivitySessionCopy.activityData[index].keys)[0])
        }
        
        if button.titleLabel!.text == "Finish"  //We are actually finishing
        {
            currentActivitySessionCopy.endDate = NSDate()
            
            if currentActivitySessionCopy.endDate!.compare(currentActivity.dueDate) == .OrderedDescending
            {
                currentActivitySessionCopy.status = "Past Due"
            }
            else
            {
                currentActivitySessionCopy.status = "Finished"
            }
        }
        else
        {
            currentActivitySessionCopy.status = "Started"
        }
        
        let wheel = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        wheel.center = saveButton.center
        wheel.startAnimating()
        wheel.alpha = 0.0
        wheel.transform = CGAffineTransformMakeScale(1.3, 1.3)
        view.addSubview(wheel)
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: [.AllowUserInteraction, .AllowAnimatedContent], animations: { () -> Void in
            
            wheel.alpha = 1.0
            wheel.transform = CGAffineTransformIdentity
            
            self.nextButton.alpha = 0.0
            self.previousButton.alpha = 0.0
            self.saveButton.alpha = 0.0
            self.saveButton.transform = CGAffineTransformMakeScale(0.7, 0.7)
            
            }, completion: { (finished) -> Void in
                self.databaseManager.uploadActivitySession(currentActivitySessionCopy, completion: { (uploadSuccess) -> Void in
                    if uploadSuccess == true
                    {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else
                    {
                        self.setUpButtons()
                        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: [.AllowUserInteraction, .AllowAnimatedContent], animations: { () -> Void in
                            
                            wheel.alpha = 0.0
                            wheel.transform = CGAffineTransformMakeScale(1.3, 1.3)
                            
                            self.saveButton.transform = CGAffineTransformIdentity
                            
                            }, completion: { (finished) -> Void in
                                
                                self.view.userInteractionEnabled = true
                                
                                let errorAlert = UIAlertController(title: "We're Sorry", message: "There's been an issue saving this activity\n\nPlease contact your teacher for assistance and try again.", preferredStyle: .Alert)
                                errorAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                self.presentViewController(errorAlert, animated: true, completion: nil)
                        })
                    }
                })
        })
    }
    
    private func presentNextViewController()
    {
        guard direction != "Same" else
        {
            currentViewController.view.alpha = 1.0
            NSNotificationCenter.defaultCenter().postNotificationName(PageManagerShouldContinuePresentation, object: nil)
            return
        }
        
        //Move the viewController on screen to the oldViewController object
        oldViewController = currentViewController
        oldViewControllerConstraints = currentViewControllerConstraints
        
        let index = currentIndex
        
        if oldIndex != -1
        {
            guard let oldVC = oldViewController else
            {
                //TODO: Error
                return
            }
            //Get the oldActivity's type
            let oldActivityPage = currentActivitySession.activityData[oldIndex]
            let oldActivityType = Array(oldActivityPage.keys)[0]
            
            //Get the savedObject for the activity
            let savedObject = oldVC.saveActivityState()
            
            if newActivityData.count <= oldIndex
            {
                for _ in newActivityData.count...oldIndex
                {
                    newActivityData.append([NSNumber : AnyObject]())
                }
            }
            
            newActivityData[oldIndex].updateValue(savedObject, forKey: oldActivityType)
        }
        
        guard index != -1 else
        {
            let introVC = Page_IntroVC(nibName: "Page_IntroVC", bundle: nil)
            introVC.pageManager = self
            introVC.activityTitle = currentActivity.name
            introVC.summary = currentActivity.activityDescription
            
            currentViewController = introVC
            
            continueWithPresentation()
            return
        }
        
        //Get the new activity's type
        let currentActivityPage = currentActivitySession.activityData[currentIndex]
        let currentActivityType = Array(currentActivityPage.keys)[0]
        
        //Initialize the new activity
        currentViewController = viewControllerForPageType(ActivityViewControllerType(rawValue: currentActivityType.integerValue)!)
        currentViewController.pageManager = self
        
        currentViewController.view?.userInteractionEnabled = (currentActivitySession.status == "Started" || currentActivitySession.status == "Not Started")
        
        //Check if we have already saved data in the activity (i.e. the user is going backwards)
        if newActivityData.count > currentIndex
        {
            if newActivityData[currentIndex].isEmpty == false
            {
                currentViewController.restoreActivityState(Array(newActivityData[currentIndex].values)[0])
            }
            else
            {
                currentViewController.restoreActivityState(Array(currentActivityPage.values)[0])
            }
        }
        else
        {
            currentViewController.restoreActivityState(Array(currentActivityPage.values)[0])
        }
    }
    
    func continueWithPresentation()
    {
        guard currentViewController != nil else { return }
        
        if isPresented == false
        {
            currentViewController.willMoveToParentViewController(self)
            currentViewController.view.translatesAutoresizingMaskIntoConstraints = false
            currentViewController.updateColors()
            view.addSubview(currentViewController.view)
            view.sendSubviewToBack(currentViewController.view)
            
            currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
            currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
            currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
            
            view.addConstraints(currentViewControllerConstraints)
            
            currentViewController.didMoveToParentViewController(self)
            self.modalPresentationStyle = .Custom
            if subjectParent.classForCoder !== TestingTVC.classForCoder()
            {
                self.transitioningDelegate = (subjectParent as! SubjectVC)
            }
            subjectParent.presentViewController(self, animated: true, completion: nil)
        }
        else
        {
            setUpButtons()
            currentViewController.willMoveToParentViewController(self)
            currentViewController.view.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(currentViewController.view, aboveSubview: oldViewController!.view)
            view.sendSubviewToBack(currentViewController.view)
            
            currentViewControllerConstraints = Array<NSLayoutConstraint>()
            
            currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
            currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
            currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            currentViewControllerConstraints.append(NSLayoutConstraint(item: currentViewController.view, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
            
            view.addConstraints(currentViewControllerConstraints)
            
            currentViewController.didMoveToParentViewController(self)
            
            switch direction
            {
            case "Forward":
                currentViewController.view.transform = CGAffineTransformMakeTranslation(view.frame.size.width, 0.0)
                break
                
            case "Backward":
                currentViewController.view.transform = CGAffineTransformMakeTranslation(-view.frame.size.width, 0.0)
                break
                
            default:
                currentViewController.view.transform = CGAffineTransformMakeTranslation(view.frame.size.width, 0.0)
                break
            }
            
            currentViewController.updateColors()
            
            lastVisibleIndex = currentIndex
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                
                self.currentViewController.view.transform = CGAffineTransformIdentity
                
                if self.oldViewController != nil
                {
                    switch self.direction
                    {
                    case "Forward":
                        self.oldViewController!.view.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0.0)
                        break
                        
                    case "Backward":
                        self.oldViewController!.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0.0)
                        break
                        
                    default:
                        self.oldViewController!.view.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0.0)
                        break
                    }
                }
                
                }, completion: { (finished) -> Void in
                    
                    if self.nextButton.alpha == 1.0
                    {
                        self.nextButton.userInteractionEnabled = true
                    }
                    if self.previousButton.alpha == 1.0
                    {
                        self.previousButton.userInteractionEnabled = true
                    }
                    if self.saveButton.alpha == 1.0
                    {
                        self.saveButton.userInteractionEnabled = true
                    }
                    
                    if self.oldViewController != nil
                    {
                        self.oldViewController!.willMoveToParentViewController(nil)
                        self.oldViewController!.removeFromParentViewController()
                        self.oldViewController!.view.removeFromSuperview()
                        self.oldViewController!.didMoveToParentViewController(nil)
                    }
            })
        }
    }
    
    private func viewControllerForPageType(pageType: ActivityViewControllerType) -> CESDatabaseActivity?
    {
        switch pageType
        {
        case .Calculator:
            return CalculatorVC()
            
        case .ClockDrag:
            return ClockDragVC()
            
        case .Garden:
            return Page_GardenDataVC()
            
        case .Intro:
            return Page_IntroVC()
            
        case .MathProblem:
            return MathProblemVC()
            
        case .Module:
            return ModuleVC()
            
        case .PictureQuiz:
            return PictureQuizVC()
            
        case .QuickQuiz:
            return QuickQuizVC()
            
        case .Read:
            return Page_ReadVC()
            
            //case .Sandbox:
            //    return SandboxVC()
            
        case .DrawingVC:
            return DrawingVC()
            
        case .Spelling:
            return SpellingTestVC()
            
        case .SquaresDragAndDrop:
            return SquaresDragAndDrop()
            
        case .Vocab:
            return VocabVC()
            
        default:
            return nil
        }
    }*/
}
