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

private class ActivityManagerVC: UIViewController, CESActivityManager
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
    @IBOutlet private var contentView: UIView!
    @IBOutlet var saveProgressIndicator: MSProgressView!
    @IBOutlet var tableOfContentsView: UIView!
    
    private var tableOfContentsLoadingQueue : dispatch_queue_t!
    private var activityLoadingQueue : dispatch_queue_t!
    
    private var activityWillBeFullscreen = false
    
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
    
    private var currentViewController : CESDatabaseActivity!
    private var currentActivityIndex = -1
    private var numberOfPages : Int
        {
        get
        {
            if currentActivitySession.activityData.isEmpty == false
            {
                return currentActivitySession.activityData.count
            }
            else
            {
                return currentActivity.activityData.count
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
        contentView.backgroundColor = ColorScheme.currentColorScheme().backgroundColor
        saveProgressIndicator.barColor = ColorScheme.currentColorScheme().secondaryColor
        
        pageNumberLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        pageNumberLabel.text = "Page 0 of \(numberOfPages)"
        
        tableOfContentsButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        previousButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        saveButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        nextButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        
        let introVC = ActivityIntroVC()
        introVC.activityTitle = currentActivity.name
        introVC.summary = currentActivity.activityDescription
        contentView.addSubview(introVC.view)
        currentViewController = introVC
        constrainCurrentViewController()
        
        updateButtons()
    }
    
    private func constrainCurrentViewController()
    {
        guard let currentVC = currentViewController as? UIViewController else
        {
            return
        }
        
        switch currentViewController.activityWantsFullScreen()
        {
        case true:
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[vc]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["vc":currentVC]))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[vc]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["vc":currentVC]))
            
        case false:
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==leftMargin)-[vc]-(==rightMargin)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:["leftMargin":margins.left, "rightMargin":margins.right], views: ["vc":currentVC]))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==topMargin)-[vc]-(==bottomMargin)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:["topMargin":margins.top, "bottomMargin":margins.bottom], views: ["vc":currentVC]))
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
            introVC.activityTitle = currentActivity.name
            introVC.summary = currentActivity.activityDescription
            contentView.addSubview(introVC.view)
            currentViewController = introVC
            constrainCurrentViewController()
            
            introVC.view.transform = CGAffineTransformMakeTranslation(-contentView.frame.size.width, 0.0)
            
            UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { [unowned self] () -> Void in
                introVC.view.transform = CGAffineTransformIdentity
                (self.currentViewController as! UIViewController).view.transform = CGAffineTransformMakeTranslation(self.contentView.frame.size.width, 0.0)
                }) { [unowned self] (finished) -> Void in
                    
                    (self.currentViewController as! UIViewController).view.removeFromSuperview()
                    self.currentViewController = introVC
                    (self.currentViewController as! UIViewController).view.userInteractionEnabled = true
                    self.enableButtons()
            }
            return
        }
        
        dispatch_async(activityLoadingQueue) { [unowned self] () -> Void in
            var activityType : ActivityViewControllerType
            var activityData : AnyObject
            if self.currentActivitySession.activityData.isEmpty == false
            {
                activityType = ActivityViewControllerType(rawValue: self.currentActivitySession.activityData[self.currentActivityIndex].keys.first!)!
                activityData = self.currentActivitySession.activityData[self.currentActivityIndex].values.first!
                
            }
            else
            {
                activityType = ActivityViewControllerType(rawValue: self.currentActivity.activityData[self.currentActivityIndex].keys.first!)!
                activityData = self.currentActivity.activityData[self.currentActivityIndex].values.first!
            }
            
            var previousActivityType : ActivityViewControllerType
            if self.currentActivitySession.activityData.isEmpty == false
            {
                previousActivityType = ActivityViewControllerType(rawValue: self.currentActivitySession.activityData[self.currentActivityIndex + 1].keys.first!)!
                
            }
            else
            {
                previousActivityType = (self.currentActivity.activityData[self.currentActivityIndex + 1] as NSDictionary).allKeys.first! as! ActivityViewControllerType
            }
            
            self.currentActivitySession.activityData[self.currentActivityIndex + 1].updateValue(self.currentViewController.saveActivityState?() ?? "", forKey: previousActivityType.rawValue)
            
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                guard let previousPageVC = self.viewControllerForPageType(activityType) else { return }
                self.disableButtons()
                self.contentView.addSubview((previousPageVC as! UIViewController).view)
                self.constrainCurrentViewController()
                (previousPageVC as! UIViewController).view.transform = CGAffineTransformMakeTranslation(-self.contentView.frame.size.width, 0.0)
                previousPageVC.restoreActivityState?(activityData)
                
                (self.currentViewController as! UIViewController).view.userInteractionEnabled = false
                (previousPageVC as! UIViewController).view.userInteractionEnabled = false
                
                UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { [unowned self] () -> Void in
                    (previousPageVC as! UIViewController).view.transform = CGAffineTransformIdentity
                    (self.currentViewController as! UIViewController).view.transform = CGAffineTransformMakeTranslation(self.contentView.frame.size.width, 0.0)
                    }) { [unowned self] (finished) -> Void in
                        (self.currentViewController as! UIViewController).view.removeFromSuperview()
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
            var previousActivityType : ActivityViewControllerType
            if self.currentActivitySession.activityData.isEmpty == false
            {
                previousActivityType = ActivityViewControllerType(rawValue: self.currentActivitySession.activityData[self.currentActivityIndex + 1].keys.first!)!
                
            }
            else
            {
                previousActivityType = ActivityViewControllerType(rawValue: self.currentActivity.activityData[self.currentActivityIndex + 1].keys.first!)!
            }
            self.currentActivitySession.activityData[self.currentActivityIndex].updateValue(self.currentViewController.saveActivityState?() ?? "", forKey: previousActivityType.rawValue)
            
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                self.saveProgressIndicator.startAnimating(true)
                UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowAnimatedContent, animations: { () -> Void in
                    self.saveProgressIndicator.alpha = 1.0
                    self.saveButton.alpha = 0.0
                    self.saveButton.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    }, completion: nil)
                
                self.databaseManager.uploadActivitySession(self.currentActivitySession) { [unowned self] (uploadSuccess) -> Void in
                    if uploadSuccess == true
                    {
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
                })
        }
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
            var activityType : ActivityViewControllerType
            var activityData : AnyObject
            if self.currentActivitySession.activityData.isEmpty == false
            {
                activityType = ActivityViewControllerType(rawValue: self.currentActivitySession.activityData[self.currentActivityIndex].keys.first!)!
                activityData = self.currentActivitySession.activityData[self.currentActivityIndex].values.first!
                
            }
            else
            {
                activityType = ActivityViewControllerType(rawValue: self.currentActivity.activityData[self.currentActivityIndex].keys.first!)!
                activityData = self.currentActivity.activityData[self.currentActivityIndex].keys.first!
            }
            
            var previousActivityType : ActivityViewControllerType
            if self.currentActivitySession.activityData.isEmpty == false
            {
                previousActivityType = ActivityViewControllerType(rawValue: self.currentActivitySession.activityData[self.currentActivityIndex - 1].keys.first!)!
                
            }
            else
            {
                previousActivityType = ActivityViewControllerType(rawValue: self.currentActivity.activityData[self.currentActivityIndex - 1].keys.first!)!
            }
            
            self.currentActivitySession.activityData[self.currentActivityIndex - 1].updateValue(self.currentViewController.saveActivityState?() ?? "", forKey: previousActivityType.rawValue)
            
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                guard let nextPageVC = self.viewControllerForPageType(activityType) else { return }
                self.disableButtons()
                self.contentView.addSubview((nextPageVC as! UIViewController).view)
                self.constrainCurrentViewController()
                (nextPageVC as! UIViewController).view.transform = CGAffineTransformMakeTranslation(self.contentView.frame.size.width, 0.0)
                nextPageVC.restoreActivityState?(activityData)
                
                (self.currentViewController as! UIViewController).view.userInteractionEnabled = false
                (nextPageVC as! UIViewController).view.userInteractionEnabled = false
                
                UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { [unowned self] () -> Void in
                    (nextPageVC as! UIViewController).view.transform = CGAffineTransformIdentity
                    (self.currentViewController as! UIViewController).view.transform = CGAffineTransformMakeTranslation(-self.contentView.frame.size.width, 0.0)
                    }) { [unowned self] (finished) -> Void in
                        (self.currentViewController as! UIViewController).view.removeFromSuperview()
                        self.currentViewController = nextPageVC
                        (self.currentViewController as! UIViewController).view.userInteractionEnabled = true
                        self.enableButtons()
                }
                })
        }
    }
    
    @IBAction private func viewTOC()
    {
        
    }
}

//MARK: - Introduction View Controller

extension ActivityManagerVC
{
    class ActivityIntroVC: FormattedVC
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
        
        private override func viewDidLoad()
        {
            super.viewDidLoad()
            
            summaryTextView = CESOutlinedLabel()
            summaryTextView.text = summary
            summaryTextView.textAlignment = .Center
            summaryTextView.font = UIFont.systemFontOfSize(28.0, weight: UIFontWeightRegular)
            summaryTextView.backgroundColor = view.backgroundColor?.lighter
            summaryTextView.textColor = ColorScheme.currentColorScheme().primaryColor
            summaryTextView.layer.borderColor = ColorScheme.currentColorScheme().secondaryColor.CGColor
            view.addSubview(summaryTextView)
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Width, multiplier: 0.7, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.5, constant: 0.0))
            
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
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(20)-[titleLabel]-(>=8)-[summaryTextView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["titleLabel":titleLabel, "summaryTextView":summaryTextView]))
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
        case .Calculator:
            return CalculatorVC()
            
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
    func buildTableOfContentsView()
    {
        
    }
}
