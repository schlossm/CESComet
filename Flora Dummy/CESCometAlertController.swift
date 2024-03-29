//
//  CESCometAlertController.swift
//  FloraDummy
//
//  Created by Michael Schloss on 2/27/15.
//  Copyright (c) 2015 SGSC. All rights reserved.
//

import UIKit

@available(*, deprecated=9.0, message="CESCometAlertAction has been deprecated.  Use UIAlertAction instead")
class CESCometAlertAction : UIView
{
    var title : String!
    var handler : ((alertAction: CESCometAlertAction) -> Void)?
    var style : UIAlertActionStyle!
    
    var parentViewController : CESCometAlertController!
    
    init(title: String, style: UIAlertActionStyle, handler: ((alertAction: CESCometAlertAction) -> Void)?)
    {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        
        self.title = title
        self.handler = handler
        self.style = style
        
        backgroundColor = ColorScheme.currentColorScheme().backgroundColor.darker
        layer.cornerRadius = 10.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        userInteractionEnabled = true
        
        let titleLabel = CESOutlinedLabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = style != .Destructive ? ColorScheme.currentColorScheme().primaryColor : UIColor.redColor().lighter.lighter
        titleLabel.text = title
        titleLabel.textAlignment = .Center
        titleLabel.minimumScaleFactor = 0.1
        titleLabel.adjustsFontSizeToFitWidth = true
        if style != .Cancel
        {
            titleLabel.font = UIFont(name: "Marker Felt", size: 32)
        }
        else
        {
            titleLabel.font = UIFont(name: "MarkerFelt-Wide", size: 32)
        }
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.rasterizationScale = UIScreen.mainScreen().scale
        addSubview(titleLabel)
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    private var shouldExpand = false
    
    private func expandButton()
    {
        UIView.animateWithDuration(0.3, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction, .CurveEaseIn], animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.1, 1.1)
            }, completion: { (finished) -> Void in
                self.normalizeButton()
        })
    }
    
    private func normalizeButton()
    {
        UIView.animateWithDuration(0.3, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction, .CurveEaseOut], animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            }, completion: { (finished) -> Void in
                if self.shouldExpand == true
                {
                    self.expandButton()
                }
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        shouldExpand = true
        expandButton()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let boundsExtension = 5
        let outerBounds = CGRectInset(bounds, CGFloat(0 - boundsExtension), CGFloat(0 - boundsExtension))
        let touchedInside = CGRectContainsPoint(outerBounds, (touches.first! ).locationInView(self))
        let previouslyTouchedInside = CGRectContainsPoint(outerBounds, (touches.first! ).previousLocationInView(self))
        
        if touchedInside
        {
            if previouslyTouchedInside == false
            {
                shouldExpand = true
                expandButton()
            }
        }
        else
        {
            if previouslyTouchedInside
            {
                shouldExpand = false
                normalizeButton()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        shouldExpand = false
        normalizeButton()
        
        let boundsExtension = 5
        let outerBounds = CGRectInset(bounds, CGFloat(0 - boundsExtension), CGFloat(0 - boundsExtension))
        let touchedInside = CGRectContainsPoint(outerBounds, (touches.first! ).locationInView(self))
        
        if touchedInside == true
        {
            parentViewController.dismissViewControllerAnimated(true, completion: nil)
            handler?(alertAction: self)
        }
    }
    
}

@available(*, deprecated=9.0, message="CESCometAlertController has been deprecated.  Use UIAlertController instead")
class CESCometAlertController: FormattedVC, UIViewControllerTransitioningDelegate
{
    private var displayTitle : String!
    private var displayMessage : String?
    private var displayStyle: UIAlertControllerStyle!
    
    private var actions = Array<CESCometAlertAction>()
    
    private var backgroundView : UIView!
    private var alertView : UIView!
    
    init(title: String, message: String?, style: UIAlertControllerStyle)
    {
        super.init(nibName: nil, bundle: nil)
        
        self.displayTitle = title
        self.displayMessage = message
        self.displayStyle = style
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .Custom
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .clearColor()
        
        backgroundView = UIView()
        backgroundView.alpha = 0.0
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        backgroundView.layer.rasterizationScale = UIScreen.mainScreen().scale
        backgroundView.layer.shouldRasterize = true
        view.addSubview(backgroundView)
        view.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        
        let alertViewWidth = CGFloat(400.0)
        
        alertView = UIView()
        alertView.clipsToBounds = true
        alertView.backgroundColor = ColorScheme.currentColorScheme().backgroundColor
        alertView.layer.cornerRadius = 10.0
        alertView.layer.shouldRasterize = true
        alertView.layer.rasterizationScale = UIScreen.mainScreen().scale
        view.addSubview(alertView)
        
        switch displayStyle as UIAlertControllerStyle
        {
        case .ActionSheet:
            
            break
            
        case .Alert:
            let titleLabel = CESOutlinedLabel()
            titleLabel.textColor = ColorScheme.currentColorScheme().primaryColor
            titleLabel.text = displayTitle
            titleLabel.minimumScaleFactor = 0.1
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.font = UIFont(name: "MarkerFelt-Wide", size: 36)
            titleLabel.layer.shouldRasterize = true
            titleLabel.layer.rasterizationScale = UIScreen.mainScreen().scale
            alertView.addSubview(titleLabel)
            
            if displayMessage == nil
            {
                alertView.frame = CGRectMake(0, 0, alertViewWidth, titleLabel.font.lineHeight + 40)
                
                titleLabel.center = CGPointMake(alertView.frame.width/2.0, alertView.frame.size.height/2.0)
            }
            else
            {
                let messageLabel = CESOutlinedLabel(frame: CGRectMake(0, 0, alertViewWidth, 0))
                messageLabel.textColor = ColorScheme.currentColorScheme().primaryColor
                messageLabel.text = displayMessage
                messageLabel.textAlignment = .Center
                messageLabel.numberOfLines = 0
                messageLabel.minimumScaleFactor = 0.1
                messageLabel.adjustsFontSizeToFitWidth = true
                messageLabel.font = UIFont(name: "Marker Felt", size: 22)
                messageLabel.layer.shouldRasterize = true
                messageLabel.layer.rasterizationScale = UIScreen.mainScreen().scale
                messageLabel.frame.size = messageLabel.sizeThatFits(CGSizeMake(alertViewWidth, view.frame.size.height - 300))
                alertView.addSubview(messageLabel)
                
                alertView.frame = CGRectMake(0, 0, alertViewWidth, 20 + titleLabel.frame.size.height + 30 + messageLabel.frame.size.height + 20)
                titleLabel.center = CGPointMake(alertView.frame.width/2.0, 20 + titleLabel.frame.size.height/2.0)
                messageLabel.center = CGPointMake(alertView.frame.size.width/2.0, titleLabel.frame.size.height + titleLabel.frame.origin.y + 30 + messageLabel.frame.size.height/2.0)
            }
            break
        }
        
        //Setup Actions
        
        if actions.count == 1
        {
            actions[0].frame = CGRectMake(0, 0, alertView.frame.size.width - 40.0, 50)
            let lowestLabel = alertView.subviews.last as! UILabel
            actions[0].center = CGPointMake(alertView.frame.size.width/2.0, lowestLabel.frame.size.height + lowestLabel.frame.origin.y + 30 + actions[0].frame.size.height/2.0)
            alertView.addSubview(actions[0])
            alertView.frame.size.height = actions[0].frame.origin.y + actions[0].frame.size.height + 20.0
        }
        else if actions.count == 2
        {
            actions[0].frame = CGRectMake(0, 0, (alertView.frame.size.width - 60.0)/2.0, 50)
            actions[1].frame = CGRectMake(0, 0, (alertView.frame.size.width - 60.0)/2.0, 50)
            let lowestLabel = alertView.subviews.last as! UILabel
            actions[0].center = CGPointMake(20 + actions[0].frame.size.width/2.0, lowestLabel.frame.size.height + lowestLabel.frame.origin.y + 30 + actions[0].frame.size.height/2.0)
            actions[1].center = CGPointMake(actions[0].frame.size.width + actions[0].frame.origin.x + 20 + actions[1].frame.size.width/2.0, actions[0].center.y)
            alertView.addSubview(actions[0])
            alertView.addSubview(actions[1])
            alertView.frame.size.height = actions[0].frame.origin.y + actions[0].frame.size.height + 20.0
        }
        else
        {
            actions[0].frame = CGRectMake(0, 0, alertView.frame.size.width - 40.0, 50)
            let lowestLabel = alertView.subviews.last as! UILabel
            actions[0].center = CGPointMake(alertView.frame.size.width/2.0, lowestLabel.frame.size.height + lowestLabel.frame.origin.y + 30 + actions[0].frame.size.height/2.0)
            alertView.addSubview(actions[0])
            alertView.frame.size.height = actions[0].frame.origin.y + actions[0].frame.size.height + 20.0
            
            for index in 1...actions.count - 1
            {
                actions[index].frame = CGRectMake(0, 0, alertView.frame.size.width - 40.0, 50)
                actions[index].center = CGPointMake(alertView.frame.size.width/2.0, actions[index - 1].frame.size.height + actions[index - 1].frame.origin.y + 10 + actions[index].frame.size.height/2.0)
                alertView.addSubview(actions[index])
                alertView.frame.size.height = actions[index].frame.origin.y + actions[index].frame.size.height + 20.0
            }
        }
        
        alertView.center = view.center
    }
    
    func addAction(action: CESCometAlertAction)
    {
        action.parentViewController = self
        actions.append(action)
    }
    
    override func updateColors()
    {
        super.updateColors()
        
        view.backgroundColor = .clearColor()
        
        if alertView != nil
        {
            UIView.animateWithDuration(0.3, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                
                self.alertView.backgroundColor = ColorScheme.currentColorScheme().backgroundColor
                
                }, completion: nil)
        }
    }
    
    
    /*
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return CESCometAlertControllerPresentedPresentation()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return CESCometAlertControllerDismissalPresentation()
    }*/
}

