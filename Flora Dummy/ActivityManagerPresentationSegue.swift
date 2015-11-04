//
//  ActivityManagerPresentationSegue.swift
//  CES
//
//  Created by Michael Schloss on 11/1/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit
/*
UIView.animateWithDuration(1.5, delay: 1.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .AllowAnimatedContent, animations: { [unowned self] () -> Void in

activityLoadingView.transform = CGAffineTransformMakeScale(self.view.frame.size.width/activityLoadingView.frame.size.width, self.view.frame.size.height/activityLoadingView.frame.size.height)
activityLoadingView.effect = nil
activityLoadingView.contentView.alpha = 0.0

}, completion: { [unowned self] (finished) -> Void in

loadingWheel.stopAnimating(true)
activityLoadingView.removeFromSuperview()
self.view.userInteractionEnabled = true
})*/

class ActivityManagerPresentationSegue: UIStoryboardSegue
{
    var sourceView : UIView!
    
    override func perform()
    {
        let sourceVCView = sourceViewController.view
        let destVCView = destinationViewController.view
        
        let deltaX = sourceVCView.frame.midX - sourceView.frame.midX
        let deltaY = sourceVCView.frame.midY - sourceView.frame.midY
        
        let deltaHeight = sourceVCView.frame.height / sourceView.frame.height
        let deltaWidth = sourceVCView.frame.width / sourceView.frame.width
        
        UIApplication.sharedApplication().keyWindow?.addSubview(destVCView)
        destVCView.frame = sourceVCView.frame
        destVCView.alpha = 0.0
        destVCView.transform = CGAffineTransformMakeTranslation(-deltaX, -deltaY)
        destVCView.transform = CGAffineTransformScale(destVCView.transform, 1/deltaWidth, 1/deltaHeight)
        
        UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, usingSpringWithDamping: 0.77, initialSpringVelocity: 0.9, options: .AllowAnimatedContent, animations: { [unowned self] () -> Void in
            self.sourceView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(deltaX, deltaY), CGAffineTransformMakeScale(deltaWidth, deltaHeight))
            destVCView.transform = CGAffineTransformIdentity
            destVCView.alpha = 1.0
            }) { (finished) -> Void in
                for subview in self.sourceView.subviews
                {
                    if subview.classForCoder == NSClassFromString("_UIVisualEffectContentView")
                    {
                        for subviewSubview in subview.subviews
                        {
                            for subviewSubviewSubview in subviewSubview.subviews
                            {
                                if subviewSubviewSubview.classForCoder == MSProgressView.classForCoder()
                                {
                                    (subviewSubviewSubview as! MSProgressView).stopAnimating(true)
                                }
                            }
                        }
                    }
                }
                destVCView.userInteractionEnabled = true
                self.sourceView.removeFromSuperview()
                self.sourceViewController.presentViewController(self.destinationViewController, animated: false, completion: nil)
        }
    }
}