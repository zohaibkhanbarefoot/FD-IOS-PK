//
//  MyProfile.h
//  EddystoneScannerSample
//
//  Created by user on 6/01/2017.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MyProfile : BaseViewController
-(IBAction)buttonPressed:(id)sender;

@property (nonatomic) BOOL accountMode;
@property(nonatomic,weak)IBOutlet UIView *view_newPhoneNum;
@property(nonatomic,weak)IBOutlet UITextField *txt_oldPhoneNum;
@property(nonatomic,weak)IBOutlet UITextField *txt_newPhoneNum;



@property(weak , nonatomic) IBOutlet UILabel *newphNoLabel;
@property(weak , nonatomic) IBOutlet UILabel * newconnectorLabel;
@property (weak, nonatomic) IBOutlet UIButton *newph_hereButton;
@property (weak, nonatomic) IBOutlet UIButton *newconnector_hereButton;
@property (weak,nonatomic) IBOutlet UIButton *updatePhButton;
@property (weak,nonatomic) IBOutlet UIButton *cancelButton;

-(IBAction)newph_hereButton_clicked:(id)sender;
-(IBAction)newconnector_hereButton_clicked:(id)sender;
-(IBAction)btn_updatePhNum:(id)sender;
-(IBAction)btn_cancel_clicked:(id)sender;

@end
