//
//  ActivityManagerVC.swift
//  CES
//
//  Created by Michael Schloss on 10/10/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit

@objc enum FrameType : Int
{
    case PageNumberLabel, TOCButtonFrame, PreviousButtonFrame, SaveButtonFrame, NextButtonFrame
}

//MARK: - ActivityManager Main

internal class ActivityManagerVC: UIViewController, CESActivityManager
{
    private var databaseManager = CESDatabase.databaseManagerForPageManagerClass()
    
    @IBOutlet private var pageNumberLabel: UILabel!
    @IBOutlet private var tableOfContentsButton: UIButton!
    @IBOutlet private var previousButton: UIButton!
        {
        didSet
        {
            UILabel.outlineLabel(previousButton.titleLabel!)
        }
    }
    @IBOutlet private var saveButton: UIButton!
        {
        didSet
        {
            UILabel.outlineLabel(saveButton.titleLabel!)
        }
    }
    @IBOutlet private var nextButton: UIButton!
        {
        didSet
        {
            UILabel.outlineLabel(nextButton.titleLabel!)
        }
    }
    @IBOutlet private var containerView: UIView!
        {
        didSet
        {
            containerView.backgroundColor = .clearColor()
        }
    }
    @IBOutlet private var saveProgressIndicator: MSProgressView!
    @IBOutlet private var tableOfContentsView: UIView!
        {
        didSet
        {
            tableOfContentsView.backgroundColor = .blackColor()
        }
    }
    @IBOutlet private var contentView : UIView!
        {
        didSet
        {
            contentView.backgroundColor = ColorScheme.currentColorScheme().backgroundColor
        }
    }
    
    private var tableOfContentsLoadingQueue : dispatch_queue_t!
    private var activityLoadingQueue : dispatch_queue_t!
    
    private var activityWillBeFullscreen = false
    
    lazy private var tableOfContentViews = [UIView]()
    
    @objc var margins : UIEdgeInsets
        {
        get
        {
            return UIEdgeInsetsMake(pageNumberLabel.frame.origin.y + pageNumberLabel.frame.size.height, 0.0, pageNumberLabel.frame.origin.y + pageNumberLabel.frame.size.height, 0.0)
        }
    }
    
    private var _currentActivity : Activity!
    @objc var currentActivity : Activity!
        {
        get
        {
            return _currentActivity
        }
        set
        {
            guard currentActivity == nil else { return }
            _currentActivity = newValue
            self.currentActivitySession = databaseManager.activitySessionForActivity(currentActivity)
        }
    }
    private var currentActivitySession : ActivitySession!
    private var currentActivityData : [[Int : AnyObject]]
        {
        get
        {
            return currentActivitySession.activityData ?? currentActivity.activityData ?? [[Int:AnyObject]]()
        }
        set
        {
            if currentActivitySession.activityData != nil
            {
                currentActivitySession.activityData = newValue
            }
        }
    }
    
    private var currentViewController : CESDatabaseActivity!
    private var currentActivityIndex = -1
    private var numberOfPages : Int
        {
        get
        {
            if currentActivitySession.activityData?.isEmpty == false
            {
                return currentActivitySession.activityData!.count
            }
            else
            {
                return currentActivity.activityData?.count ?? 0
            }
        }
    }
    
