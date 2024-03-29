//
//  QuickQuizVC.m
//  Flora Dummy
//
//  Created by Zachary Nichols on 10/26/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
////

#import "QuickQuizVC.h"

#import "CES-Swift.h"

@interface QuickQuizVC ()

@end

@implementation QuickQuizVC
@synthesize pageManager;
@synthesize questionLabel, option1Button, option2Button, option3Button;
@synthesize question, answers, correctIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    pageManager.canGoForward = false;
    
    if (!(questionLabel && option1Button && option2Button && option3Button))
    {
        [self populateView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateColors
{
    [super updateColors];
    
    //[self outlineTextInLabel:questionLabel];
    questionLabel.textColor = [ColorScheme currentColorScheme].primaryColor;
    questionLabel.backgroundColor = [ColorScheme currentColorScheme].secondaryColor;
    questionLabel.backgroundColor = [ColorScheme currentColorScheme].secondaryColor;

}

-(void)populateView
{
    // Question label
    
    
    
    questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,
                                                              pageManager.topMargin + 20,
                                                              self.view.frame.size.width - 40,
                                                              18 + 20)];
    
    questionLabel.text = question;
    questionLabel.textAlignment = NSTextAlignmentCenter;
    //questionLabel.font = self.font;
    
    questionLabel.textColor = [ColorScheme currentColorScheme].primaryColor;
    questionLabel.backgroundColor = [ColorScheme currentColorScheme].secondaryColor;
    
    [self.view addSubview:questionLabel];
    
    
    // Buttons
    float imageMargin = 20;

    
    // Option 1
    option1Button = [[UIButton alloc] initWithFrame:CGRectMake(questionLabel.frame.origin.x,
                                                               questionLabel.frame.origin.y + questionLabel.frame.size.height + 20,
                                                               (self.view.frame.size.width - 80) / 3,
                                                               (self.view.frame.size.width - 80) / 3)];
    
    //option1Button.backgroundColor = secondaryColor;
    option1Button.tag = 0;
    
    [option1Button setImageEdgeInsets:UIEdgeInsetsMake(imageMargin, imageMargin, imageMargin, imageMargin)];
    [option1Button setImage:[UIImage imageNamed:(NSString *)[answers objectAtIndex:0]] forState:UIControlStateNormal];
    
    [option1Button addTarget:self
                      action:@selector(optionSelected:)
            forControlEvents:UIControlEventTouchUpInside];
    
    //[self outlineButton:option1Button];
    [self.view addSubview:option1Button];
    
    
    
    // Option 2
    option2Button = [[UIButton alloc] initWithFrame:CGRectMake(option1Button.frame.origin.x + option1Button.frame.size.width + 20,
                                                               option1Button.frame.origin.y,
                                                               option1Button.frame.size.width,
                                                               option1Button.frame.size.height)];
    //option1Button.backgroundColor = secondaryColor;
    option2Button.tag = 1;
    
    [option2Button setImageEdgeInsets:UIEdgeInsetsMake(imageMargin, imageMargin, imageMargin, imageMargin)];
    [option2Button setImage:[UIImage imageNamed:(NSString *)[answers objectAtIndex:1]] forState:UIControlStateNormal];
    
    [option2Button addTarget:self
                      action:@selector(optionSelected:)
            forControlEvents:UIControlEventTouchUpInside];
    
    //[self outlineButton:option2Button];
    [self.view addSubview:option2Button];
    
    
    
    // Option 3
    option3Button = [[UIButton alloc] initWithFrame:CGRectMake(option2Button.frame.origin.x + option2Button.frame.size.width + 20,
                                                               option2Button.frame.origin.y,
                                                               option2Button.frame.size.width,
                                                               option2Button.frame.size.height)];
    
    option3Button.tag = 2;
    
    [option3Button setImageEdgeInsets:UIEdgeInsetsMake(imageMargin, imageMargin, imageMargin, imageMargin)];
    [option3Button setImage:[UIImage imageNamed:(NSString *)[answers objectAtIndex:2]] forState:UIControlStateNormal];
    
    [option3Button addTarget:self
                      action:@selector(optionSelected:)
            forControlEvents:UIControlEventTouchUpInside];
    
    //[self outlineButton:option3Button];
    [self.view addSubview:option3Button];
    
    
}

-(IBAction)optionSelected:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
    
    NSInteger senderTag = senderButton.tag;
    
    if(senderTag == correctIndex.intValue)
    {
        // Hooray you win!
        NSLog(@"Correct");
        
        //self.nextButton.hidden = false;
        [self flashYesInView:senderButton];
        [self unhideButton];
        
    }else
    {
        // Oh no, you lose!
        NSLog(@"Incorrect");
        /*
        if(self.nextButton.hidden == NO)
        {
            [self hideButton];
        }*/
        
        [self flashNoInView:senderButton];
        
    }
}

-(void)flashNoInView: (UIView *)view
{
    view.backgroundColor = [UIColor redColor];
    view.alpha = 0.75f;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.65];
    view.backgroundColor = [ColorScheme currentColorScheme].secondaryColor;
    view.alpha = 1.0f;
    [UIView commitAnimations];
    
}

-(void)flashYesInView: (UIView *)view
{
    view.backgroundColor = [UIColor greenColor];
    view.alpha = 0.75f;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.65];
    view.backgroundColor = [ColorScheme currentColorScheme].secondaryColor;
    view.alpha = 1.0f;

    [UIView commitAnimations];
    
}

-(void)hideButton
{
    pageManager.canGoForward = false;
    /*
    [UIView transitionWithView:self.nextButton
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    self.nextButton.hidden = YES;*/

}

-(void)unhideButton
{
    pageManager.canGoForward = true;
    /*
    [UIView transitionWithView:self.nextButton
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    self.nextButton.hidden = NO;*/
    
}


@end
