//
//  Calculator.swift
//  CES
//
//  Created by Michael Schloss on 11/4/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit

private enum PendingOperation
{
    case Addition, Multiplication, Subtraction, Division, None
}

class Calculator: FormattedVC
{
    @IBOutlet private var calculationLabel : CESOutlinedLabel!
        {
        didSet
        {
            calculationLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        }
    }
    
    private let buttonColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    
    private var calculatedNumber = 0.0
    private var currentNumber = 0.0
    private var numberOfClearClicks = 1
    @IBOutlet private var clearButton : UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeSideView", name: CalculatorPresentationController.CalculatorShouldDecreaseSizeNotification(), object: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private var shouldClear = false
    private var isFirstNumber = true
    private var pendingOp = PendingOperation.None
    private var pendingButton : UIButton!
    @IBAction private func buttonPressed(sender: UIButton)
    {
        numberOfClearClicks = 0
        clearButton.setTitle("C", forState: .Normal)
        if let _ = Int(sender.titleLabel!.text!)
        {
            if shouldClear == true
            {
                shouldClear = false
                calculationLabel.text = ""
            }
            guard calculationLabel.text! != "0" || sender.titleLabel!.text! != "0" else
            {
                isFirstNumber = false
                return
            }
            if calculationLabel.text == "0"
            {
                calculationLabel.text = ""
            }
            calculationLabel.text! += String(sender.titleLabel!.text!)
            currentNumber = Double(calculationLabel.text!)!
        }
        else if sender.titleLabel!.text == "."
        {
            if shouldClear == true
            {
                shouldClear = false
                calculationLabel.text = "0"
            }
            guard !calculationLabel.text!.containsString(".") else { return }
            calculationLabel.text! += sender.titleLabel!.text!
            currentNumber = Double("\(calculationLabel.text!)0")!
        }
        else if sender.titleLabel!.text == "±"
        {
            guard calculationLabel.text != "0" else
            {
                if isFirstNumber
                {
                    clearButton.setTitle("AC", forState: .Normal)
                    numberOfClearClicks = 1
                }
                return
            }
            shouldClear = true
            currentNumber = -currentNumber
            calculationLabel.text = String(currentNumber)
            trimString()
        }
        else if sender.titleLabel!.text == "+"
        {
            checkForPendingOp()
            shouldClear = true
            pendingOp = .Addition
            pendingButton = sender
            sender.backgroundColor = buttonColor.darker
            if isFirstNumber == true
            {
                isFirstNumber = false
                calculatedNumber = currentNumber
            }
        }
        else if sender.titleLabel!.text == "−"
        {
            checkForPendingOp()
            shouldClear = true
            pendingOp = .Subtraction
            pendingButton = sender
            sender.backgroundColor = buttonColor.darker
            if isFirstNumber == true
            {
                isFirstNumber = false
                calculatedNumber = currentNumber
            }
        }
        else if sender.titleLabel!.text == "×"
        {
            checkForPendingOp()
            shouldClear = true
            pendingOp = .Multiplication
            pendingButton = sender
            sender.backgroundColor = buttonColor.darker
            if isFirstNumber == true
            {
                isFirstNumber = false
                calculatedNumber = currentNumber
            }
        }
        else if sender.titleLabel!.text == "÷"
        {
            checkForPendingOp()
            shouldClear = true
            pendingOp = .Division
            pendingButton = sender
            sender.backgroundColor = buttonColor.darker
            if isFirstNumber == true
            {
                isFirstNumber = false
                calculatedNumber = currentNumber
            }
        }
        else if sender.titleLabel!.text == "sin"
        {
            guard calculationLabel.text != "0" else
            {
                if isFirstNumber
                {
                    clearButton.setTitle("AC", forState: .Normal)
                    numberOfClearClicks = 1
                }
                return
            }
            shouldClear = true
            currentNumber = sin(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "tan"
        {
            guard calculationLabel.text != "0" else
            {
                if isFirstNumber
                {
                    clearButton.setTitle("AC", forState: .Normal)
                    numberOfClearClicks = 1
                }
                return
            }
            shouldClear = true
            currentNumber = tan(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "cos"
        {
            guard calculationLabel.text != "0" else
            {
                if isFirstNumber
                {
                    clearButton.setTitle("AC", forState: .Normal)
                    numberOfClearClicks = 1
                }
                return
            }
            shouldClear = true
            currentNumber = tan(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "arcsin"
        {
            guard calculationLabel.text != "0" else
            {
                if isFirstNumber
                {
                    clearButton.setTitle("AC", forState: .Normal)
                    numberOfClearClicks = 1
                }
                return
            }
            shouldClear = true
            currentNumber = asin(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "arccos"
        {
            guard calculationLabel.text != "0" else
            {
                if isFirstNumber
                {
                    clearButton.setTitle("AC", forState: .Normal)
                    numberOfClearClicks = 1
                }
                return
            }
            shouldClear = true
            currentNumber = acos(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "arctan"
        {
            guard calculationLabel.text != "0" else
            {
                if isFirstNumber
                {
                    clearButton.setTitle("AC", forState: .Normal)
                    numberOfClearClicks = 1
                }
                return
            }
            shouldClear = true
            currentNumber = atan(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "π"
        {
            shouldClear = true
            currentNumber = M_PI
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "e"
        {
            shouldClear = true
            currentNumber = M_E
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "√"
        {
            shouldClear = true
            currentNumber = sqrt(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "ln"
        {
            shouldClear = true
            currentNumber = log(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "log10"
        {
            shouldClear = true
            currentNumber = log10(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "x^2"
        {
            shouldClear = true
            currentNumber = pow(currentNumber, 2)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "10^x"
        {
            shouldClear = true
            currentNumber = pow(10, currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "e^x"
        {
            shouldClear = true
            currentNumber = pow(M_E, currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "!"
        {
            guard currentNumber >= 0 else { return }
            shouldClear = true
            currentNumber = factorial(currentNumber)
            calculationLabel.text = String(currentNumber)
        }
        else if sender.titleLabel!.text == "="
        {
            checkForPendingOp()
            clearButton.setTitle("AC", forState: .Normal)
            numberOfClearClicks = 1
        }
    }
    
    private func factorial(n: Double) -> Double
    {
        return n == 0 ? 1 : n * self.factorial(n - 1)
    }
    
    private func trimString()
    {
        guard calculationLabel.text!.containsString(".") && calculationLabel.text!.characters.last! == "0" else { return }
        
        var newString = calculationLabel.text!.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0"))
        newString.removeAtIndex(newString.endIndex.advancedBy(-1))
        calculationLabel.text! = newString.isEmpty ? "0" : newString
    }
    
    private func checkForPendingOp()
    {
        guard pendingOp != .None else { return }
        
        pendingButton?.backgroundColor = buttonColor
        pendingButton = nil
        
        switch pendingOp
        {
        case .Addition:
            calculatedNumber += currentNumber
            
        case .Subtraction:
            calculatedNumber -= currentNumber
            
        case .Multiplication:
            calculatedNumber *= currentNumber
            
        case .Division:
            calculatedNumber /= currentNumber
            
        default: break
        }
        
        calculationLabel.text! = String(calculatedNumber)
        trimString()
    }
    
    @IBAction private func clearScreen()
    {
        numberOfClearClicks++
        if numberOfClearClicks == 1
        {
            calculationLabel.text = "0"
            currentNumber = 0.0
            clearButton.setTitle("AC", forState: .Normal)
        }
        else
        {
            calculationLabel.text = "0"
            isFirstNumber = true
            calculatedNumber = 0.0
            currentNumber = 0.0
            pendingOp = .None
            pendingButton?.backgroundColor = buttonColor
            pendingButton = nil
        }
    }
    
    func closeSideView()
    {
        selectedSideViewButton = nil
        preferredContentSize = CGSizeMake(304, 508)
    }
    
    private var selectedSideViewButton : UIButton?
    @IBAction private func toggleSideView(sender: UIButton)
    {
        if selectedSideViewButton?.titleLabel!.text! == sender.titleLabel!.text!
        {
            selectedSideViewButton = nil
            preferredContentSize = CGSizeMake(304, 508)
            NSNotificationCenter.defaultCenter().postNotificationName(CalculatorPresentationController.CalculatorWillDecreaseSizeNotification(), object: nil)
        }
        else
        {
            selectedSideViewButton = sender
            var sideView : UIView!
            switch sender.titleLabel!.text!
            {
            case "Trig":
                sideView = NSBundle.mainBundle().loadNibNamed("trigView", owner: self, options: nil).first! as! UIView
                preferredContentSize = CGSizeMake(452, 508)
                
            case "Const":
                sideView = NSBundle.mainBundle().loadNibNamed("constView", owner: self, options: nil).first! as! UIView
                preferredContentSize = CGSizeMake(382, 508)
                
            case "...":
                sideView = NSBundle.mainBundle().loadNibNamed("extraView", owner: self, options: nil).first! as! UIView
                preferredContentSize = CGSizeMake(382, 508)
                
            case "Exp":
                sideView = NSBundle.mainBundle().loadNibNamed("expoView", owner: self, options: nil).first! as! UIView
                preferredContentSize = CGSizeMake(452, 508)
                
            default: break
            }
            
            sideView.backgroundColor = view.backgroundColor
            (presentationController as! CalculatorPresentationController).calculatorExtension = sideView
            NSNotificationCenter.defaultCenter().postNotificationName(CalculatorPresentationController.CalculatorWillIncreaseSizeNotification(), object: nil)
        }
    }
}