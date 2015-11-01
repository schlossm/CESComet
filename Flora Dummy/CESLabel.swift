//
//  CESLabel.swift
//  CES
//
//  Created by Michael Schloss on 10/1/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit

extension UILabel
{
    class func outlineLabel(label: UILabel)
    {
        label.layer.shadowColor = UIColor.blackColor().CGColor
        label.layer.shadowOffset = CGSizeMake(0.1, 0.1)
        label.layer.shadowOpacity = 1.0
        label.layer.shadowRadius = 1.0
    }
}

@IBDesignable
class CESOutlinedLabel: UILabel
{
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
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(0.1, 0.1)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 1.0
    }
}
