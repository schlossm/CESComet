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
    @IBOutlet private var titleLabel      : CESOutlinedLabel!
        {
        didSet
        {
            titleLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        }
    }
    
    //Subject Buttons
    @IBOutlet private var buttonView      : UIView!
    
    @IBOutlet private var languageArts    : HomeButton!
        {
        didSet
        {
            languageArts.actionHandler = { [unowned self] in
                print("Language Arts")
            }
        }
    }
    @IBOutlet private var math            : HomeButton!
        {
        didSet
        {
            math.actionHandler = { [unowned self] in
                print("Math")
            }
        }
    }
    @IBOutlet private var history         : HomeButton!
        {
        didSet
        {
            history.actionHandler = { [unowned self] in
                print("History")
            }
        }
    }
    @IBOutlet private var science         : HomeButton!
        {
        didSet
        {
            science.actionHandler = { [unowned self] in
                print("Science")
            }
        }
    }
    
    //For View Type One
    private var scrollView      : UIScrollView!
    
    var viewType = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = ColorScheme.currentColorScheme().backgroundColor
        
        if CurrentUser.hasSavedUserInformation() { CurrentUser.currentUser().loadSavedUser() }
        
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
}

//MARK: - Introduction/Tutorial
/*
extension HomeVC
{
    private func beginIntroductionAndTutorial()
    {
        blackView = UIView()
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.alpha = 0.0
        blackView.backgroundColor = .blackColor()
        UIApplication.sharedApplication().keyWindow!.addSubview(blackView)
        UIApplication.sharedApplication().keyWindow!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blackView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["blackView":blackView]))
        UIApplication.sharedApplication().keyWindow!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[blackView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["blackView":blackView]))
        
        
        UIView.animateWithDuration(0.5 , delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
            self.blackView.alpha = 1.0
            
            }) { (finished) -> Void in
                
                self.showIntroduction()
                
        }
    }
    
    private func showIntroduction()
    {
        let helloText = UILabel()
        helloText.translatesAutoresizingMaskIntoConstraints = false
        helloText.font = UIFont(name: "HelveticaNeue-Thin", size: 72.0)
        helloText.text = stringForKey("HelloThere")
        helloText.textAlignment = .Center
        helloText.baselineAdjustment = .AlignCenters
        helloText.alpha = 0.0
        helloText.textColor = .whiteColor()
        blackView.addSubview(helloText)
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[helloText]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["helloText":helloText]))
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[helloText]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["helloText":helloText]))
        
        UIView.animateWithDuration(0.5, delay: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            
            helloText.alpha = 1.0
            
            }) { (finished) -> Void in
                
                UIView.animateWithDuration(0.5, delay: 2.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                    
                    helloText.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                        
                        helloText.removeFromSuperview()
                        
                        let welcomeToCometText = UILabel()
                        welcomeToCometText.translatesAutoresizingMaskIntoConstraints = false
                        welcomeToCometText.font = UIFont(name: "HelveticaNeue-Thin", size: 72.0)
                        welcomeToCometText.text = stringForKey("WelcomeToComet")
                        welcomeToCometText.textAlignment = .Center
                        welcomeToCometText.numberOfLines = 0
                        welcomeToCometText.baselineAdjustment = .AlignCenters
                        welcomeToCometText.alpha = 0.0
                        welcomeToCometText.textColor = .whiteColor()
                        self.blackView.addSubview(welcomeToCometText)
                        self.blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[needHelpText]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["needHelpText":welcomeToCometText]))
                        self.blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[needHelpText]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["needHelpText":welcomeToCometText]))
                        
                        UIView.animateWithDuration(0.5, delay: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                            
                            welcomeToCometText.alpha = 1.0
                            
                            }, completion: { (finished) -> Void in
                                
                                UIView.animateWithDuration(0.5, delay: 3.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                                    
                                    welcomeToCometText.alpha = 0.0
                                    
                                    }, completion: { (finished) -> Void in
                                        
                                        welcomeToCometText.removeFromSuperview()
                                        
                                        let needHelpText = UILabel()
                                        needHelpText.translatesAutoresizingMaskIntoConstraints = false
                                        needHelpText.font = UIFont(name: "HelveticaNeue-Thin", size: 72.0)
                                        needHelpText.text = stringForKey("WeNeedYourHelp")
                                        needHelpText.textAlignment = .Center
                                        needHelpText.numberOfLines = 0
                                        needHelpText.baselineAdjustment = .AlignCenters
                                        needHelpText.alpha = 0.0
                                        needHelpText.textColor = .whiteColor()
                                        self.blackView.addSubview(needHelpText)
                                        self.blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[needHelpText]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["needHelpText":needHelpText]))
                                        self.blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[needHelpText]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["needHelpText":needHelpText]))
                                        
                                        UIView.animateWithDuration(0.5, delay: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                                            
                                            needHelpText.alpha = 1.0
                                            
                                            }, completion: { (finished) -> Void in
                                                
                                                UIView.animateWithDuration(0.5, delay: 5.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                                                    
                                                    needHelpText.alpha = 0.0
                                                    
                                                    }, completion: { (finished) -> Void in
                                                        
                                                        needHelpText.removeFromSuperview()
                                                        
                                                        self.showHomeScreenTypeChoice()
                                                        
                                                })
                                        })
                                        
                                })
                        })
                })
                
        }
    }
    
    private var detailLabel : UILabel!
    
    private func showHomeScreenTypeChoice()
    {
        let topQuestion = UILabel()
        topQuestion.translatesAutoresizingMaskIntoConstraints = false
        topQuestion.font = UIFont(name: "HelveticaNeue-Thin", size: 56.0)
        topQuestion.text = stringForKey("HomeLayoutQuestion")
        topQuestion.numberOfLines = 0
        topQuestion.textAlignment = .Center
        topQuestion.baselineAdjustment = .AlignCenters
        topQuestion.alpha = 0.0
        topQuestion.textColor = .whiteColor()
        blackView.addSubview(topQuestion)
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[topQuestion]-(20)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["topQuestion":topQuestion]))
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topQuestion]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["topQuestion":topQuestion]))
        
        let hSTSCFont = UIFont.boldSystemFontOfSize(24.0)
        let attributes = [NSFontAttributeName: hSTSCFont]
        
        let homeScreenTypeSegmentControl = UISegmentedControl(items: [stringForKey("ExpandedHomeScreenOption"), stringForKey("CompactHomeScreenOption")])
        homeScreenTypeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        homeScreenTypeSegmentControl.alpha = 0.0
        homeScreenTypeSegmentControl.selectedSegmentIndex = 0
        homeScreenTypeSegmentControl.setTitleTextAttributes(attributes, forState: .Normal)
        homeScreenTypeSegmentControl.tintColor = view.backgroundColor
        homeScreenTypeSegmentControl.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
        blackView.addSubview(homeScreenTypeSegmentControl)
        blackView.addConstraint(NSLayoutConstraint(item: homeScreenTypeSegmentControl, attribute: .Width, relatedBy: .Equal, toItem: blackView, attribute: .Width, multiplier: 0.7, constant: 0.0))
        blackView.addConstraint(NSLayoutConstraint(item: homeScreenTypeSegmentControl, attribute: .CenterX, relatedBy: .Equal, toItem: blackView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topQuestion]-(50)-[homeScreenTypeSegmentControl]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["topQuestion":topQuestion, "homeScreenTypeSegmentControl":homeScreenTypeSegmentControl]))
        
        let instructions = UILabel()
        instructions.translatesAutoresizingMaskIntoConstraints = false
        instructions.font = UIFont(name: "Helvetica Neue", size: 24.0)
        instructions.text = stringForKey("HomeLayoutInstructions")
        instructions.numberOfLines = 0
        instructions.textAlignment = .Center
        instructions.baselineAdjustment = .AlignCenters
        instructions.alpha = 0.0
        instructions.textColor = .whiteColor()
        blackView.addSubview(instructions)
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[instructions]-(20)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["instructions":instructions]))
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[homeScreenTypeSegmentControl]-(20)-[instructions]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["homeScreenTypeSegmentControl":homeScreenTypeSegmentControl, "instructions":instructions]))
        
        setUpSmallHSL(0.5)
        
        UIView.animateWithDuration(0.5, delay: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            
            instructions.alpha = 1.0
            topQuestion.alpha = 1.0
            homeScreenTypeSegmentControl.alpha = 1.0
            
            }, completion:nil)
    }
    
    private var smallScreenView : MiniScreenView!
    private var smallScreenViewFrame : CGRect!
    
    private func setUpSmallHSL(delay: NSTimeInterval)
    {
        detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 38.0)
        detailLabel.text = stringForKey("DetailForBigHSL")
        detailLabel.textAlignment = .Center
        detailLabel.baselineAdjustment = .None
        detailLabel.alpha = 0.0
        detailLabel.numberOfLines = 0
        detailLabel.textColor = .whiteColor()
        blackView.addSubview(detailLabel)
        
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[detailLabel]-(20)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["detailLabel":detailLabel]))
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[detailLabel]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["detailLabel":detailLabel]))
        
        smallScreenView = MiniScreenView()
        smallScreenView.translatesAutoresizingMaskIntoConstraints = false
        smallScreenView.layer.borderColor = UIColor.grayColor().lighter.CGColor
        smallScreenView.layer.borderWidth = 5.0
        smallScreenView.alpha = 0.0
        blackView.addSubview(smallScreenView)
        blackView.addConstraint(NSLayoutConstraint(item: smallScreenView, attribute: .CenterX, relatedBy: .Equal, toItem: blackView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        blackView.addConstraint(NSLayoutConstraint(item: smallScreenView, attribute: .CenterY, relatedBy: .Equal, toItem: blackView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        blackView.addConstraint(NSLayoutConstraint(item: smallScreenView, attribute: .Width,   relatedBy: .Equal, toItem: blackView, attribute: .Width, multiplier: 0.2, constant: 0.0))
        blackView.addConstraint(NSLayoutConstraint(item: smallScreenView, attribute: .Height,  relatedBy: .Equal, toItem: blackView, attribute: .Height, multiplier: 0.2, constant: 0.0))
        
        let screens = UIView()
        screens.translatesAutoresizingMaskIntoConstraints = false
        screens.backgroundColor = view.backgroundColor
        smallScreenView.addSubview(screens)
        smallScreenView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(5)-[screens]-(5)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["screens":screens]))
        smallScreenView.addConstraint(NSLayoutConstraint(item: screens, attribute: .CenterX, relatedBy: .Equal, toItem: smallScreenView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        switch homeViewType
        {
        case "Expanded":
            smallScreenView.addConstraint(NSLayoutConstraint(item: screens, attribute: .Width, relatedBy: .Equal, toItem: smallScreenView, attribute: .Width, multiplier: 3.0, constant: -30.0))
            break
            
        case "Compact":
            smallScreenView.addConstraint(NSLayoutConstraint(item: screens, attribute: .Width, relatedBy: .Equal, toItem: smallScreenView, attribute: .Width, multiplier: 1.0, constant: -10.0))
            break
            
        default:
            break
        }
        smallScreenView.actionHandler = { () -> Void in
            NSTimer.scheduledTimerWithTimeInterval(0.19, target: self, selector: "moveOnToColorChoice", userInfo: nil, repeats: false)
            
            UIView.animateWithDuration(0.3, delay: 0.21, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                
                self.smallScreenView.alpha = 0.0
                
                }, completion: nil)
            
            UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                
                self.shouldContinue = false
                self.smallScreenView.transform = CGAffineTransformMakeScale(10.0, 10.0)
                
                }, completion: { (finished) -> Void in
                    
                    self.smallScreenView.removeFromSuperview()
                    
            })
        }
        
        blackView.layoutIfNeeded()
        buildSmallScreensForHSL(screens)
        screens.layer.shouldRasterize = true
        screens.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        switch homeViewType
        {
        case "Expanded":
            blackView.layoutIfNeeded()
            screens.transform = CGAffineTransformMakeTranslation(CGRectInset(smallScreenView.frame, 5.0, 5.0).width, 0.0)
            break
            
        default:
            break
        }
        
        smallScreenViewFrame = smallScreenView.frame
        
        UIView.animateWithDuration(0.5, delay: delay, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            
            self.detailLabel.alpha = 1.0
            self.smallScreenView.alpha = 1.0
            
            }) { (finished) -> Void in
                
                switch self.homeViewType
                {
                case "Expanded":
                    self.shouldContinue = true
                    self.animateScreensLeftFirst(screens, delay: nil)
                    break
                    
                default:
                    break
                }
        }
    }
    
    private var shouldContinue = true
    
    private func animateScreensLeftFirst(screens: UIView, delay: NSTimeInterval?)
    {
        if shouldContinue
        {
            UIView.animateWithDuration(1.5, delay: delay != nil ? delay! : 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: .AllowUserInteraction, animations: { () -> Void in
                
                screens.transform = CGAffineTransformIdentity
                
                }) { (finished) -> Void in
                    if self.shouldContinue
                    {
                        UIView.animateWithDuration(1.5, delay: 2.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: .AllowUserInteraction, animations: { () -> Void in
                            
                            screens.transform = CGAffineTransformMakeTranslation(-CGRectInset(self.smallScreenViewFrame, 5.0, 5.0).width, 0.0)
                            
                            }, completion: { (finished) -> Void in
                                self.animateScreensRight(screens)
                        })
                    }
            }
        }
    }
    
    private func animateScreensRight(screens: UIView)
    {
        if shouldContinue
        {
            UIView.animateWithDuration(1.5, delay: 2.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                
                screens.transform = CGAffineTransformIdentity
                
                }) { (finished) -> Void in
                    if self.shouldContinue
                    {
                        UIView.animateWithDuration(1.5, delay: 2.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                            
                            screens.transform = CGAffineTransformMakeTranslation(CGRectInset(self.smallScreenViewFrame, 5.0, 5.0).width, 0.0)
                            
                            }, completion: { (finished) -> Void in
                                self.animateScreensLeftFirst(screens, delay: 2.0)
                        })
                    }
            }
        }
    }
    
    private var miniTitleLabel : UIView!
    
    private func buildSmallScreensForHSL(view: UIView)
    {
        miniTitleLabel = UIView()
        miniTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        miniTitleLabel.backgroundColor = .whiteColor()
        view.superview!.addSubview(miniTitleLabel)
        view.superview!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(9)-[miniTitleLabel(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height":titleLabel.frame.size.height * 0.2], views: ["miniTitleLabel":miniTitleLabel]))
        view.superview!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(9)-[miniTitleLabel(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width":titleLabel.frame.size.width * 0.2], views: ["miniTitleLabel":miniTitleLabel]))
        view.superview!.layoutIfNeeded()
        
        //
        //First Page -- Buttons
        //
        
        let miniButtonView = UIView()
        miniButtonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(miniButtonView)
        switch self.homeViewType
        {
        case "Compact":
            view.addConstraint(NSLayoutConstraint(item: miniButtonView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 0.0, constant: 4.0))
            view.addConstraint(NSLayoutConstraint(item: miniButtonView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: self.miniTitleLabel.frame.size.height + 8.0))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[miniButtonView(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height":400.0 * 0.2], views: ["miniButtonView":miniButtonView]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[miniButtonView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width":320.0 * 0.2], views: ["miniButtonView":miniButtonView]))
            break
            
        default:
            view.addConstraint(NSLayoutConstraint(item: miniButtonView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0/6.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: miniButtonView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[miniButtonView(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height":400.0 * 0.2], views: ["miniButtonView":miniButtonView]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[miniButtonView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width":320.0 * 0.2], views: ["miniButtonView":miniButtonView]))
            break
        }
        
        let laButton = UIView()
        laButton.translatesAutoresizingMaskIntoConstraints = false
        laButton.backgroundColor = view.backgroundColor?.lighter
        laButton.layer.borderWidth = 2.0
        laButton.layer.borderColor = UIColor.grayColor().lighter.CGColor
        miniButtonView.addSubview(laButton)
        let mButton = UIView()
        mButton.translatesAutoresizingMaskIntoConstraints = false
        mButton.backgroundColor = view.backgroundColor?.lighter
        mButton.layer.borderWidth = 2.0
        mButton.layer.borderColor = UIColor.grayColor().lighter.CGColor
        miniButtonView.addSubview(mButton)
        let sButton = UIView()
        sButton.translatesAutoresizingMaskIntoConstraints = false
        sButton.backgroundColor = view.backgroundColor?.lighter
        sButton.layer.borderWidth = 2.0
        sButton.layer.borderColor = UIColor.grayColor().lighter.CGColor
        miniButtonView.addSubview(sButton)
        let hButton = UIView()
        hButton.translatesAutoresizingMaskIntoConstraints = false
        hButton.backgroundColor = view.backgroundColor?.lighter
        hButton.layer.borderWidth = 2.0
        hButton.layer.borderColor = UIColor.grayColor().lighter.CGColor
        miniButtonView.addSubview(hButton)
        
        miniButtonView.addConstraint(NSLayoutConstraint(item: laButton, attribute: .Leading, relatedBy: .Equal, toItem: miniButtonView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        miniButtonView.addConstraint(NSLayoutConstraint(item: laButton, attribute: .Top, relatedBy: .Equal, toItem: miniButtonView, attribute: .Top, multiplier: 1.0, constant: 0.0))
        miniButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[laButton(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height":170.0 * 0.2], views: ["laButton":laButton]))
        miniButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[laButton(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width":130.0 * 0.2], views: ["laButton":laButton]))
        miniButtonView.addConstraint(NSLayoutConstraint(item: mButton, attribute: .Trailing, relatedBy: .Equal, toItem: miniButtonView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        miniButtonView.addConstraint(NSLayoutConstraint(item: mButton, attribute: .Top, relatedBy: .Equal, toItem: miniButtonView, attribute: .Top, multiplier: 1.0, constant: 0.0))
        miniButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[mButton(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height":170.0 * 0.2], views: ["mButton":mButton]))
        miniButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[mButton(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width":130.0 * 0.2], views: ["mButton":mButton]))
        miniButtonView.addConstraint(NSLayoutConstraint(item: sButton, attribute: .Leading, relatedBy: .Equal, toItem: miniButtonView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        miniButtonView.addConstraint(NSLayoutConstraint(item: sButton, attribute: .Bottom, relatedBy: .Equal, toItem: miniButtonView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        miniButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[sButton(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height":170.0 * 0.2], views: ["sButton":sButton]))
        miniButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[sButton(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width":130.0 * 0.2], views: ["sButton":sButton]))
        miniButtonView.addConstraint(NSLayoutConstraint(item: hButton, attribute: .Trailing, relatedBy: .Equal, toItem: miniButtonView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        miniButtonView.addConstraint(NSLayoutConstraint(item: hButton, attribute: .Bottom, relatedBy: .Equal, toItem: miniButtonView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        miniButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[hButton(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height":170.0 * 0.2], views: ["hButton":hButton]))
        miniButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[hButton(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width":130.0 * 0.2], views: ["hButton":hButton]))
        
        //
        //Second Page - Calendar
        //
        
        let calendarView = UIView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarView)
        switch self.homeViewType
        {
        case "Compact":
            view.addConstraint(NSLayoutConstraint(item: calendarView, attribute: .Leading, relatedBy: .Equal, toItem: miniButtonView, attribute: .Trailing, multiplier: 1.0, constant: 4.0))
            view.addConstraint(NSLayoutConstraint(item: calendarView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: -4.0))
            view.addConstraint(NSLayoutConstraint(item: calendarView, attribute: .Top, relatedBy: .Equal, toItem: miniButtonView, attribute: .Top, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: calendarView, attribute: .Bottom, relatedBy: .Equal, toItem: miniButtonView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
            break
            
        default:
            view.addConstraint(NSLayoutConstraint(item: calendarView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 0.5, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: calendarView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 4.0 + miniTitleLabel.frame.size.height + miniTitleLabel.frame.origin.y))
            view.addConstraint(NSLayoutConstraint(item: calendarView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -4.0))
            view.addConstraint(NSLayoutConstraint(item: calendarView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: (1.0/3.0), constant: -8.0))
            break
        }
        
        
        for index in 2...32
        {
            let calendarDot = UIView()
            calendarDot.translatesAutoresizingMaskIntoConstraints = false
            calendarDot.backgroundColor = UIColor.grayColor().lighter
            calendarView.addSubview(calendarDot)
            calendarView.addConstraint(NSLayoutConstraint(item: calendarDot, attribute: .CenterX, relatedBy: .Equal, toItem: calendarView, attribute: .Trailing, multiplier: ((CGFloat(index % 7) + 1.0) / 8.0), constant: 0.0))
            calendarView.addConstraint(NSLayoutConstraint(item: calendarDot, attribute: .CenterY, relatedBy: .Equal, toItem: calendarView, attribute: .Bottom, multiplier: (CGFloat(index / 7) + 1.0)/6.0, constant: 0.0))
            calendarView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[calendarDot(4)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarDot":calendarDot]))
            calendarView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[calendarDot(4)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarDot":calendarDot]))
        }
        
        //
        //Third Page - Quick Assignments
        //
        
        let tableBorder = UIView()
        tableBorder.translatesAutoresizingMaskIntoConstraints = false
        tableBorder.layer.borderColor = UIColor.grayColor().lighter.CGColor
        tableBorder.layer.borderWidth = 2.0
        view.addSubview(tableBorder)
        switch self.homeViewType
        {
        case "Compact":
            view.addConstraint(NSLayoutConstraint(item: tableBorder, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier:1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: tableBorder, attribute: .Top, relatedBy: .Equal, toItem: miniButtonView, attribute: .Bottom, multiplier: 1.0, constant: 4.0))
            view.addConstraint(NSLayoutConstraint(item: tableBorder, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -4.0))
            view.addConstraint(NSLayoutConstraint(item: tableBorder, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1.0, constant: -8.0))
            break
            
        default:
            view.addConstraint(NSLayoutConstraint(item: tableBorder, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 5.0/6.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: tableBorder, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 4.0 + miniTitleLabel.frame.size.height + miniTitleLabel.frame.origin.y))
            view.addConstraint(NSLayoutConstraint(item: tableBorder, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -4.0))
            view.addConstraint(NSLayoutConstraint(item: tableBorder, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: (1.0/3.0), constant: -8.0))
            break
        }
        
        
        var num : Int
        switch homeViewType
        {
        case "Compact":
            num = 2
            break
            
        default:
            num = 7
            break
        }
        for index in 1...num
        {
            let num = (CGFloat(index)/CGFloat(num + 1))
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = UIColor.grayColor().lighter
            tableBorder.addSubview(line)
            tableBorder.addConstraint(NSLayoutConstraint(item: line, attribute: .Leading, relatedBy: .Equal, toItem: tableBorder, attribute: .Trailing, multiplier: 0.1, constant: -2.0))
            tableBorder.addConstraint(NSLayoutConstraint(item: line, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: tableBorder, attribute: .Bottom, multiplier: num, constant: 0.0))
            tableBorder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[line(1)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["line":line]))
            tableBorder.addConstraint(NSLayoutConstraint(item: line, attribute: .Width, relatedBy: .Equal, toItem: tableBorder, attribute: .Width, multiplier: 0.9, constant: 0.0))
        }
    }
    
    func segmentedControlValueChanged(segmentedControl: UISegmentedControl)
    {
        shouldContinue = false
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            homeViewType = "Expanded"
            UIView.animateWithDuration(0.5, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                self.smallScreenView.alpha = 0.0
                self.detailLabel.alpha = 0.0
                
                }, completion: { (finished) -> Void in
                    
                    self.smallScreenView.removeFromSuperview()
                    self.detailLabel.removeFromSuperview()
                    
                    self.setUpSmallHSL(0.0)
                    
            })
            break
            
        case 1:
            homeViewType = "Compact"
            UIView.animateWithDuration(0.5, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                self.smallScreenView.alpha = 0.0
                self.detailLabel.alpha = 0.0
                
                }, completion: { (finished) -> Void in
                    
                    (self.smallScreenView.subviews[0] ).layer.removeAllAnimations()
                    self.smallScreenView.removeFromSuperview()
                    self.detailLabel.removeFromSuperview()
                    
                    self.setUpSmallHSL(0.0)
                    
            })
            break
            
        default:
            break
        }
    }
    
    func moveOnToColorChoice()
    {
        for subview in self.blackView.subviews 
        {
            if subview !== smallScreenView
            {
                subview.removeFromSuperview()
            }
        }
        
        let thankYouText = UILabel()
        thankYouText.translatesAutoresizingMaskIntoConstraints = false
        thankYouText.font = UIFont(name: "HelveticaNeue-Thin", size: 72.0)
        thankYouText.text = stringForKey("ThankYou")
        thankYouText.textAlignment = .Center
        thankYouText.baselineAdjustment = .AlignCenters
        thankYouText.alpha = 1.0
        thankYouText.textColor = .whiteColor()
        blackView.insertSubview(thankYouText, belowSubview: smallScreenView)
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[thankYouText]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["thankYouText":thankYouText]))
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[thankYouText]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["thankYouText":thankYouText]))
        
        UIView.animateWithDuration(0.5, delay: 3.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            
            thankYouText.alpha = 0.0
            
            }) { (finished) -> Void in
                
                thankYouText.removeFromSuperview()
                
                let twoMoreQuestionsText = UILabel()
                twoMoreQuestionsText.translatesAutoresizingMaskIntoConstraints = false
                twoMoreQuestionsText.font = UIFont(name: "HelveticaNeue-Thin", size: 72.0)
                twoMoreQuestionsText.text = stringForKey("TwoMoreQuestions")
                twoMoreQuestionsText.textAlignment = .Center
                twoMoreQuestionsText.baselineAdjustment = .AlignCenters
                twoMoreQuestionsText.alpha = 0.0
                twoMoreQuestionsText.numberOfLines = 0
                twoMoreQuestionsText.textColor = .whiteColor()
                self.blackView.addSubview(twoMoreQuestionsText)
                self.blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[twoMoreQuestionsText]-(20)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["twoMoreQuestionsText":twoMoreQuestionsText]))
                self.blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[twoMoreQuestionsText]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["twoMoreQuestionsText":twoMoreQuestionsText]))
                
                UIView.animateWithDuration(0.5, delay: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                    
                    twoMoreQuestionsText.alpha = 1.0
                    
                    }, completion: { (finished) -> Void in
                        
                        UIView.animateWithDuration(0.5, delay: 5.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                            
                            twoMoreQuestionsText.alpha = 0.0
                            
                            }, completion: { (finished) -> Void in
                                
                                twoMoreQuestionsText.removeFromSuperview()
                                self.showColorChoice()
                                
                        })
                })
        }
    }
    
    private func showColorChoice()
    {
        let topQuestion = UILabel()
        topQuestion.translatesAutoresizingMaskIntoConstraints = false
        topQuestion.font = UIFont(name: "HelveticaNeue-Thin", size: 56.0)
        topQuestion.text = stringForKey("ColorQuestion")
        topQuestion.numberOfLines = 0
        topQuestion.textAlignment = .Center
        topQuestion.baselineAdjustment = .AlignCenters
        topQuestion.alpha = 0.0
        topQuestion.textColor = .whiteColor()
        blackView.addSubview(topQuestion)
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[topQuestion]-(20)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["topQuestion":topQuestion]))
        blackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topQuestion]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["topQuestion":topQuestion]))
        
        setUpSmallColorChoice()
        
        UIView.animateWithDuration(0.5, delay: 0.5, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            
            topQuestion.alpha = 1.0
            
            }, completion:nil)
    }
    
    private func setUpSmallColorChoice()
    {
        
    }
    
    /*
    func showBreakingNewsLabel()
    {
    let breakingNewsLabel = BreakingNewsLabel(frame: CGRectMake(0, 0, 150, 60))
    breakingNewsLabel.textAlignment = .Center
    breakingNewsLabel.text = "News"
    breakingNewsLabel.textColor = primaryColor
    breakingNewsLabel.font = UIFont(name: "Marker Felt", size: 26)
    breakingNewsLabel.numberOfLines = 0
    breakingNewsLabel.center = CGPointMake(view.frame.size.width + breakingNewsLabel.frame.size.width/2.0, newsFeed!.center.y)
    breakingNewsLabel.layer.shouldRasterize = true
    breakingNewsLabel.layer.rasterizationScale = UIScreen.mainScreen().scale
    breakingNewsLabel.layer.shadowOpacity = 1.0
    breakingNewsLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0)
    Definitions.outlineTextInLabel(breakingNewsLabel)
    view.addSubview(breakingNewsLabel)
    
    UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .AllowAnimatedContent, animations: { () -> Void in
    
    breakingNewsLabel.center = CGPointMake(breakingNewsLabel.frame.size.width * 0.3, breakingNewsLabel.center.y)
    
    }, completion: { (finished) -> Void in
    self.newsFeed.startFeed()
    })
    }*/
}
*/
private class MiniScreenView : UIView
{
    var actionHandler : (() -> Void)!
    
    private func selectView()
    {
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.85, 0.85)
            }, completion: nil)
    }
    
    private func deSelectView()
    {
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    private override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        selectView()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first!
        if CGRectContainsPoint(bounds, touch.locationInView(self))
        {
            if CGRectContainsPoint(bounds, touch.previousLocationInView(self)) == false
            {
                selectView()
            }
        }
        else
        {
            if CGRectContainsPoint(bounds, touch.previousLocationInView(self))
            {
                deSelectView()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first!
        if CGRectContainsPoint(bounds, touch.locationInView(self))
        {
            actionHandler()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        deSelectView()
    }
}