/*
@available(*, unavailable)
class CESCometAlertControllerPresentedPresentation : NSObject, UIViewControllerAnimatedTransitioning
{
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    {
        return 0.5
    }
    
    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as! CESCometAlertController
        let presentingController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let containerView = transitionContext.containerView()!
        
        containerView.addSubview(presentedController.view)
        
        presentedController.alertView.transform = CGAffineTransformMakeScale(0.7, 0.7)
        presentedController.alertView.alpha = 0.0
        
        for subview in presentedController.alertView.subviews 
        {
            if subview.classForCoder === CESCometAlertAction.classForCoder()
            {
                subview.transform = CGAffineTransformMakeScale(0.7, 0.7)
                subview.alpha = 0.0
            }
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: .AllowAnimatedContent, animations: { () -> Void in
            
            presentedController.backgroundView.alpha = 1.0
            
            }, completion: nil)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: transitionDuration(transitionContext)/2.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .AllowAnimatedContent, animations: { () -> Void in
            
            presentedController.alertView.alpha = 1.0
            presentedController.alertView.transform = CGAffineTransformIdentity
            
            }, completion: nil)
        
        for subview in presentedController.alertView.subviews 
        {
            if subview.classForCoder === CESCometAlertAction.classForCoder()
            {
                let delay = (transitionDuration(transitionContext) + (Double((presentedController.alertView.subviews as NSArray).indexOfObject(subview) - 2) * 0.15))
                UIView.animateWithDuration(transitionDuration(transitionContext), delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .AllowAnimatedContent, animations: { () -> Void in
                    
                    subview.transform = CGAffineTransformIdentity
                    subview.alpha = 1.0
                    
                    }, completion: { (finished) -> Void in
                        
                        if subview == (presentedController.alertView.subviews ).last!
                        {
                            transitionContext.completeTransition(true)
                        }
                })
            }
        }
    }
}

@available(*, unavailable)
class CESCometAlertControllerDismissalPresentation : NSObject, UIViewControllerAnimatedTransitioning
{
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    {
        return 1.0
    }
    
    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let presentingController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as! CESCometAlertController
        let containerView = transitionContext.containerView()!
        
        containerView.addSubview(presentingController.view)
        
        for subview in presentingController.alertView.subviews 
        {
            if subview.classForCoder === CESCometAlertAction.classForCoder()
            {
                let delay = Double((presentingController.alertView.subviews as NSArray).indexOfObject(subview) - 2) * 0.15
                UIView.animateWithDuration(transitionDuration(transitionContext), delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .AllowAnimatedContent, animations: { () -> Void in
                    
                    subview.transform = CGAffineTransformMakeScale(1.8, 1.8)
                    subview.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                        
                        if subview == (presentingController.alertView.subviews ).last! && presentingController.alertView.subviews.count - 2 > 2
                        {
                            transitionContext.completeTransition(true)
                        }
                })
            }
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: transitionDuration(transitionContext)/2.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: .AllowAnimatedContent, animations: { () -> Void in
            
            presentingController.backgroundView.alpha = 0.0
            
            }, completion: nil)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: transitionDuration(transitionContext)/2.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .AllowAnimatedContent, animations: { () -> Void in
            
            presentingController.alertView.alpha = 0.0
            presentingController.alertView.transform = CGAffineTransformMakeScale(1.3, 1.3)
            
            }, completion: { (finished) -> Void in
                
                if presentingController.alertView.subviews.count - 2 <= 2
                {
                    transitionContext.completeTransition(true)
                }
        })
    }
}*/
