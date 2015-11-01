//
//  CESSubjectUnwindSegue.swift
//  CES
//
//  Created by Michael Schloss on 10/31/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit

class CESSubjectUnwindSegue: UIStoryboardSegue
{
    var sourceRect : CGRect!
    var sourceView : UIView!
    
    override func perform()
    {
        let sourceVCView = sourceViewController.view
        let destVCView = destinationViewController.view
        
        UIApplication.sharedApplication().keyWindow?.insertSubview(destVCView, belowSubview: sourceVCView)
        destVCView.transform = CGAffineTransformIdentity
        destVCView.frame = sourceVCView.frame
        UIApplication.sharedApplication().keyWindow?.addSubview(sourceVCView)
        
        let convertedRect = destVCView.convertRect(sourceRect, fromView: sourceView)
        
        let deltaX = destVCView.frame.midX - convertedRect.midX
        let deltaY = destVCView.frame.midY - convertedRect.midY
        
        let deltaHeight = destVCView.frame.height / convertedRect.height
        let deltaWidth = destVCView.frame.width / convertedRect.width
        
        destVCView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(deltaX, deltaY), CGAffineTransformMakeScale(deltaWidth, deltaHeight))
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
            destVCView.transform = CGAffineTransformIdentity
            sourceVCView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1/deltaWidth, 1/deltaHeight), CGAffineTransformMakeTranslation(-deltaX, -deltaY))
            sourceVCView.alpha = 0.0
            }) { (finished) -> Void in
                self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