    @objc func frameForType(frameType: FrameType) -> CGRect
    {
        switch frameType
        {
        case .PageNumberLabel:
            return pageNumberLabel.frame
            
        case .TOCButtonFrame:
            return tableOfContentsButton.frame
            
        case .PreviousButtonFrame:
            return previousButton.frame
            
        case .SaveButtonFrame:
            return saveButton.frame
            
        case .NextButtonFrame:
            return nextButton.frame
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableOfContentsLoadingQueue = dispatch_queue_create("Table of Contents Loading Queue", DISPATCH_QUEUE_SERIAL)
        activityLoadingQueue = dispatch_queue_create("Activity Loading Queue", DISPATCH_QUEUE_SERIAL)
        
        view.backgroundColor = ColorScheme.currentColorScheme().backgroundColor
        saveProgressIndicator.barColor = ColorScheme.currentColorScheme().secondaryColor
        
        pageNumberLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        pageNumberLabel.text = "Page 0 of \(numberOfPages)"
        
        tableOfContentsButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        previousButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        saveButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        nextButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        
        let introVC = ActivityIntroVC()
        introVC.activityManager = self
        introVC.activityTitle = currentActivity.name
        introVC.summary = currentActivity.activityDescription
        addChildViewController(introVC)
        containerView.addSubview(introVC.view)
        currentViewController = introVC
        constrainCurrentViewController()
        
        updateButtons()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        dispatch_async(tableOfContentsLoadingQueue) { [unowned self] () -> Void in
            self.buildTableOfContentsView()
        }
    }
    
    private func constrainCurrentViewController()
    {
        guard let currentVC = currentViewController as? FormattedVC else
        {
            return
        }
        
        currentVC.view.translatesAutoresizingMaskIntoConstraints = false
        switch currentViewController.activityWantsFullScreen()
        {
        case true:
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[vc]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["vc":currentVC.view]))
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[vc]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["vc":currentVC.view]))
            
        case false:
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==leftMargin)-[vc]-(==rightMargin)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:["leftMargin":margins.left, "rightMargin":margins.right], views: ["vc":currentVC.view]))
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==topMargin)-[vc]-(==bottomMargin)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:["topMargin":margins.top, "bottomMargin":margins.bottom], views: ["vc":currentVC.view]))
        }
    }
    
    private func disableButtons()
    {
        previousButton.userInteractionEnabled = false
        nextButton.userInteractionEnabled = false
        saveButton.userInteractionEnabled = false
        tableOfContentsButton.userInteractionEnabled = false
    }
    
    private func enableButtons()
    {
        previousButton.userInteractionEnabled = true
        nextButton.userInteractionEnabled = true
        saveButton.userInteractionEnabled = true
        tableOfContentsButton.userInteractionEnabled = true
    }
    
    private func updateButtons()
    {
        switch currentActivityIndex
        {
        case -1...0:
            previousButton.userInteractionEnabled = false
            nextButton.userInteractionEnabled = true
            UIView.animateWithDuration(CESCometTransitionDuration, animations: { () -> Void in
                self.previousButton.alpha = 0.0
                self.nextButton.alpha = 1.0
            })
            
        case 0..<(numberOfPages - 1):
            previousButton.userInteractionEnabled = true
            nextButton.userInteractionEnabled = true
            UIView.animateWithDuration(CESCometTransitionDuration, animations: { () -> Void in
                self.previousButton.alpha = 1.0
                self.nextButton.alpha = 1.0
            })
            
        case numberOfPages - 1:
            previousButton.userInteractionEnabled = true
            nextButton.userInteractionEnabled = false
            UIView.animateWithDuration(CESCometTransitionDuration, animations: { () -> Void in
                self.previousButton.alpha = 1.0
                self.nextButton.alpha = 0.0
            })
            
        default: break
        }
    }
    
    @IBAction private func previousPage()
    {
        currentActivityIndex--
        guard currentActivityIndex >= 0 else
        {
            currentActivityIndex = -1
            let introVC = ActivityIntroVC()
            introVC.activityManager = self
            introVC.activityTitle = currentActivity.name
            introVC.summary = currentActivity.activityDescription
            addChildViewController(introVC)
            containerView.addSubview(introVC.view)
            currentViewController = introVC
            constrainCurrentViewController()
            addChildViewController(introVC)
            
            introVC.view.transform = CGAffineTransformMakeTranslation(-containerView.frame.size.width, 0.0)
            
            UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { [unowned self] () -> Void in
                introVC.view.transform = CGAffineTransformIdentity
                (self.currentViewController as! UIViewController).view.transform = CGAffineTransformMakeTranslation(self.containerView.frame.size.width, 0.0)
                }) { [unowned self] (finished) -> Void in
                    
                    (self.currentViewController as! UIViewController).view.removeFromSuperview()
                    (self.currentViewController as! UIViewController).removeFromParentViewController()
                    self.currentViewController = introVC
                    (self.currentViewController as! UIViewController).view.userInteractionEnabled = true
                    self.enableButtons()
            }
            return
        }
        
        dispatch_async(activityLoadingQueue) { [unowned self] () -> Void in
            let activityType = ActivityViewControllerType(rawValue: self.currentActivityData[self.currentActivityIndex].keys.first!)!
            let activityData = self.currentActivityData[self.currentActivityIndex].values.first!
            let previousActivityType = ActivityViewControllerType(rawValue: self.currentActivityData[self.currentActivityIndex + 1].keys.first!)!
            
            self.currentActivityData[self.currentActivityIndex + 1].updateValue(self.currentViewController.saveActivityState?() ?? "", forKey: previousActivityType.rawValue)
            
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                guard let previousPageVC = self.viewControllerForPageType(activityType) else { return }
                self.disableButtons()
                self.containerView.addSubview((previousPageVC as! UIViewController).view)
                self.constrainCurrentViewController()
                (previousPageVC as! UIViewController).view.transform = CGAffineTransformMakeTranslation(-self.containerView.frame.size.width, 0.0)
                previousPageVC.restoreActivityState?(activityData)
                self.addChildViewController(previousPageVC as! UIViewController)
                
                (self.currentViewController as! UIViewController).view.userInteractionEnabled = false
                (previousPageVC as! UIViewController).view.userInteractionEnabled = false
                
                UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { [unowned self] () -> Void in
                    (previousPageVC as! UIViewController).view.transform = CGAffineTransformIdentity
                    (self.currentViewController as! UIViewController).view.transform = CGAffineTransformMakeTranslation(self.containerView.frame.size.width, 0.0)
                    }) { [unowned self] (finished) -> Void in
                        (self.currentViewController as! UIViewController).view.removeFromSuperview()
                        (self.currentViewController as! UIViewController).removeFromParentViewController()
                        self.currentViewController = previousPageVC
                        (self.currentViewController as! UIViewController).view.userInteractionEnabled = true
                        self.enableButtons()
                }
                })
        }
    }
    
    @IBAction private func saveActivityProgress()
    {
        disableButtons()
        
        dispatch_async(activityLoadingQueue) { [unowned self] () -> Void in
            if self.numberOfPages > 0
            {
                let previousActivityType = ActivityViewControllerType(rawValue: self.currentActivityData[self.currentActivityIndex].keys.first!)!
                self.currentActivityData[self.currentActivityIndex].updateValue(self.currentViewController.saveActivityState?() ?? "", forKey: previousActivityType.rawValue)
            }
            
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                self.saveProgressIndicator.startAnimating(true)
                UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowAnimatedContent, animations: { () -> Void in
                    self.saveProgressIndicator.alpha = 1.0
                    self.saveButton.alpha = 0.0
                    self.saveButton.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    }, completion: nil)
                
                if self.numberOfPages > 0
                {
                    self.databaseManager.uploadActivitySession(self.currentActivitySession) { [unowned self] (uploadSuccess) -> Void in
                        if uploadSuccess == true
                        {
                            self.saveProgressIndicator.showComplete()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else
                        {
                            self.saveProgressIndicator.showIncomplete()
                            UIView.animateWithDuration(CESCometTransitionDuration, delay: 2.8, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowAnimatedContent, animations: { () -> Void in
                                self.saveProgressIndicator.alpha = 0.0
                                self.saveButton.alpha = 1.0
                                self.saveButton.transform = CGAffineTransformIdentity
                                }, completion: { (finished) in
                                    self.saveProgressIndicator.reset()
                            })
                        }
                    }
                }
                else
                {
                    NSTimer.scheduledTimerWithTimeInterval(1.3, target: self, selector: "dismissSelf", userInfo: nil, repeats: false)
                }
                })
        }
    }
    
    func dismissSelf()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction private func nextPage()
    {
        currentActivityIndex++
        guard currentActivityIndex < numberOfPages else
        {
            currentActivityIndex = numberOfPages - 1
            return
        }
        
        dispatch_async(activityLoadingQueue) { [unowned self] () -> Void in
            let activityType = ActivityViewControllerType(rawValue: self.currentActivityData[self.currentActivityIndex].keys.first!)!
            let activityData = self.currentActivityData[self.currentActivityIndex].values.first!
            let previousActivityType = ActivityViewControllerType(rawValue: self.currentActivityData[self.currentActivityIndex - 1].keys.first!)!
            
            self.currentActivityData[self.currentActivityIndex - 1].updateValue(self.currentViewController.saveActivityState?() ?? "", forKey: previousActivityType.rawValue)
            
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                guard let nextPageVC = self.viewControllerForPageType(activityType) else { return }
                self.disableButtons()
                self.containerView.addSubview((nextPageVC as! UIViewController).view)
                self.constrainCurrentViewController()
                (nextPageVC as! UIViewController).view.transform = CGAffineTransformMakeTranslation(self.containerView.frame.size.width, 0.0)
                nextPageVC.restoreActivityState?(activityData)
                self.addChildViewController(nextPageVC as! UIViewController)
                
                (self.currentViewController as! UIViewController).view.userInteractionEnabled = false
                (nextPageVC as! UIViewController).view.userInteractionEnabled = false
                
                UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { [unowned self] () -> Void in
                    (nextPageVC as! UIViewController).view.transform = CGAffineTransformIdentity
                    (self.currentViewController as! UIViewController).view.transform = CGAffineTransformMakeTranslation(-self.containerView.frame.size.width, 0.0)
                    }) { [unowned self] (finished) -> Void in
                        (self.currentViewController as! UIViewController).view.removeFromSuperview()
                        (self.currentViewController as! UIViewController).removeFromParentViewController()
                        self.currentViewController = nextPageVC
                        (self.currentViewController as! UIViewController).view.userInteractionEnabled = true
                        self.enableButtons()
                }
                })
        }
    }
    
    @IBAction private func viewTOC()
    {
        showTableOfContents()
    }
}

