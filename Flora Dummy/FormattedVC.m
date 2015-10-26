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
    
    isPresented = NO;
    
    //Immediately set colors before presentation
    [self updateColors];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColors) name:ColorSchemeDidChangeNotification object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateColors
{
    [UIView animateWithDuration:transitionLength delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^
     {
         self.view.backgroundColor = [ColorScheme currentColorScheme].backgroundColor;
     } completion:nil];
}

- (id) saveActivityState
{
    @throw [NSException exceptionWithName:@"Subclassing Required" reason:@"This method requires each activity to implement a custom solution." userInfo:nil];
}

- (void) restoreActivityState:(id)object
{
    @throw [NSException exceptionWithName:@"Subclassing Required" reason:@"This method requires each activity to implement a custom solution." userInfo:nil];
}

- (NSDictionary *) settings
{
    @throw [NSException exceptionWithName:@"Subclassing Required" reason:@"This method requires each activity to implement a custom solution." userInfo:nil];
}

@end
