//
//  DrawingVC.swift
//  FloraDummy
//
//  Created by Michael Schloss on 3/17/15.
//  Copyright (c) 2015 SGSC. All rights reserved.
//

import UIKit

private struct LineSegment
{
    var firstPoint : CGPoint
    var secondPoint : CGPoint
}

class DrawingVC: FormattedVC
{
    private var drawingView : DrawingView!
    private var instructionsLabel : UILabel!
    
    private var drawingViewOrientation = DrawingVCOrientation.Landscape
    
    private var instructions : String!
    private var cachedImage : UIImage!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        instructionsLabel = CESOutlinedLabel()
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.text = instructions
        instructionsLabel.textAlignment = .Center
        instructionsLabel.font = UIFont(name: "MarkerFelt-Wide", size: 32)
        instructionsLabel.numberOfLines = 0
        instructionsLabel.minimumScaleFactor = 0.1
        instructionsLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(instructionsLabel)
        view.addConstraint(NSLayoutConstraint(item: instructionsLabel, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: instructionsLabel, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: /*pageManagerParent.rightMargin*/0))
        view.addConstraint(NSLayoutConstraint(item: instructionsLabel, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: /*pageManagerParent.leftMargin*/0))
        view.addConstraint(NSLayoutConstraint(item: instructionsLabel, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant:/*pageManagerParent.topMargin*/20))
        
        drawingView = DrawingView()
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        drawingView.backgroundColor = .whiteColor()
        drawingView.cachedDrawing = cachedImage
        view.addSubview(drawingView)
        switch drawingViewOrientation
        {
        case .Landscape:
            view.addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: /*pageManagerParent.topMargin*/20))
            view.addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant:/*pageManagerParent.bottomMargin*/0))
            break
            
        case .Portrait:
            view.addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: /*pageManagerParent.topMargin*/20))
            view.addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: /*pageManagerParent.leftMargin*/0*2.0))
            view.addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: /*pageManagerParent.rightMargin*/0*2.0))
            view.addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant:/*pageManagerParent.bottomMargin*/0))
            break
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        updateColors()
    }
    
    override func restoreActivityState(object: AnyObject)
    {
        let arrayOfData = object as! Array<Dictionary<String, AnyObject>>
        
        //Restore Settings
        let settings = arrayOfData[0] as Dictionary<String, AnyObject>
        instructions = settings["Instructions"] as! String
        drawingViewOrientation = DrawingVCOrientation(rawValue: (settings["Orientation"] as! NSNumber).integerValue)!
        
        //If we have user data
        if arrayOfData.count > 1
        {
            //Restore User Data
            let userData = arrayOfData[1] as Dictionary<String, AnyObject>
            cachedImage = UIImage(data: NSData().dataFromHexString(userData["Drawing"] as! NSString as String))!
            
            //Update drawingView
            if drawingView != nil
            {
                drawingView.cachedDrawing = cachedImage
            }
        }
        
        view.layoutIfNeeded()
        NSNotificationCenter.defaultCenter().postNotificationName(PageManagerShouldContinuePresentation, object: nil)
    }
    
    override func saveActivityState() -> AnyObject
    {
        var returnArray = Array<Dictionary<String, AnyObject>>()
        
        //Save Settings
        var settings = Dictionary<String, AnyObject>()
        settings.updateValue(instructions, forKey: "Instructions")
        settings.updateValue(NSNumber(integer: drawingViewOrientation.rawValue), forKey: "Orientation")
        returnArray.append(settings)
        
        //Make sure we actually have userData to save
        if drawingView.cachedDrawing != nil
        {
            //Save User Data
            var userData = Dictionary<String, AnyObject>()
            userData.updateValue(UIImagePNGRepresentation(drawingView.cachedDrawing)!.hexRepresentationWithSpaces(true, capitals: false), forKey: "Drawing")
            returnArray.append(userData)
        }
        
        return returnArray
    }
    
    override func settings() -> [NSObject : AnyObject]
    {
        var settings = Dictionary<String, String>()
        
        //Settings
        settings.updateValue("String", forKey: "Instructions")
        settings.updateValue("Picker - Landscape, Portrait", forKey: "Orientation")
        
        return settings
    }
    
    override func updateColors()
    {
        super.updateColors()
        
        if instructionsLabel != nil
        {
            instructionsLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        }
    }
}

