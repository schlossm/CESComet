//
//  SubjectVC.swift
//  FloraDummy
//
//  Created by Michael Schloss on 1/11/15.
//  Copyright (c) 2015 SGSC. All rights reserved.
//

import UIKit
import CoreData

func subjectIDToName(subjectID: Int) -> String
{
    switch subjectID
    {
    case 1: return "Math"
    case 2: return "Science"
    case 3: return "History"
    case 4: return "Language Arts"
    default: return "None"
    }
}

class SubjectLoadingView : UIView
{
    @IBOutlet var loadingIndicator : MSProgressView!
        {
        didSet
        {
            loadingIndicator.barColor = ColorScheme.currentColorScheme().primaryColor
            loadingIndicator.startAnimating(true)
        }
    }
    
    @IBOutlet var label : CESOutlinedLabel!
        {
        didSet
        {
            label.textColor = ColorScheme.currentColorScheme().primaryColor
        }
    }
}

class SubjectNoActivitesView : UIView
{
    @IBOutlet var label : CESOutlinedLabel!
}

class SubjectVC: FormattedVC, UIViewControllerTransitioningDelegate
{
    lazy private var activities = [Activity]()
    
    var sourceRect : CGRect!
    var sourceView : UIView!
    
    @IBOutlet private var loadingView : SubjectLoadingView!
        {
        didSet
        {
            loadingView.backgroundColor = ColorScheme.currentColorScheme().backgroundColor.lighter
        }
    }
    @IBOutlet private var noActivitiesView : SubjectNoActivitesView!
        {
        didSet
        {
            noActivitiesView.backgroundColor = ColorScheme.currentColorScheme().backgroundColor.lighter
            noActivitiesView.label.textColor = ColorScheme.currentColorScheme().primaryColor
        }
    }
    
    @IBOutlet var titleLabel : CESOutlinedLabel!
        {
        didSet
        {
            titleLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        }
    }
    @IBOutlet var activitiesTable : UITableView!
        {
        didSet
        {
            activitiesTable!.layer.borderWidth = 2.0
            activitiesTable!.layer.borderColor = ColorScheme.currentColorScheme().secondaryColor.CGColor
            activitiesTable!.backgroundColor = ColorScheme.currentColorScheme().backgroundColor.lighter
            activitiesTable!.separatorColor = ColorScheme.currentColorScheme().secondaryColor
        }
    }
    @IBOutlet var notificationField : CESOutlinedLabel!
        {
        didSet
        {
            notificationField.textColor = ColorScheme.currentColorScheme().primaryColor
            notificationField.backgroundColor = ColorScheme.currentColorScheme().backgroundColor.lighter
            notificationField.layer.borderWidth = 2.0
            notificationField.layer.borderColor = ColorScheme.currentColorScheme().secondaryColor.CGColor
        }
    }
    
    @IBOutlet var homeButton : UIButton!
        {
        didSet
        {
            UILabel.outlineLabel(homeButton.titleLabel!)
            homeButton.setTitleColor(ColorScheme.currentColorScheme().primaryColor, forState: .Normal)
        }
    }
    
    @IBInspectable
    var subjectID : Int = -1
    var subjectName : String
        {
        get
        {
            return subjectIDToName(self.subjectID)
        }
    }
    
    private var activitiesLoaded = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = ColorScheme.currentColorScheme().backgroundColor
        
        var statusBarViewBackgroundColor : UIColor
        if ColorScheme.currentColorScheme().backgroundColor.lighter == UIColor.whiteColor() || ColorScheme.currentColorScheme().backgroundColor.lighter == UIColor.clearColor()
        {
            statusBarViewBackgroundColor = ColorScheme.currentColorScheme().backgroundColor.darker
        }
        else
        {
            statusBarViewBackgroundColor = ColorScheme.currentColorScheme().backgroundColor.lighter
        }
        
