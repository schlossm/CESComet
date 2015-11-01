//
//  HomeButton.swift
//  FloraDummy
//
//  Created by Michael Schloss on 4/11/15.
//  Copyright (c) 2015 SGSC. All rights reserved.
//

import UIKit

@IBDesignable
class HomeButton: UIView
{
    @IBInspectable
    var iconImage           : UIImage!
        {
        didSet
        {
            if icon != nil
            {
                icon.image = iconImage
            }
        }
    }
    
    @IBInspectable
    var title               : String!
        {
        didSet
        {
            if titleLabel != nil
            {
                titleLabel.text = title
            }
        }
    }
    
    var actionHandler : (() -> Void)!
    
    private var oldBackgroundColor : UIColor!
    
    private var icon        : UIImageView!
    var iconRect : CGRect
        {
        get
        {
            return icon.frame
        }
    }
    
    private var titleLabel  : UILabel!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        commonInit()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit()
    {
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = ColorScheme.currentColorScheme().secondaryColor
        icon.image = iconImage
        icon.contentMode = .ScaleAspectFit
        icon.layer.shouldRasterize = true
        icon.layer.rasterizationScale = UIScreen.mainScreen().scale
        icon.layer.cornerRadius = 20.0
        icon.layer.borderWidth = 3.0
        icon.layer.borderColor = ColorScheme.currentColorScheme().secondaryColor.CGColor
        addSubview(icon)
        addConstraint(NSLayoutConstraint(item: icon, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        titleLabel = CESOutlinedLabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = ColorScheme.currentColorScheme().secondaryColor
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.systemFontOfSize(26.0, weight: UIFontWeightBold)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.numberOfLines = 2
        addSubview(titleLabel)
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[icon][titleLabel]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height":titleLabel.font.lineHeight], views: ["icon":icon, "titleLabel":titleLabel]))
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
            
            self.icon.backgroundColor = UIColor.clearColor()
            
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
            actionHandler?()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        unHighlight()
    }
}
