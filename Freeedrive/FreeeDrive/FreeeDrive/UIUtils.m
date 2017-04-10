//
//  UIUtils.m
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils

static UIUtils *gInstance = NULL;

#pragma mark -
#pragma mark Init / Lifecycle

+(UIUtils *)singleton
{
    @synchronized(self)
    {
        if(gInstance == NULL)
        {
            gInstance = [[UIUtils alloc]init];
        }
    }
    
    return gInstance;
}

-(id)init
{
    self = [super init];
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark -
#pragma mark - Utility methods

-(void)configureButton:(UIButton *)button withSyle:(NSString *)style size:(CGFloat)size andTitle:(NSString *)title
{
    
    
    

    if([style isEqualToString:@"normal"])
       [button.titleLabel setFont:[UIFont fontWithName:@"DINNextLTPro-LightCondensed" size:size]];
   else
    [button.titleLabel setFont:[UIFont fontWithName:@"DINNextLTPro-MediumCond" size:size]];
   // button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor bleuColor] forState:UIControlStateNormal];
}

-(void)configureLabel:(UILabel *)label withSyle:(NSString *)style size:(CGFloat)size color:(UIColor *)color andText:(NSString *)text
{
    if([style isEqualToString:@"normal"])
    {
        [label setFont:[UIFont fontWithName:@"DINNextLTPro-LightCondensed" size:size]];
    }
    else if([style isEqualToString:@"textcenter"]){
        [label setFont:[UIFont fontWithName:@"DINNextLTPro-MediumCond" size:size]];
        [label setTextAlignment:NSTextAlignmentCenter];

    }
    else if([style isEqualToString:@"normal_leftallign"]){
        [label setFont:[UIFont fontWithName:@"DINNextLTPro-LightCondensed" size:size]];
        [label setTextAlignment:NSTextAlignmentLeft];
        
    }
    else if([style isEqualToString:@"normal_center"]){
        
           [label setFont:[UIFont fontWithName:@"DINNextLTPro-LightCondensed" size:size]];
        [label setTextAlignment:NSTextAlignmentCenter];
    }

   
    else
    {
        
    [label setFont:[UIFont fontWithName:@"DINNextLTPro-MediumCond" size:size]];
    }
    [label setText:text];
    [label setTextColor:color];
}

-(void)configureLabelForScore:(UILabel *)label withSyle:(NSString *)style size:(CGFloat)size color:(UIColor *)color andText:(NSString *)text
{
    [label setText:text];
    [label setFont:[UIFont fontWithName:@"DINNextLTPro-MediumCond" size:size]];
    [label setTextColor:(color ? color:[UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [label setBackgroundColor:([style isEqualToString:@"sublabel"] ? [UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1.0]:[UIColor clearColor])];
    label.layer.cornerRadius = [style isEqualToString:@"sublabel"] ? 1:label.layer.cornerRadius;
    label.textAlignment = NSTextAlignmentCenter;
    label.clipsToBounds = YES;
}

-(void)configureField:(UITextField *)field withSyle:(NSString *)style size:(CGFloat)size color:(UIColor *)color andHint:(NSString *)text
{
    if([style isEqualToString:@"normal"])
        [field setFont:[UIFont fontWithName:@"DINNextLTPro-LightCondensed" size:size]];
    else
        [field setFont:[UIFont fontWithName:@"DINNextLTPro-MediumCond" size:size]];
    [field setPlaceholder:text];
    [field setTextColor:color];
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
}

-(void)configureTextView:(UITextView *)textView withSyle:(NSString *)style size:(CGFloat)size color:(UIColor *)color andText:(NSString *)text
{
    if([style isEqualToString:@"normal"])
        [textView setFont:[UIFont fontWithName:@"DINNextLTPro-LightCondensed" size:size]];
    else
        [textView setFont:[UIFont fontWithName:@"DINNextLTPro-MediumCond" size:size]];
    [textView setTextColor:color];
}

-(void)boldify:(UILabel *)label withSize:(CGFloat )size
{
    NSString *string = label.text;
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *regularFont = [UIFont fontWithName:@"DINNextLTPro-LightCondensed" size:size];
    UIFont *boldFont = [UIFont fontWithName:@"DINNextLTPro-MediumCond" size:size];
    NSUInteger index = [string rangeOfString:@" - "].location;
    [attString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, index)];
    [attString addAttribute:NSFontAttributeName value:regularFont range:NSMakeRange(index + 1, string.length - (index + 1))];
    [label setAttributedText:attString];
}




@end
