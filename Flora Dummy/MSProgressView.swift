//
//  MSProgressView.swift
//
//
//  Created by Michael Schloss on 4/22/15.
//  Copyright (c) 2015 Michael Schloss. All rights reserved.
//

import UIKit

extension UIColor
{
    var lighter : UIColor
        {
        get
        {
            var alpha : CGFloat = 0.0
            var red : CGFloat = 0.0
            var green : CGFloat = 0.0
            var blue : CGFloat = 0.0
            
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return UIColor(red: red + 0.1, green: green + 0.1, blue: blue + 0.1, alpha: alpha)
        }
    }
}

@IBDesignable
class MSProgressView: UIView
{
    ///The color of the progress bar.  Setting this value will automatically animate the color change
    ///
    ///The default color is white.
    @IBInspectable
    var barColor : UIColor = UIColor.whiteColor()
        {
        didSet
        {
            let color = progressLayer.strokeColor
            progressLayer.strokeColor = barColor.CGColor
            let barColorAnimation = CABasicAnimation(keyPath: "lineWidth")
            barColorAnimation.fromValue = NSValue(nonretainedObject: color)
            barColorAnimation.toValue = NSValue(nonretainedObject: barColor.CGColor)
            barColorAnimation.fillMode = kCAFillModeForwards
            barColorAnimation.duration = 0.5
            barColorAnimation.removedOnCompletion = false
            progressLayer.addAnimation(barColorAnimation, forKey: "barColorAnimation")
        }
    }
    
    ///The width of the progress bar.  Setting this value will automatically animate the width change
    ///
    ///The default width is 5.0
    @IBInspectable
    var barWidth : CGFloat = 5.0
        {
        didSet
        {
            let lineWidth = progressLayer.lineWidth
            progressLayer.lineWidth = barWidth
            let barWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
            barWidthAnimation.fromValue = lineWidth
            barWidthAnimation.toValue = barWidth
            barWidthAnimation.fillMode = kCAFillModeForwards
            barWidthAnimation.duration = 0.5
            barWidthAnimation.removedOnCompletion = false
            progressLayer.addAnimation(barWidthAnimation, forKey: "barWidthAnimation")
        }
    }
    
    private var progressLayer : CAShapeLayer!
    private var progressBar: UIBezierPath!
    private var progress : CGFloat = 0.0
    var currentProgress : CGFloat
        {
        get
        {
            return progress
        }
    }
    
    private var isComplete = false
    private var isRotating = false
    
    override func drawRect(rect: CGRect)
    {
        progressBar = UIBezierPath(arcCenter: CGPointMake(progressLayer.bounds.size.width/2.0, progressLayer.bounds.height/2.0), radius: rect.size.width/2.0, startAngle: 0.0, endAngle: CGFloat(2.0 * M_PI), clockwise: true)
        progressLayer.path = progressBar.CGPath
        layer.addSublayer(progressLayer)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        backgroundColor = .clearColor()
        layer.backgroundColor = UIColor.clearColor().CGColor
        
        progressLayer = CAShapeLayer()
        progressLayer.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height)
        progressLayer.strokeColor = barColor.CGColor
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.lineWidth = barWidth
        progressLayer.strokeEnd = 0.9
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        backgroundColor = .clearColor()
        layer.backgroundColor = UIColor.clearColor().CGColor
        
