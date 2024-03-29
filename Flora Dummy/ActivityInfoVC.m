//
//  ActivityInfoVC.m
//  FloraDummy
//
//  Created by Zachary Nichols on 11/23/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

#import "ActivityInfoVC.h"
#import "CES-Swift.h"

@interface ActivityInfoVC ()

@end

@implementation ActivityInfoVC
@synthesize nameField, releasePicker, duePicker, imageField;
@synthesize saveButton;
@synthesize activity;


-(id)initWithActivity: (id<Activity>)a
{
    if (self = [super init])
    {
        // Initialize
        activity = a;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (activity.name != nil)
    {
        nameField.text = activity.name;
    }
    
    if (activity.releaseDate != nil)
    {
        releasePicker.date = activity.releaseDate;
    }
    
    if (activity.dueDate != nil)
    {
        duePicker.date = activity.dueDate;
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)packageActivity
{
    //activity.name = nameField.text;
    
    //activity.releaseDate = releasePicker.date;
    //activity.dueDate = duePicker.date;
    
    //activity.iconImageName = imageField.text;
}

-(IBAction)save:(id)sender
{
    [self packageActivity];
    
    //Notify the delegate if it exists.
    if (_delegate != nil)
    {
        [_delegate finishSavingActivity:activity];
    }
}

@end
