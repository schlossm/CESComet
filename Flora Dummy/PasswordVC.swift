//
//  PasswordVC.swift
//  FloraDummy
//
//  Created by Michael Schloss on 2/27/15.
//  Copyright (c) 2015 SGSC. All rights reserved.
//

import UIKit

class PasswordVC: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var usernameTextField: NALoginTextField!
    @IBOutlet weak var passwordTextField: NALoginTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginLoadingWheel: MSProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginBackground: UIImageView!
    
    private var animator : UIDynamicAnimator!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loginBackground.layer.shouldRasterize = true
        loginBackground.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        animator = UIDynamicAnimator(referenceView: view)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else { return }
        
        let keyboardAnimationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        if passwordTextField.frame.origin.y + passwordTextField.frame.size.height > keyboardRect.origin.y //Move it up
        {
            UIView.animateWithDuration(keyboardAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: [.AllowUserInteraction], animations: { [unowned self] () -> Void in
                self.titleLabel.alpha = 0.0
                self.usernameTextField.transform = CGAffineTransformMakeTranslation(0.0, keyboardRect.origin.y - (self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height) - 8.0)
                self.passwordTextField.transform = CGAffineTransformMakeTranslation(0.0, keyboardRect.origin.y - (self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height) - 8.0)
                }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardAnimationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animateWithDuration(keyboardAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: [.AllowUserInteraction], animations: { [unowned self] () -> Void in
            self.titleLabel.alpha = 1.0
            self.usernameTextField.transform = CGAffineTransformIdentity
            self.passwordTextField.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject)
    {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    override func shouldAutorotate() -> Bool
    {
        return false
    }
    
    private func showWheel()
    {
        loginLoadingWheel.startAnimating(true)
        UIView.animateWithDuration(0.3) { () -> Void in
            self.loginLoadingWheel.alpha = 1.0
        }
    }
    
    private func hideWheel()
    {
        loginLoadingWheel.stopAnimating(true)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.loginLoadingWheel.alpha = 0.0
            }) { (finished) -> Void in
                self.loginLoadingWheel.reset()
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        if errorLabel.alpha != 0.0
        {
            animator.removeAllBehaviors()
            
            hideWheel()
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.usernameTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
                self.passwordTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
                
                self.usernameTextField.imageView.tintColor = UIColor.blackColor()
                self.passwordTextField.imageView.tintColor = UIColor.blackColor()
            })
            
            UIView.animateWithDuration(0.3) { () -> Void in
                self.errorLabel.transform = CGAffineTransformMakeTranslation(0.0, -20.0)
                self.errorLabel.alpha = 0.0
            }
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == usernameTextField
        {
            passwordTextField.text = ""
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == usernameTextField
        {
            passwordTextField.becomeFirstResponder()
        }
        else
        {
            showWheel()
            
            passwordTextField.resignFirstResponder()
            
            usernameTextField.enabled = false
            passwordTextField.enabled = false
            
            
            CESDatabase.databaseManagerForPasswordVCClass().inputtedUsernameIsValid(usernameTextField.text, andPassword: passwordTextField.text, completion: { [unowned self] (isValid) -> Void in
                if isValid == true
                {
                    CESDatabase.databaseManagerForPasswordVCClass().downloadUserInformationForUser(self.usernameTextField.text, andPassword: self.passwordTextField.text, completion: { [unowned self] (success) -> Void in
                        if success == true
                        {
                            CurrentUser.currentUser().loadSavedUser()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else
                        {
                            self.errorLabel.text = "We couldn't get your user information.  Please try again."
                            self.showLoginError()
                            self.usernameTextField.enabled = true
                            self.passwordTextField.enabled = true
                        }
                    })
                }
                else
                {
                    self.errorLabel.text = "We couldn't verify your login.  Please try again."
                    self.showLoginError()
                    self.usernameTextField.enabled = true
                    self.passwordTextField.enabled = true
                }
            })
        }
        
        return false
    }
    
    private func showLoginError()
    {
        usernameTextField.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.3)
        passwordTextField.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.3)
        
        usernameTextField.imageView.tintColor = UIColor.redColor()
        passwordTextField.imageView.tintColor = UIColor.redColor()
        
        usernameTextField.enabled = true
        passwordTextField.enabled = true
        
        let usernameAttachmentBehavior = UIAttachmentBehavior(item: usernameTextField, attachedToAnchor: usernameTextField.center)
        usernameAttachmentBehavior.damping = 0.5
        usernameAttachmentBehavior.frequency = 5.0
        animator.addBehavior(usernameAttachmentBehavior)
        
        let passwordAttachmentBehavior = UIAttachmentBehavior(item: passwordTextField, attachedToAnchor: passwordTextField.center)
        passwordAttachmentBehavior.damping = 0.5
        passwordAttachmentBehavior.frequency = 5.0
        animator.addBehavior(passwordAttachmentBehavior)
        
        let push = UIPushBehavior(items: [usernameTextField, passwordTextField], mode: UIPushBehaviorMode.Instantaneous)
        push.pushDirection = CGVectorMake(2.0, 0)
        push.magnitude = 50.0
        animator.addBehavior(push)
        push.active = true
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.errorLabel.transform = CGAffineTransformIdentity
            self.errorLabel.alpha = 1.0
        }
        
        if loginLoadingWheel.alpha != 0.0
        {
            loginLoadingWheel.showIncomplete()
        }
    }
}