        progressLayer = CAShapeLayer()
        progressLayer.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height)
        progressLayer.strokeColor = barColor.CGColor
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.lineWidth = barWidth
        progressLayer.strokeEnd = 0.9
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        progressLayer.bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height)
        progressLayer.anchorPoint = CGPointMake(0.5, 0.5)
        progressLayer.position = CGPoint(x: bounds.size.width/2.0, y: bounds.size.height/2.0)
    }
    
    func startAnimating(animated: Bool)
    {
        guard isComplete == false else
        {
            return
        }
        
        if animated == false
        {
            alpha = 1.0
        }
        isRotating = true
        let transform = progressLayer.transform
        progressLayer.transform = CATransform3DRotate(progressLayer.transform, CGFloat((M_PI) - 0.001), 0.0, 0.0, 1.0)
        let rotationAnimation = CABasicAnimation(keyPath: "transform")
        rotationAnimation.delegate = self
        rotationAnimation.fromValue = NSValue(CATransform3D: transform)
        rotationAnimation.toValue = NSValue(CATransform3D: CATransform3DRotate(transform, CGFloat((M_PI) - 0.001), 0.0, 0.0, 1.0))
        rotationAnimation.fillMode = kCAFillModeForwards
        rotationAnimation.duration = 0.5
        rotationAnimation.removedOnCompletion = false
        progressLayer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func stopAnimating(animated: Bool)
    {
        isRotating = false
        if animated == false
        {
            alpha = 0.0
        }
        progressLayer.removeAnimationForKey("rotationAnimation")
    }
    
    func setProgress(newProgress: CGFloat)
    {
        isRotating = false
        alpha = 1.0
        if progressLayer.animationForKey("rotationAnimation") != nil
        {
            progressLayer.removeAnimationForKey("rotationAnimation")
            UIView.animateWithDuration(0.2, delay: 0.0, options: .AllowUserInteraction, animations: { () -> Void in
                self.progressLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 3.0/2.0), 0.0, 0.0, 1.0)
                }, completion: nil)
        }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progress
        animation.toValue = newProgress
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        progressLayer.addAnimation(animation, forKey: "strokeEndChange")
        progress = newProgress
        progressLayer.strokeEnd = newProgress
    }
    
    func showComplete()
    {
        guard isComplete == false else
        {
            return
        }
        
        isComplete = true
        
        isRotating = false
        if progressLayer.animationForKey("rotationAnimation") != nil
        {
            progressLayer.removeAnimationForKey("rotationAnimation")
            UIView.animateWithDuration(0.2, delay: 0.0, options: .AllowUserInteraction, animations: { () -> Void in
                self.progressLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 3.0/2.0), 0.0, 0.0, 1.0)
                }, completion: nil)
        }
        
        let greenView = UIView()
        greenView.translatesAutoresizingMaskIntoConstraints = false
        greenView.backgroundColor = UIColor.greenColor().lighter
        addSubview(greenView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[greenView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["barWidth":barWidth], views: ["greenView":greenView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[greenView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["barWidth":barWidth], views: ["greenView":greenView]))
        greenView.layer.cornerRadius = frame.size.width/2.0
        
        let bezierPath = UIBezierPath()
        bezierPath.lineCapStyle = .Round
        bezierPath.moveToPoint(CGPointMake(0.27083 * CGRectGetWidth(frame), 0.54167 * CGRectGetHeight(frame)))
        bezierPath.addLineToPoint(CGPointMake(0.41667 * CGRectGetWidth(frame), 0.68750 * CGRectGetHeight(frame)))
        bezierPath.addLineToPoint(CGPointMake(0.75000 * CGRectGetWidth(frame), 0.35417 * CGRectGetHeight(frame)))
        
        let greenViewShapeLayer = CAShapeLayer()
        greenViewShapeLayer.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height)
        greenViewShapeLayer.path = bezierPath.CGPath
        greenViewShapeLayer.strokeColor = UIColor.whiteColor().CGColor
        greenViewShapeLayer.fillColor = UIColor.clearColor().CGColor
        greenViewShapeLayer.lineWidth = 3.0
        greenView.layer.addSublayer(greenViewShapeLayer)
        greenViewShapeLayer.anchorPoint = CGPointMake(0, 0)
        
        layoutIfNeeded()
        greenView.transform = CGAffineTransformMakeScale(0.0, 0.0)
        greenViewShapeLayer.strokeStart = 0.5
        greenViewShapeLayer.strokeEnd = 0.5
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { () -> Void in
            greenViewShapeLayer.strokeStart = 0.5
            greenViewShapeLayer.strokeEnd = 0.5
            self.progressLayer.opacity = 0.0
            greenView.transform = CGAffineTransformIdentity
            }) { (finished) -> Void in
                
                greenViewShapeLayer.strokeStart = 0.5
                greenViewShapeLayer.strokeEnd = 0.5
                
                let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
                strokeStartAnimation.fromValue = 0.5
                strokeStartAnimation.toValue = 0.0
                strokeStartAnimation.duration = 0.3
                strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                greenViewShapeLayer.addAnimation(strokeStartAnimation, forKey: "greenLayerstrokeStartChange")
                greenViewShapeLayer.strokeStart = 0.0
                let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
                strokeEndAnimation.fromValue = 0.5
                strokeEndAnimation.toValue = 1.0
                strokeEndAnimation.duration = 0.3
                strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                greenViewShapeLayer.addAnimation(strokeEndAnimation, forKey: "greenLayerstrokeEndChange")
                greenViewShapeLayer.strokeEnd = 1.0
                
        }
    }
    
    func showIncomplete()
    {
        guard isComplete == false else
        {
            return
        }
        
        isComplete = true
        
        isRotating = false
        if progressLayer.animationForKey("rotationAnimation") != nil
        {
            progressLayer.removeAnimationForKey("rotationAnimation")
            UIView.animateWithDuration(0.2, delay: 0.0, options: .AllowUserInteraction, animations: { () -> Void in
                self.progressLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 3.0/2.0), 0.0, 0.0, 1.0)
                }, completion: nil)
        }
        
        let redView = UIView()
        redView.translatesAutoresizingMaskIntoConstraints = false
        redView.backgroundColor = UIColor.redColor().lighter
        addSubview(redView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[greenView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["barWidth":barWidth], views: ["greenView":redView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[greenView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["barWidth":barWidth], views: ["greenView":redView]))
        redView.layer.cornerRadius = frame.size.width/2.0
        
        let firstBezierPath = UIBezierPath()
        firstBezierPath.lineCapStyle = .Round
        firstBezierPath.moveToPoint(CGPointMake(0.27083 * CGRectGetWidth(frame), 0.27083 * CGRectGetHeight(frame)))
        firstBezierPath.addLineToPoint(CGPointMake(0.72917 * CGRectGetWidth(frame), 0.72917 * CGRectGetHeight(frame)))
        
        let firstRedViewShapeLayer = CAShapeLayer()
        firstRedViewShapeLayer.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height)
        firstRedViewShapeLayer.path = firstBezierPath.CGPath
        firstRedViewShapeLayer.strokeColor = UIColor.whiteColor().CGColor
        firstRedViewShapeLayer.fillColor = UIColor.clearColor().CGColor
        firstRedViewShapeLayer.lineWidth = 3.0
        redView.layer.addSublayer(firstRedViewShapeLayer)
        firstRedViewShapeLayer.anchorPoint = CGPointMake(0, 0)
        
        let secondBezierPath = UIBezierPath()
        secondBezierPath.lineCapStyle = .Round
        secondBezierPath.moveToPoint(CGPointMake(0.27083 * CGRectGetWidth(frame), 0.72917 * CGRectGetHeight(frame)))
        secondBezierPath.addLineToPoint(CGPointMake(0.72917 * CGRectGetWidth(frame), 0.27083 * CGRectGetHeight(frame)))
        
        let secondRedViewShapeLayer = CAShapeLayer()
        secondRedViewShapeLayer.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height)
        secondRedViewShapeLayer.path = secondBezierPath.CGPath
        secondRedViewShapeLayer.strokeColor = UIColor.whiteColor().CGColor
        secondRedViewShapeLayer.fillColor = UIColor.clearColor().CGColor
        secondRedViewShapeLayer.lineWidth = 3.0
        redView.layer.addSublayer(secondRedViewShapeLayer)
        secondRedViewShapeLayer.anchorPoint = CGPointMake(0, 0)
        
        layoutIfNeeded()
        redView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        redView.transform = CGAffineTransformMakeScale(0.0, 0.0)
        firstRedViewShapeLayer.strokeStart = 0.5
        firstRedViewShapeLayer.strokeEnd = 0.5
        secondRedViewShapeLayer.strokeStart = 0.5
        secondRedViewShapeLayer.strokeEnd = 0.5
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { () -> Void in
            
            firstRedViewShapeLayer.strokeStart = 0.5
            firstRedViewShapeLayer.strokeEnd = 0.5
            secondRedViewShapeLayer.strokeStart = 0.5
            secondRedViewShapeLayer.strokeEnd = 0.5
            
            self.progressLayer.opacity = 0.0
            redView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            
            }) { (finished) -> Void in
                
                firstRedViewShapeLayer.strokeStart = 0.5
                firstRedViewShapeLayer.strokeEnd = 0.5
                secondRedViewShapeLayer.strokeStart = 0.5
                secondRedViewShapeLayer.strokeEnd = 0.5
                
                let firstStrokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
                firstStrokeStartAnimation.fromValue = 0.5
                firstStrokeStartAnimation.toValue = 0.0
                firstStrokeStartAnimation.duration = 0.3
                firstStrokeStartAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                firstRedViewShapeLayer.addAnimation(firstStrokeStartAnimation, forKey: "redLayerstrokeStartChange")
                firstRedViewShapeLayer.strokeStart = 0.0
                let firstStrokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
                firstStrokeEndAnimation.fromValue = 0.5
                firstStrokeEndAnimation.toValue = 1.0
                firstStrokeEndAnimation.duration = 0.3
                firstStrokeEndAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                firstRedViewShapeLayer.addAnimation(firstStrokeEndAnimation, forKey: "redLayerstrokeEndChange")
                firstRedViewShapeLayer.strokeEnd = 1.0
                
                let secondStrokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
                secondStrokeStartAnimation.fromValue = 0.5
                secondStrokeStartAnimation.toValue = 0.0
                secondStrokeStartAnimation.duration = 0.3
                secondStrokeStartAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                secondRedViewShapeLayer.addAnimation(secondStrokeStartAnimation, forKey: "redLayerstrokeStartChange")
                secondRedViewShapeLayer.strokeStart = 0.0
                let secondStrokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
                secondStrokeEndAnimation.fromValue = 0.5
                secondStrokeEndAnimation.toValue = 1.0
                secondStrokeEndAnimation.duration = 0.3
                secondStrokeEndAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                secondRedViewShapeLayer.addAnimation(secondStrokeEndAnimation, forKey: "redLayerstrokeEndChange")
                secondRedViewShapeLayer.strokeEnd = 1.0
        }
    }
    
    func reset()
    {
        progressLayer.opacity = 1.0
        progressBar = UIBezierPath(arcCenter: CGPointMake(progressLayer.bounds.size.width/2.0, progressLayer.bounds.height/2.0), radius: frame.size.width/2.0, startAngle: 0.0, endAngle: CGFloat(2.0 * M_PI), clockwise: true)
        progressLayer.path = progressBar.CGPath
        
        for subview in subviews
        {
            subview.removeFromSuperview()
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool)
    {
        if isRotating
        {
            startAnimating(true)
        }
    }
}