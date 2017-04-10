//
//  BaseViewController.m
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark -
#pragma mark Init / Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.topBarView)
    {
        //add top body
        self.topBarView = [[[NSBundle mainBundle]loadNibNamed:@"TopBarView" owner:nil options:nil]objectAtIndex:0];
        [self.view addSubview:self.topBarView];
        CGRect frame = self.topBarView.frame;
        frame.origin.y = 0.0f;
        frame.origin.x = 0.0f;
        frame.size.width = self.view.frame.size.width;
        self.topBarView.frame = frame;
        
        //color upper side
      UIView *v = [self.topBarView viewWithTag:-1];
      [v setBackgroundColor:[UIColor bleuColor]];
        
        //menu button
        self.menuButton = [self.topBarView viewWithTag:-2];
               //back button
        self.backButton = [self.topBarView viewWithTag:-3];
        
        
        self.syncHiddenButton = [self.topBarView viewWithTag:-5];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
