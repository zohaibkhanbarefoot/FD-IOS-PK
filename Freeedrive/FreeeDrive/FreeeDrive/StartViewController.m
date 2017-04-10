//
//  ViewController.m
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "StartViewController.h"
#import "SignupViewController.h"
#import "LoginViewController.h"
#import "NotVerifiedViewController.h"
#import "MainViewController.h"
#import "SlideNavigationController.h"
#import "RateUsViewController.h"
#import "QRCodeScanner.h"

@interface StartViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton, *signupButton;
@end
@implementation StartViewController
#pragma mark -
#pragma mark Init / Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //configure UI
    
    
      

    
    [self.navigationController setNavigationBarHidden:YES];
    [self.menuButton setHidden:YES];
    [self.backButton setHidden:YES];
  
}

-(void)viewWillAppear:(BOOL)animated{

    [[UIUtils singleton]configureButton:self.loginButton withSyle:@"normal" size:19 andTitle:LocalizedString(@"login", nil)];
    [[UIUtils singleton]configureButton:self.signupButton withSyle:@"normal" size:19 andTitle:LocalizedString(@"signup", nil)];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UI Actions

-(IBAction)buttonPressed:(id)sender
{
    if(sender == self.loginButton)
    {
      LoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
      [[SlideNavigationController sharedInstance] pushViewController:loginController animated:YES];
        }
    else
    {
        //RateUsViewController *rate = [self.storyboard instantiateViewControllerWithIdentifier:@"RateUsViewController"];
        //[self.navigationController pushViewController:rate animated:YES];
        
        //AutoReplyViewController *ar = [self.storyboard instantiateViewControllerWithIdentifier:@"AutoReplyViewController"];
        //[self.navigationController pushViewController:ar animated:YES];
        
        SignupViewController *signupController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignupViewController"];
        [self.navigationController pushViewController:signupController animated:YES];
        //SentEmailViewController *sentController = [self.storyboard instantiateViewControllerWithIdentifier:@"SentEmailViewController"];
        //[self.navigationController pushViewController:sentController animated:YES];
        //NotVerifiedViewController *notController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotVerifiedViewController"];
        //[self.navigationController pushViewController:notController animated:YES];
        
        //NoContractViewController *noController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoContractViewController"];
        //[self.navigationController pushViewController:noController animated:YES];
        
        //MainViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        //[self.navigationController pushViewController:mainController animated:YES];
    }
}

@end
