//
//  CreditsViewController.m
//  FreeeDriveStore
//
//  Created by KL on 3/13/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "CreditsViewController.h"
#import "MainViewController.h"
@interface CreditsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UILabel *topLabel, *tanguy1Label, *tanguy2Label, *gus1Label, *gus2Label, *mora1Label, *mora2Label, *salim1Label, *salim2Label, *fdLabel, *codeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@end
@implementation CreditsViewController
#pragma mark -
#pragma mark Init / Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //configure UI
   // [self.wheelButton setHidden:YES];
    [self.backButton setHidden:NO];

    [self.menuButton setHidden:YES];
    
    
     [self.menuButton setUserInteractionEnabled:YES];
    [self.backButton addTarget:self action:@selector(ok:) forControlEvents:UIControlEventAllTouchEvents];
  //  [self.wheelButton setHidden:YES];
    [[UIUtils singleton]configureButton:self.okButton withSyle:@"bold" size:21.0f andTitle:LocalizedString(@"ok", nil)];
    
//    [[UIUtils singleton]configureLabel:self.topLabel withSyle:@"normal" size:19.0f color:[UIColor blueishColor] andText:LocalizedString(@"credits", nil)];
//    [[UIUtils singleton]configureLabel:self.tanguy1Label withSyle:@"normal" size:21.0f color:[UIColor bleuColor] andText:LocalizedString(@"tanguy1", nil)];
//    [[UIUtils singleton] boldify:self.tanguy1Label withSize:21.0f];
//    [[UIUtils singleton]configureLabel:self.tanguy2Label withSyle:@"normal" size:17.0f color:[UIColor blueishColor] andText:LocalizedString(@"tanguy2", nil)];
//    [[UIUtils singleton]configureLabel:self.gus1Label withSyle:@"normal" size:21.0f color:[UIColor bleuColor] andText:LocalizedString(@"gus1", nil)];
//    [[UIUtils singleton] boldify:self.gus1Label withSize:21.0f];
//    [[UIUtils singleton]configureLabel:self.gus2Label withSyle:@"normal" size:17.0f color:[UIColor blueishColor] andText:LocalizedString(@"gus2", nil)];
//    [[UIUtils singleton]configureLabel:self.mora1Label withSyle:@"normal" size:21.0f color:[UIColor bleuColor] andText:LocalizedString(@"mora1", nil)];
//    [[UIUtils singleton] boldify:self.mora1Label withSize:21.0f];
//    [[UIUtils singleton]configureLabel:self.mora2Label withSyle:@"normal" size:17.0f color:[UIColor blueishColor] andText:LocalizedString(@"mora2", nil)];
     
    [[UIUtils singleton] configureLabel:self.salim1Label
                              withSyle:@"normal"
                                  size:19.0f
                                 color:[UIColor blueishColor]
                               andText:@"www.freeedrive.com"];
    
    
    UITapGestureRecognizer *tapGestureRecognizer
    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lbl_link_clicked:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.salim1Label addGestureRecognizer:tapGestureRecognizer];
    self.salim1Label.userInteractionEnabled = YES;
    
    //
    [[UIUtils singleton] configureLabel:self.salim2Label
                              withSyle:@"normal"
                                  size:19.0f
                                 color:[UIColor blueishColor]
                               andText:[NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    
    self.salim1Label.hidden = NO;
    self.salim2Label.hidden = NO;
    
    [[UIUtils singleton] configureLabel:self.codeLabel
                               withSyle:@"normal"
                                   size:19.0f
                                  color:[UIColor blueishColor]
                                andText:@"© Freeedrive 2016"];
    
    [[UIUtils singleton] configureLabel:self.fdLabel
                               withSyle:@"normal"
                                   size:19.0f
                                  color:[UIColor blueishColor]
                                andText:[NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    self.fdLabel.hidden = YES;
     self.codeLabel.hidden = YES;
    
    if([UIScreen mainScreen].bounds.size.height < 568.0f)
    {
        self.topConstraint.constant -= 30.0f;
    }
}

-(void)lbl_link_clicked:(id)sender{

    NSURL *url = [NSURL URLWithString:@"http://www.freeedrive.com"];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
      //  NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UI Actions

-(IBAction)ok:(id )sender
{
    
    [self.menuButton setUserInteractionEnabled:NO];
    
 
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        if ([controller isKindOfClass:[MainViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }

    
    
}

@end
