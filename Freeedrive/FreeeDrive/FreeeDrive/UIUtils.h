//
//  UIUtils.h
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+FreeeDrive.h"

@interface UIUtils : NSObject

+(UIUtils *)singleton;

-(void)configureButton:(UIButton *)button withSyle:(NSString *)style size:(CGFloat)size andTitle:(NSString *)title;
-(void)configureLabel:(UILabel *)label withSyle:(NSString *)style size:(CGFloat)size color:(UIColor *)color andText:(NSString *)text;
-(void)configureLabelForScore:(UILabel *)label withSyle:(NSString *)style size:(CGFloat)size color:(UIColor *)color andText:(NSString *)text;
-(void)configureField:(UITextField *)field withSyle:(NSString *)style size:(CGFloat)size color:(UIColor *)color andHint:(NSString *)text;
-(void)configureTextView:(UITextView *)textView withSyle:(NSString *)style size:(CGFloat)size color:(UIColor *)color andText:(NSString *)text;
-(void)boldify:(UILabel *)label withSize:(CGFloat )size;

@end
