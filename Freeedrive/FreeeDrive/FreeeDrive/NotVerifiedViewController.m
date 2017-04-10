//
//  NotVerifiedViewController.m
//  FreeeDriveStore
//
//  Created by KL on 3/9/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "NotVerifiedViewController.h"
#import "UDOperator.h"
#import "MBProgressHUD.h"

@interface NotVerifiedViewController ()

@property (weak, nonatomic) IBOutlet UIButton *yesButton, *noButton;
@property (weak, nonatomic) IBOutlet UILabel *sentLabel;

@end

@implementation NotVerifiedViewController

#pragma mark - Init / Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

   // [self.wheelButton setHidden:YES];
    [self.backButton setHidden:NO];
    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [[UIUtils singleton]configureButton:self.yesButton withSyle:@"bold" size:21.0f andTitle:LocalizedString(@"yes", nil)];
    [[UIUtils singleton]configureButton:self.noButton withSyle:@"bold" size:21.0f andTitle:LocalizedString(@"no", nil)];
    [[UIUtils singleton]configureLabel:self.sentLabel withSyle:@"normal" size:19.0f color:[UIColor bleuColor] andText:LocalizedString(@"not_verified", nil)];
    self.yesButton.hidden = YES;
    self.noButton.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  UI Actions

-(void)back:(id )sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)yes:(id)sender
{
    }

-(IBAction)no:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
