//
//  FormattedVC.m
//  Flora Dummy
//
//  Created by Zach Nichols on 2/15/14.
//  Finalized by Michael Schloss on 10/8/15.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

#import "FormattedVC.h"
#import "CES-Swift.h"

@implementation FormattedVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [ColorScheme currentColorScheme].backgroundColor;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateColors
{
    
}

- (BOOL) activityWantsFullScreen
{
    return false;
}

@end
