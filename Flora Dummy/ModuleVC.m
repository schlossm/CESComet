//
//  ModuleVC.m
//  Flora Dummy
//
//  Created by Zach Nichols on 3/27/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

#import "ModuleVC.h"
#import "CES-Swift.h"
#import "Content.h" 

@implementation ModuleVC
@synthesize contentArray;

-(id)initWithContent: (NSArray *) content
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        
        if (content != nil && content.count > 0)
        {
            [self populateScreenWithObjects:content];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    contentArray = [[NSMutableArray alloc] init];
    
    //self.pageControl.numberOfPages = self.pageCount.intValue;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self updateColors];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateColors
{
    [super updateColors];
    
    for (UIView *v in contentArray)
    {
        if ([v isKindOfClass: [UITextView new].class])
        {
            UITextView *tV = (UITextView *)v;
            //[Definitions outlineTextInTextView:tV forFont:tV.font];
            tV.textColor = [ColorScheme currentColorScheme].primaryColor;
            tV.backgroundColor = [ColorScheme currentColorScheme].secondaryColor;
    
        }
    }
}

-(void)populateScreenWithObjects: (NSArray *)objects
{
    for (Content *c in objects)
    {
        // Get what type of object it is
        NSString *type = c.type;
        
        if ([type isEqualToString:@"Text"])
        {
            [self addTextView:c];
        
        }else if ([type isEqualToString:@"Image"])
        {
            [self addImageView:c];
            
        }else if ([type isEqualToString:@"GIF"])
        {
            //[self addGIFView:c];
            
        }
    }
}

-(void)addTextView: (Content *)c
{
    // Get bounds of object
    NSArray *boundsArray = [c arrayForBounds];
    
    // Declare text view
    UITextView *tV = [[UITextView alloc] initWithFrame:
                      CGRectMake([(NSNumber *)[boundsArray objectAtIndex:0] floatValue],
                                 [(NSNumber *)[boundsArray objectAtIndex:1] floatValue],
                                 [(NSNumber *)[boundsArray objectAtIndex:2] floatValue],
                                 [(NSNumber *)[boundsArray objectAtIndex:3] floatValue])];
    
    // Get special features of object
    NSDictionary *specials = c.variableContent;
    
    // Get text
    tV.text = (NSString *)[specials objectForKey:@"Text"];
    
    // Add text view to screen and content array
    [self.view addSubview:tV];
    [contentArray addObject:tV];
    
    
    // Format
    //[self outlineTextInTextView:tV];
    //[Definitions outlineView:tV];
    tV.textColor = [ColorScheme currentColorScheme].primaryColor;
    tV.backgroundColor = [ColorScheme currentColorScheme].secondaryColor;

}

-(void)addImageView: (Content *)c
{
    // Get bounds of object
    NSArray *boundsArray = [c arrayForBounds];
    
    // Declare image view
    UIImageView *iV = [[UIImageView alloc] initWithFrame:
                      CGRectMake([(NSNumber *)[boundsArray objectAtIndex:0] floatValue],
                                 [(NSNumber *)[boundsArray objectAtIndex:1] floatValue],
                                 [(NSNumber *)[boundsArray objectAtIndex:2] floatValue],
                                 [(NSNumber *)[boundsArray objectAtIndex:3] floatValue])];
    
    // Get special features of object
    NSDictionary *specials = c.variableContent;
    
    // Get image
    if ((NSString *)[specials objectForKey:@"Image"])
    {
        iV.image = [UIImage imageNamed:[specials objectForKey:@"Image"]];

    }else
    {
        iV.image = [UIImage imageNamed:@"Settings2.3"];
    }
    
    // Add image view to screen and content array
    [self.view addSubview:iV];
    [contentArray addObject:iV];
}

-(void)addGIFView: (NSDictionary *)dict
{
    // Get bounds of object
    NSArray *boundsArray = (NSArray *)[dict objectForKey:@"Bounds"];
    
    // Declare image view
    UIImageView *iV = [[UIImageView alloc] initWithFrame:
                       CGRectMake([(NSNumber *)[boundsArray objectAtIndex:0] floatValue],
                                  [(NSNumber *)[boundsArray objectAtIndex:1] floatValue],
                                  [(NSNumber *)[boundsArray objectAtIndex:2] floatValue],
                                  [(NSNumber *)[boundsArray objectAtIndex:3] floatValue])];
    
    // Get special features of object
    NSDictionary *specials = (NSDictionary *)[dict objectForKey:@"Specials"];
    NSArray *gifArray = (NSArray *)[specials objectForKey:@"GIFs"];
    NSNumber *gifDuration = (NSNumber *)[specials objectForKey:@"GIFDuration"];
    
    // Get image
    if (gifArray.count > 0)
    {
        if (gifDuration && (gifDuration.floatValue != 0))
        {
            NSMutableArray *gifPicArray = [[NSMutableArray alloc] init];
            for (NSString *gifName in gifArray)
            {
                if([UIImage imageNamed:gifName])
                {
                    [gifPicArray addObject: [UIImage imageNamed:gifName]];

                }
            }
            
            iV.animationImages = gifPicArray;
            iV.animationDuration = gifDuration.floatValue;
            iV.animationRepeatCount = 0;
            [iV startAnimating];
        
        }else
        {
            iV.image = [UIImage imageNamed:@"Settings2.3"];
        }
        
    }else
    {
        iV.image = [UIImage imageNamed:@"Settings2.3"];
    }
    
    // Add image view to screen and content array
    [self.view addSubview:iV];
    [contentArray addObject:iV];

}

-(void)a
{
    // Test array
    
    NSMutableArray *a = [[NSMutableArray alloc] init];

    NSMutableDictionary *t = [[NSMutableDictionary alloc] init];
    [t setValue:@"TextView" forKey:@"Type"];
    [t setValue:@[[NSNumber numberWithFloat:100],
                  [NSNumber numberWithFloat:100],
                  [NSNumber numberWithFloat:200],
                  [NSNumber numberWithFloat:200]] forKey:@"Bounds"];
    [t setValue:@"TEXTTEXTTEXT" forKey:@"Text"];


    
    
    NSMutableDictionary *i = [[NSMutableDictionary alloc] init];
    [i setValue:@"Image" forKey:@"Type"];
    [i setValue:@[[NSNumber numberWithFloat:300],
                  [NSNumber numberWithFloat:100],
                  [NSNumber numberWithFloat:200],
                  [NSNumber numberWithFloat:200]] forKey:@"Bounds"];
    [i setValue:[UIImage imageNamed:@"apple_red"] forKey:@"Image"];
    
    NSMutableDictionary *g = [[NSMutableDictionary alloc] init];
    [g setValue:@"GIF" forKey:@"Type"];
    [g setValue:@[[NSNumber numberWithFloat:100],
                  [NSNumber numberWithFloat:500],
                  [NSNumber numberWithFloat:600],
                  [NSNumber numberWithFloat:200]] forKey:@"Bounds"];
    [g setValue: [NSArray arrayWithObjects:
                  [UIImage imageNamed:@"HOME1"],
                  [UIImage imageNamed:@"HOME2"],
                  [UIImage imageNamed:@"HOME2"],
                  [UIImage imageNamed:@"HOME2"],
                  [UIImage imageNamed:@"HOME3"],
                  [UIImage imageNamed:@"HOME3"],
                  [UIImage imageNamed:@"HOME3"],
                  [UIImage imageNamed:@"HOME4"],
                  [UIImage imageNamed:@"HOME4"],
                  [UIImage imageNamed:@"HOME4"],
                  [UIImage imageNamed:@"HOME3"],
                  [UIImage imageNamed:@"HOME3"],
                  [UIImage imageNamed:@"HOME3"],
                  [UIImage imageNamed:@"HOME2"],
                  [UIImage imageNamed:@"HOME2"],
                  [UIImage imageNamed:@"HOME2"],
                  nil]
         forKey:@"GIFs"];
    [g setValue:[NSNumber numberWithFloat:0.8] forKey:@"GIFDuration"];
    
    [a addObjectsFromArray:@[t, i, g]];

}

@end
