//
//  RateUsViewController.m
//  FreeeDriveStore
//
//  Created by KL on 3/14/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "RateUsViewController.h"
#import "UITextView+Placeholder.h"
#import "MBProgressHUD.h"
#import "UDOperator.h"
#import "MainViewController.h"

@interface RateUsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton, *sendButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation RateUsViewController

#pragma mark -
#pragma mark Init / Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.backButton setHidden:NO];
   // [self.wheelButton setHidden:YES];
    [self.backButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventAllTouchEvents];

    [[UIUtils singleton]configureButton:self.sendButton withSyle:@"bold" size:21.0f andTitle:LocalizedString(@"send", nil)];
    [[UIUtils singleton]configureButton:self.cancelButton withSyle:@"normal" size:21.0f andTitle:LocalizedString(@"cancel", nil)];
    [[UIUtils singleton]configureLabel:self.topLabel withSyle:@"normal" size:19.0f color:[UIColor blueishColor] andText:LocalizedString(@"rate", nil)];
    [self.textView setPlaceholder:LocalizedString(@"write_here", nil)];
    [self.textView setPlaceholderColor:[UIColor bleuColor]];
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [UIColor bleuColor].CGColor;
    [[UIUtils singleton]configureTextView:self.textView withSyle:@"normal" size:15.0f color:[UIColor bleuColor] andText:@""];
    if([UIScreen mainScreen].bounds.size.height < 568.0f)
        self.topConstraint.constant = 90.0f;
    
    
    
    
    //dismiss keyboard on tap
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
    [viewTap setDelegate:self];
    [self.view addGestureRecognizer:viewTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UI Actions

-(IBAction)send:(id)sender
{
    [self rateUs];
}

-(IBAction)cancel:(id)sender
{

    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        if ([controller isKindOfClass:[MainViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }



}

-(void)dismiss:(id )sender
{
    [self.textView resignFirstResponder];
    if([UIScreen mainScreen].bounds.size.height >= 568.0f)
        return;
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:
     ^{
         self.topConstraint.constant = 120.0f;
         [self.view layoutIfNeeded];
     }
                     completion:^(BOOL finished){
                     }];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([UIScreen mainScreen].bounds.size.height >= 568.0f)
        return YES;
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:
     ^{
         self.topConstraint.constant = 30.0f;
         [self.view layoutIfNeeded];
     }
                     completion:^(BOOL finished){
                     }];
    
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark API

-(void)rateUs
{
    if([self.textView.text length] == 0 || [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"rate_invalid", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *auth = [[NSUserDefaults standardUserDefaults]  valueForKey:@"auth"];
    [payload setObject:auth forKey:@"authorization"];
    [payload setObject:self.textView.text forKey:@"message"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UDOperator singleton]postRateUs:payload withCompletionBlock:^(id response){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if(response && [response isKindOfClass:[NSNumber class]]){
            long status = [response longValue ];
            if(status == 200){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:LocalizedString(@"feedback_ok", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:LocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                NSString *error = [response objectForKey:@"error"];
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                            message:error
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
            }
        }
    }];
}

@end
