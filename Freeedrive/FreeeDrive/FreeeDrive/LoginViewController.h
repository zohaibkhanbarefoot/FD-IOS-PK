//
//  LoginViewController.h
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "BaseViewController.h"
#import "FRHyperLabel.h"
@interface LoginViewController : BaseViewController
@property(nonatomic,weak)IBOutlet UIView *view_newPhoneNum;
@property(nonatomic,weak)IBOutlet UITextField *txt_oldPhoneNum;
@property(nonatomic,weak)IBOutlet UITextField *txt_newPhoneNum;

@property (weak,nonatomic) IBOutlet UIButton *updatePhButton;
@property (weak,nonatomic) IBOutlet UIButton *cancelButton;

-(IBAction)newph_hereButton_clicked:(id)sender;
-(IBAction)newconnector_hereButton_clicked:(id)sender;
-(IBAction)btn_updatePhNum:(id)sender;
-(IBAction)btn_cancel_clicked:(id)sender;
@property (nonatomic,weak)IBOutlet UIButton *btn_selectContryCode;
-(IBAction)btn_selectContryCode:(id)sender;




//termsandcondition
@property(nonatomic,weak)IBOutlet UIView *view_termsCondition;
@property(nonatomic,weak)IBOutlet UILabel *lbl_terms_title;
@property(nonatomic,weak)IBOutlet UILabel *lbl_termas_detail;
@property(nonatomic,weak)IBOutlet FRHyperLabel *lbl_privacyPolicy;
@property (nonatomic,weak)IBOutlet UIButton *btn_accept;
-(IBAction)btn_accept_clicked:(id)sender;
@end
