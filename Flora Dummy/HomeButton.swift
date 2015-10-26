//
//  HomeButton.swift
//  FloraDummy
//
//  Created by Michael Schloss on 4/11/15.
//  Copyright (c) 2015 SGSC. All rights reserved.
//

import UIKit

class HomeButton: UIView
{
    private var _iconImage  : UIImage!
    var iconImage           : UIImage!
        {
        get
        {
            return _iconImage
        }
        set
        {
            _iconImage = newValue
            
            if icon != nil
            {
                icon.image = newValue
            }
        }
    }
    
    private var _title      : String!
    var title               : String!
        {
        get
        {
            return _title
        }
        set
        {
            _title = newValue
            
            if titleLabel != nil
            {
                titleLabel.text = newValue
            }
        }
    }
    
    var actionHandler : (() -> Void)!
    
    var oldBackgroundColor : UIColor!
    
    var icon        : UIImageView!
    var titleLabel  : UILabel!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .blackColor()
        icon.image = _iconImage
        icon.contentMode = .ScaleAspectFit
        icon.layer.shouldRasterize = true
        icon.layer.rasterizationScale = UIScreen.mainScreen().scale
        icon.layer.cornerRadius = 20.0
        icon.layer.borderWidth = 3.0
        addSubview(icon)
        addConstraint(NSLayoutConstraint(item: icon, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        titleLabel = CESOutlinedLabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = _title
        titleLabel.textAlignment = .Center
        titleLabel.font = bodyFont
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.1
        addSubview(titleLabel)
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[titleLabel(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height":titleLabel.font.lineHeight], views: ["titleLabel":titleLabel]))
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    private func highlight()
    {
        icon.backgroundColor = UIColor.clearColor().darker.darker
    }
    
    private func animateHighlight()
    {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            
            self.icon.backgroundColor = UIColor.clearColor().darker.darker
            
        }, completion: nil)
    }
    
    private func unHighlight()
    {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
            
            self.icon.backgroundColor = self.icon.backgroundColor?.lighter.lighter
            
            }, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        highlight()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first!
        if CGRectContainsPoint(bounds, touch.locationInView(self))
        {
            if CGRectContainsPoint(bounds, touch.previousLocationInView(self)) == false
            {
                animateHighlight()
            }
        }
        else
        {
            if CGRectContainsPoint(bounds, touch.previousLocationInView(self))
            {
                unHighlight()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        unHighlight()
        
        let touch = touches.first!
        if CGRectContainsPoint(bounds, touch.locationInView(self))
        {
            actionHandler()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        unHighlight()
    }
}
