//
//  CESOutlinedView.swift
//  CES
//
//  Created by Michael Schloss on 10/1/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit

class CESOutlinedView: UIView
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
        layer.borderWidth = 2.0
        layer.borderColor = ColorScheme.currentColorScheme().secondaryColor.CGColor
    }
}