//MARK: - Introduction View Controller

extension ActivityManagerVC
{
    internal class ActivityIntroVC: FormattedVC
    {
        var summary : String!
            {
            didSet
            {
                if summaryTextView != nil
                {
                    summaryTextView.text = summary
                }
            }
        }
        
        var activityTitle : String!
            {
            didSet
            {
                if titleLabel != nil
                {
                    titleLabel.text = activityTitle
                }
            }
        }
        
        private var titleLabel : CESOutlinedLabel!
        private var summaryTextView : CESOutlinedLabel!
        
        override func viewDidLoad()
        {
            super.viewDidLoad()
            view.backgroundColor = .clearColor()
            
            summaryTextView = CESOutlinedLabel()
            summaryTextView.translatesAutoresizingMaskIntoConstraints = false
            summaryTextView.text = summary
            summaryTextView.textAlignment = .Center
            summaryTextView.font = UIFont.systemFontOfSize(28.0, weight: UIFontWeightRegular)
            summaryTextView.backgroundColor = ColorScheme.currentColorScheme().backgroundColor.lighter
            summaryTextView.textColor = ColorScheme.currentColorScheme().primaryColor
            summaryTextView.layer.borderColor = ColorScheme.currentColorScheme().secondaryColor.CGColor
            view.addSubview(summaryTextView)
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.7, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.5, constant: 0.0))
            