private class DrawingView : UIView
{
    private var path : UIBezierPath!
    var cachedDrawing : UIImage!
    private var points = [CGPoint](count: 5, repeatedValue: CGPointZero)
    private var pointsBuffer = [CGPoint](count: 100, repeatedValue: CGPointZero)
    
    private var counter = 0
    private var bufferIndex = 0
    private var touchMoved = false
    private var drawingQueue : dispatch_queue_t!
    
    private let FF : Float = 0.2
    private let LOWER : Float = 0.01
    private let UPPER : Float = 2.0
    
    private var isFirstTouchPoint = true
    private var lastLineSegment : LineSegment!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        multipleTouchEnabled = false
        path = UIBezierPath()
        path.lineWidth = 2.0
        
        drawingQueue = dispatch_queue_create("drawingQueue", nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    private override func drawRect(rect: CGRect)
    {
        cachedDrawing?.drawInRect(rect)
    }
    
    private override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        counter = 0
        bufferIndex = 0
        points[counter] = touches.first!.locationInView(self)
        touchMoved = false
        isFirstTouchPoint = true
    }
    
    private var lastWidth : Float!
    
    private override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        touchMoved = true
        counter++
        points[counter] = touches.first!.locationInView(self)
        if counter == 4
        {
            points[3] = CGPointMake((points[2].x + points[4].x)/2.0, (points[2].y + points[4].y)/2.0)
            pointsBuffer[bufferIndex] = points[0]
            pointsBuffer[bufferIndex + 1] = points[1]
            pointsBuffer[bufferIndex + 2] = points[2]
            pointsBuffer[bufferIndex + 3] = points[3]
            bufferIndex += 4
            
            dispatch_async(drawingQueue, { () -> Void in
                let offsetPath = UIBezierPath()
                if self.bufferIndex == 0
                {
                    return
                }
                
                var ls = [LineSegment](count: 4, repeatedValue: LineSegment(firstPoint: CGPointZero, secondPoint: CGPointZero))
                for var i = 0; i < self.bufferIndex; i += 4
                {
                    if self.isFirstTouchPoint
                    {
                        ls[0] = LineSegment(firstPoint: self.pointsBuffer[0], secondPoint: self.pointsBuffer[0])
                        offsetPath.moveToPoint(ls[0].firstPoint)
                        self.isFirstTouchPoint = false
                    }
                    else
                    {
                        ls[0] = self.lastLineSegment
                    }
                    
                    let frac1 = self.FF/self.clamp(self.lengthSquared(self.pointsBuffer[i], pointTwo: self.pointsBuffer[i+1]), lower: self.LOWER, higher: self.UPPER)
                    let frac2 = self.FF/self.clamp(self.lengthSquared(self.pointsBuffer[i+1], pointTwo: self.pointsBuffer[i+2]), lower: self.LOWER, higher: self.UPPER)
                    let frac3 = self.FF/self.clamp(self.lengthSquared(self.pointsBuffer[i+2], pointTwo: self.pointsBuffer[i+3]), lower: self.LOWER, higher: self.UPPER)
                    ls[1] = self.lineSegmentPerpendicularTo(LineSegment(firstPoint: self.pointsBuffer[i], secondPoint: self.pointsBuffer[i + 1]), ofRelativeLength: frac1)
                    ls[2] = self.lineSegmentPerpendicularTo(LineSegment(firstPoint: self.pointsBuffer[i + 1], secondPoint: self.pointsBuffer[i + 2]), ofRelativeLength: frac2)
                    ls[3] = self.lineSegmentPerpendicularTo(LineSegment(firstPoint: self.pointsBuffer[i + 2], secondPoint: self.pointsBuffer[i + 3]), ofRelativeLength: frac3)
                    
                    offsetPath.moveToPoint(ls[0].firstPoint)
                    offsetPath.addCurveToPoint(ls[3].firstPoint, controlPoint1: ls[1].firstPoint, controlPoint2: ls[2].firstPoint)
                    offsetPath.addLineToPoint(ls[3].secondPoint)
                    offsetPath.addCurveToPoint(ls[0].secondPoint, controlPoint1: ls[2].secondPoint, controlPoint2: ls[1].secondPoint)
                    offsetPath.closePath()
                    self.lastWidth = sqrtf(self.lengthSquared(ls[3].secondPoint, pointTwo: ls[3].firstPoint))
                    self.lastLineSegment = ls[3]
                }
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
                
                if self.cachedDrawing == nil
                {
                    let newPath = UIBezierPath(rect: self.bounds)
                    UIColor.whiteColor().setFill()
                    newPath.fill()
                }
                self.cachedDrawing?.drawAtPoint(CGPointZero)
                self.colorForDrawing().setStroke()
                self.colorForDrawing().setFill()
                
                offsetPath.fill()
                offsetPath.stroke()
                self.cachedDrawing = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                offsetPath.removeAllPoints()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.bufferIndex = 0
                    self.setNeedsDisplay()
                })
            })
            
            points[0] = points[3]
            points[1] = points[4]
            counter = 1
        }
    }
    
    private override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if touchMoved == false
        {
            lastWidth = 4.0
            dispatch_async(drawingQueue, { () -> Void in
                let path = UIBezierPath(ovalInRect: CGRectMake(self.points[0].x - CGFloat(self.lastWidth)/2.0, self.points[0].y - CGFloat(self.lastWidth)/2.0, CGFloat(self.lastWidth), CGFloat(self.lastWidth)))
                
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
                
                if self.cachedDrawing == nil
                {
                    let newPath = UIBezierPath(rect: self.bounds)
                    UIColor.whiteColor().setFill()
                    newPath.fill()
                }
                self.cachedDrawing?.drawAtPoint(CGPointZero)
                self.colorForDrawing().setFill()
                
                path.lineWidth = 5.0
                path.fill()
                self.cachedDrawing = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.bufferIndex = 0
                    self.setNeedsDisplay()
                })
            })
        }
        else
        {
            dispatch_async(drawingQueue, { () -> Void in
                let path = UIBezierPath(ovalInRect: CGRectMake(self.points[0].x - CGFloat(self.lastWidth)/2.0, self.points[0].y - CGFloat(self.lastWidth)/2.0, CGFloat(self.lastWidth), CGFloat(self.lastWidth)))
                
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
                
                if self.cachedDrawing == nil
                {
                    let newPath = UIBezierPath(rect: self.bounds)
                    UIColor.whiteColor().setFill()
                    newPath.fill()
                }
                self.cachedDrawing?.drawAtPoint(CGPointZero)
                self.colorForDrawing().setFill()
                
                path.fill()
                self.cachedDrawing = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.bufferIndex = 0
                    self.setNeedsDisplay()
                })
            })
            setNeedsDisplay()
        }
    }
    
    private func lineSegmentPerpendicularTo(lineSegmentOne: LineSegment, ofRelativeLength fraction: Float) -> LineSegment
    {
        let x0 = lineSegmentOne.firstPoint.x, y0 = lineSegmentOne.firstPoint.y, x1 = lineSegmentOne.secondPoint.x, y1 = lineSegmentOne.secondPoint.y
        
        var dx, dy : CGFloat
        dx = x1 - x0
        dy = y1 - y0
        
        var xa, ya, xb, yb : CGFloat
        xa = x1 + CGFloat(fraction)/2 * dy
        ya = y1 - CGFloat(fraction)/2 * dx
        xb = x1 - CGFloat(fraction)/2 * dy
        yb = y1 + CGFloat(fraction)/2 * dx
        
        return LineSegment(firstPoint: CGPointMake(xa, ya), secondPoint: CGPointMake(xb, yb))
    }
    
    private func lengthSquared(pointOne: CGPoint, pointTwo: CGPoint) -> Float
    {
        let dx = pointTwo.x - pointOne.x
        let dy = pointTwo.y - pointOne.y
        
        return Float(dx * dx + dy * dy)
    }
    
    private func clamp(value: Float, lower: Float, higher: Float) -> Float
    {
        if value < lower
        {
            return lower
        }
        else if value > higher
        {
            return higher
        }
        else
        {
            return value
        }
    }
    
    //TODO: Finish mulitple colors options
    
    private func colorForDrawing() -> UIColor
    {
        return UIColor.blackColor()
    }
}
