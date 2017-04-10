//
//  SignupViewController.h
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "BaseViewController.h"
#import "FRHyperLabel.h"
@interface SignupViewController : BaseViewController <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL accountMode;



//termsandcondition
@property(nonatomic,weak)IBOutlet UIView *view_termsCondition;
@property(nonatomic,weak)IBOutlet UILabel *lbl_terms_title;
@property(nonatomic,weak)IBOutlet UILabel *lbl_termas_detail;
@property(nonatomic,weak)IBOutlet FRHyperLabel *lbl_privacyPolicy;
@property (nonatomic,weak)IBOutlet UIButton *btn_accept;
-(IBAction)btn_accept_clicked:(id)sender;

@end
