//
//  ActivityManagerVC.swift
//  CES
//
//  Created by Michael Schloss on 10/10/15.
//  Copyright © 2015 SGSC. All rights reserved.
//

import UIKit

@objc enum FrameType : Int
{
    case PageNumberLabel, TOCButtonFrame, PreviousButtonFrame, SaveButtonFrame, NextButtonFrame
}

private class ActivityManagerVC: UIViewController, CESActivityManager
{
    @IBOutlet private var pageNumberLabel: UILabel!
    
    @IBOutlet private var tableOfContentsButton: UIButton!
    @IBOutlet private var previousButton: UIButton!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var nextButton: UIButton!
    
    @IBOutlet private var contentView: UIView!
    
    private var activityWillBeFullscreen = false
    
    @objc var margins : UIEdgeInsets
        {
        get
        {
            return UIEdgeInsetsMake(pageNumberLabel.frame.origin.y + pageNumberLabel.frame.size.height, 0.0, pageNumberLabel.frame.origin.y + pageNumberLabel.frame.size.height, 0.0)
        }
    }
    
    private var _currentActivity : Activity!
    @objc var currentActivity : Activity!
        {
        get
        {
            return _currentActivity
        }
        set
        {
            guard currentActivity == nil else { return }
            _currentActivity = newValue
            self.currentActivitySession = databaseManager.activitySessionForActivityID(currentActivity.activityID, activity: currentActivity)
        }
    }
    private var currentActivitySession : ActivitySession!
    
    private var databaseManager = CESDatabase.databaseManagerForPageManagerClass()
    
    @objc func frameForType(frameType: FrameType) -> CGRect
    {
        switch frameType
        {
        case .PageNumberLabel:
            return pageNumberLabel.frame
            
        case .TOCButtonFrame:
            return tableOfContentsButton.frame
            
        case .PreviousButtonFrame:
            return previousButton.frame
            
        case .SaveButtonFrame:
            return saveButton.frame
            
        case .NextButtonFrame:
            return nextButton.frame
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = ColorScheme.currentColorScheme().backgroundColor
        
        pageNumberLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        
        tableOfContentsButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        previousButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        saveButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        nextButton.titleLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        
        let introVC = ActivityIntroVC()
        introVC.activityTitle = currentActivity.name
        introVC.summary = currentActivity.activityDescription
        contentView.addSubview(introVC.view)
    }
}

//MARK: - Intro ViewController
extension ActivityManagerVC
{
    class ActivityIntroVC: FormattedVC
    {
        var summary : String!
            {
            didSet
            {
                if summaryTextView != nil
                {
                    summaryTextView.text = summary
                }
            }
        }
        
        var activityTitle : String!
            {
            didSet
            {
                if titleLabel != nil
                {
                    titleLabel.text = activityTitle
                }
            }
        }
        
        private var titleLabel : CESOutlinedLabel!
        private var summaryTextView : CESOutlinedLabel!
        
        private override func viewDidLoad()
        {
            super.viewDidLoad()
            
            summaryTextView = CESOutlinedLabel()
            summaryTextView.text = summary
            summaryTextView.textAlignment = .Center
            summaryTextView.font = UIFont.systemFontOfSize(28.0, weight: UIFontWeightRegular)
            summaryTextView.backgroundColor = view.backgroundColor?.lighter
            summaryTextView.textColor = ColorScheme.currentColorScheme().primaryColor
            summaryTextView.layer.borderColor = ColorScheme.currentColorScheme().secondaryColor.CGColor
            view.addSubview(summaryTextView)
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Width, multiplier: 0.7, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: summaryTextView, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Height, multiplier: 0.5, constant: 0.0))
            
            titleLabel = CESOutlinedLabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFontOfSize(64.0, weight: UIFontWeightBlack)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.5
            titleLabel.textColor = ColorScheme.currentColorScheme().primaryColor
            titleLabel.text = activityTitle
            view.addSubview(titleLabel)
            view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(>=leftMargin)-[titleLabel]-(>=rightMargin)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["leftMargin":max(activityManager!.margins.left, 8), "rightMargin":max(activityManager!.margins.right, 8)], views: ["titleLabel":titleLabel]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(20)-[titleLabel]-(>=8)-[summaryTextView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["titleLabel":titleLabel, "summaryTextView":summaryTextView]))
        }
    }
}
