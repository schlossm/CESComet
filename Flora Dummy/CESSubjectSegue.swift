//
//  CESSubjectSegue.swift
//  CES
//
//  Created by Michael Schloss on 10/31/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit

class CESSubjectSegue: UIStoryboardSegue
{
    var sourceRect : CGRect!
    var sourceView : UIView!
    
    override func perform()
    {
        let sourceVCView = sourceViewController.view
        let destVCView = destinationViewController.view
        
        (destinationViewController as! SubjectVC).sourceRect = sourceRect
        (destinationViewController as! SubjectVC).sourceView = sourceView
        
        let convertedRect = sourceVCView.convertRect(sourceRect, fromView: sourceView)
        
        let deltaX = sourceVCView.frame.midX - convertedRect.midX
        let deltaY = sourceVCView.frame.midY - convertedRect.midY
        
        let deltaHeight = sourceVCView.frame.height / convertedRect.height
        let deltaWidth = sourceVCView.frame.width / convertedRect.width
        
        UIApplication.sharedApplication().keyWindow?.addSubview(destVCView)
        destVCView.frame = sourceVCView.frame
        destVCView.alpha = 0.0
        destVCView.transform = CGAffineTransformMakeTranslation(-deltaX, -deltaY)
        destVCView.transform = CGAffineTransformScale(destVCView.transform, 1/deltaWidth, 1/deltaHeight)
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: .AllowAnimatedContent, animations: { () -> Void in
            sourceVCView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(deltaX, deltaY), CGAffineTransformMakeScale(deltaWidth, deltaHeight))
            destVCView.transform = CGAffineTransformIdentity
            destVCView.alpha = 1.0
            }) { (finished) -> Void in
                self.sourceViewController.presentViewController(self.destinationViewController, animated: false, completion: nil)
        }
    }
}