        let statusBarView = UIView()
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        statusBarView.backgroundColor = statusBarViewBackgroundColor
        view.addSubview(statusBarView)
        view.addConstraint(NSLayoutConstraint(item: statusBarView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: statusBarView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: statusBarView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[statusBarView(20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["statusBarView":statusBarView]))
        
        notificationField.text = "Loading Notifications..."
        
        checkForActivityDataLoaded()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "activityDataLoaded", name: ActivityDataLoaded, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "activityDataLoaded", name: UIApplicationSignificantTimeChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        loadingView?.loadingIndicator?.stopAnimating(true)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func checkForActivityDataLoaded()
    {
        if CESDatabase.databaseManagerForMainActivitiesClass().activityDataIsLoaded == true
        {
            loadingView?.loadingIndicator.stopAnimating(true)
            activities = [Activity]()
            let request = NSFetchRequest(entityName: "Activity")
            request.predicate = NSPredicate(format: "classID ==[c] %d", subjectID)
            let results = try! NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
            for result in results
            {
                activities.append(CESDatabase.databaseManagerForMainActivitiesClass().activityForActivityID(result.valueForKey("activityID") as! String))
            }
            activitiesTable?.reloadData()
            loadingView?.removeFromSuperview()
            if activities.isEmpty
            {
                noActivitiesView?.alpha = 1.0
                noActivitiesView?.userInteractionEnabled = true
            }
            
            let classFetchRequest = NSFetchRequest(entityName: "Class")
            classFetchRequest.predicate = NSPredicate(format: "classID ==[c] %d", subjectID)
            let classResults = try! NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(classFetchRequest) as! [NSManagedObject]
            let classObject = classResults.first
            notificationField.text = classObject?.valueForKey("notifications") as? String ?? "No Notifications"
        }
    }
    
    func activityDataLoaded()
    {
        loadingView?.loadingIndicator?.showComplete()
        activities = [Activity]()
        let request = NSFetchRequest(entityName: "Activity")
        request.predicate = NSPredicate(format: "classID ==[c] %d", subjectID)
        let results = try! NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
        for result in results
        {
            activities.append(CESDatabase.databaseManagerForMainActivitiesClass().activityForActivityID(result.valueForKey("activityID") as! String))
        }
        activitiesTable.reloadData()
        let classFetchRequest = NSFetchRequest(entityName: "Class")
        classFetchRequest.predicate = NSPredicate(format: "classID ==[c] %d", subjectID)
        let classResults = try! NADatabase.sharedDatabase().managedObjectContext.executeFetchRequest(classFetchRequest) as! [NSManagedObject]
        let classObject = classResults.first!
        UIView.transitionWithView(notificationField, duration: CESCometTransitionDuration, options: [.AllowAnimatedContent, .TransitionCrossDissolve], animations: { [unowned self] () -> Void in
            self.notificationField.text = classObject.valueForKey("notifications") as? String ?? "No Notifications"
            }, completion: nil)
        UIView.animateWithDuration(CESCometTransitionDuration, delay: 2.3, options: [.AllowAnimatedContent], animations: { [unowned self] () -> Void in
            self.loadingView?.alpha = 0.0
            if self.activities.isEmpty
            {
                self.noActivitiesView?.alpha = 1.0
                self.noActivitiesView?.userInteractionEnabled = true
            }
            }) { [unowned self] (finished) -> Void in
                self.loadingView?.removeFromSuperview()
        }
    }
    
    @IBAction func dismissSelf()
    {
        performSegueWithIdentifier("subjectUnwind", sender: self)
    }
    
    private var selectedActivity : Activity!
    private var vevView : UIVisualEffectView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "subjectUnwind"
        {
            guard let unwindSegue = segue as? CESSubjectUnwindSegue else { return }
            
            unwindSegue.sourceRect = sourceRect
            unwindSegue.sourceView = sourceView
        }
        else
        {
            guard let activityManagerDisplaySegue = segue as? ActivityManagerPresentationSegue else { return }
            
            activityManagerDisplaySegue.sourceView = vevView
            (segue.destinationViewController as! CESActivityManager).currentActivity = selectedActivity
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        if ColorScheme.currentColorScheme().backgroundColor.lighter == UIColor.whiteColor() || ColorScheme.currentColorScheme().backgroundColor.lighter == UIColor.clearColor()
        {
            if ColorScheme.currentColorScheme().backgroundColor.darker.shouldUseWhiteText == true
            {
                return .LightContent
            }
            else
            {
                return .Default
            }
        }
        else
        {
            if ColorScheme.currentColorScheme().backgroundColor.lighter.shouldUseWhiteText == true
            {
                return .LightContent
            }
            else
            {
                return .Default
            }
        }
    }
    
    //MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return activities.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 88.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("SubjectCell")!
        
        cell.textLabel?.text = activities[indexPath.row].name
        cell.textLabel?.font = bodyFont
        cell.textLabel?.textColor = ColorScheme.currentColorScheme().primaryColor
        cell.backgroundColor = .clearColor()
        cell.imageView!.image = UIImage(named: "117-todo.png")
        UILabel.outlineLabel(cell.textLabel!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedActivity = activities[indexPath.item]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        view.userInteractionEnabled = false
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let activityLoadingView = UIVisualEffectView(effect: nil)
        activityLoadingView.layer.cornerRadius = 0.001
        activityLoadingView.clipsToBounds = true
        activityLoadingView.frame = view.convertRect(cell.frame, fromView: tableView)
        activityLoadingView.contentView.alpha = 0.0
        
        let loadingWheel = MSProgressView(frame: CGRectMake(0, 0, 37, 37))
        loadingWheel.barColor = ColorScheme.currentColorScheme().primaryColor
        loadingWheel.barWidth = 3.0
        loadingWheel.startAnimating(true)
        
        let loadingLabel = CESOutlinedLabel()
        loadingLabel.textColor = ColorScheme.currentColorScheme().primaryColor
        loadingLabel.text = "Loading Activity..."
        loadingLabel.numberOfLines = 0
        loadingLabel.font = bodyFont
        loadingLabel.sizeToFit()
        
        let activityLoadingLoadingView = UIView(frame: CGRectMake(0, 0, loadingWheel.frame.size.width + loadingLabel.frame.size.width + 8, activityLoadingView.frame.size.height))
        activityLoadingLoadingView.addSubview(loadingWheel)
        activityLoadingLoadingView.addSubview(loadingLabel)
        loadingWheel.center = CGPointMake(loadingWheel.frame.size.width/2.0, activityLoadingLoadingView.frame.size.height/2.0)
        loadingLabel.center = CGPointMake(activityLoadingLoadingView.frame.size.width - loadingLabel.frame.size.width/2.0, activityLoadingLoadingView.frame.size.height/2.0)
        activityLoadingView.contentView.addSubview(activityLoadingLoadingView)
        activityLoadingLoadingView.center = CGPointMake(activityLoadingView.frame.size.width/2.0, activityLoadingView.frame.size.height/2.0)
        
        view.addSubview(activityLoadingView)
        UIView.animateWithDuration(CESCometTransitionDuration, delay: 0.0, options: .AllowAnimatedContent, animations: { () -> Void in
            activityLoadingView.contentView.alpha = 1.0
            activityLoadingView.effect = UIBlurEffect(style: .Dark)
            }, completion: { [unowned self] (finished) -> Void in
                
                self.setCornerRadius(activityLoadingView)
                UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .AllowAnimatedContent, animations: { [unowned self] () -> Void in
                    
                    activityLoadingView.frame = CGRectMake(0, 0, self.view.frame.size.width/2.0, self.view.frame.size.height/2.0)
                    activityLoadingView.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0)
                    
                    activityLoadingLoadingView.frame = CGRectMake(0, 0, activityLoadingView.frame.size.width, activityLoadingView.frame.size.height)
                    loadingWheel.center = CGPointMake(activityLoadingLoadingView.frame.size.width/2.0, activityLoadingLoadingView.frame.size.height/2.0 - 4 - loadingWheel.frame.size.height/2.0)
                    loadingLabel.center = CGPointMake(activityLoadingLoadingView.frame.size.width/2.0, activityLoadingLoadingView.frame.size.height/2.0 + 4 + loadingWheel.frame.size.height/2.0)
                    
                    }, completion: { [unowned self] (finished) -> Void in
                        
                        //TODO: Uncomment after legit activites on database
                        
                        self.vevView = activityLoadingView
                        self.view.userInteractionEnabled = true
                        self.performSegueWithIdentifier("activityDisplaySegue", sender: self)
                })
            })
        
        
    }
    
    func setCornerRadius(activityLoadingView: UIVisualEffectView)
    {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.fromValue = NSNumber(double: 0.001)
        animation.toValue = NSNumber(double: 10.0)
        animation.duration = 0.3
        activityLoadingView.layer.addAnimation(animation, forKey: "cornerRadius")
        activityLoadingView.layer.cornerRadius = 10.0
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        loadingView?.frame = CGRectMake(0, scrollView.frame.size.height - 100 + scrollView.contentOffset.y, scrollView.frame.size.width, 100)
    }
}