            titleLabel = CESOutlinedLabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFontOfSize(64.0, weight: UIFontWeightBlack)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.5
            titleLabel.textColor = ColorScheme.currentColorScheme().primaryColor
            titleLabel.text = activityTitle
            view.addSubview(titleLabel)
            view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(>=leftMargin)-[titleLabel]-(>=rightMargin)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["leftMargin":max(activityManager!.margins.left, 8), "rightMargin":max(activityManager!.margins.right, 8)], views: ["titleLabel":titleLabel]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[titleLabel]-(>=8)-[summaryTextView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["titleLabel":titleLabel, "summaryTextView":summaryTextView]))
        }
        
        func activityWantsFullScreen() -> Bool
        {
            return true
        }
    }
}

//MARK: - View Controller Loading

extension ActivityManagerVC
{
    private func viewControllerForPageType(pageType: ActivityViewControllerType) -> CESDatabaseActivity?
    {
        switch pageType
        {
        case .ClockDrag:
            return ClockDragVC()
            
        case .Garden:
            return Page_GardenDataVC()
            
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
    }
}

//MARK: - Table of Contents

extension ActivityManagerVC
{
    private func buildTableOfContentsView()
    {
        let introVC = ActivityIntroVC()
        introVC.activityManager = self
        introVC.activityTitle = currentActivity.name
        introVC.summary = currentActivity.activityDescription
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        introVC.view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = CESCometUIImageView()
        imageView.setImage(copied)
        tableOfContentViews.append(imageView)
        
        for index in 0..<numberOfPages
        {
            let activity = viewControllerForPageType(ActivityViewControllerType(rawValue: currentActivityData[index].keys.first!)!)
            activity?.restoreActivityState?(currentActivityData[index].values.first!)
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
            (activity as! UIViewController).view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
            let snapshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageView = CESCometUIImageView()
            imageView.setImage(snapshot)
            if currentActivity.quizMode == .Yes
            {
                imageView.enableQuizMode()
            }
            tableOfContentViews.append(imageView)
        }
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] () -> Void in
            self.setUpTOCView()
        }
    }
    
    private func setUpTOCView()
    {
        
    }
    
    private func showTableOfContents()
    {
        
    }
}
