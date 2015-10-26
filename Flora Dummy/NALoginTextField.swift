//
//  NALoginTextField.swift
//  NicholsApp
//
//  Created by Michael Schloss on 6/27/15.
//  Copyright © 2015 Michael Schloss. All rights reserved.
//

import UIKit

class NALoginTextField: UITextField
{
    @IBInspectable
    var image : UIImage!
        {
        didSet
        {
            imageView = UIImageView(frame: CGRectMake(0, 0, min(frame.size.height, frame.size.width), min(frame.size.height, frame.size.width)))
            imageView.tintColor = UIColor.blackColor()
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            imageView.image = image
            leftView = imageView
        }
    }
    
    var imageView : UIImageView!
    
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
        backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        
        leftViewMode = .Always
        
        layer.cornerRadius = 10.0
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        imageView?.frame = CGRectMake(0, 0, min(frame.size.height, frame.size.width), min(frame.size.height, frame.size.width))
    }
}
