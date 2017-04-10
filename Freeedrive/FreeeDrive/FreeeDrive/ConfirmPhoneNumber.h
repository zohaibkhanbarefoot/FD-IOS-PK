//
//  ConfirmPhoneNumber.h
//  EddystoneScannerSample
//
//  Created by user on 30/12/2016.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface ConfirmPhoneNumber : BaseViewController

@property (nonatomic,weak)IBOutlet UIButton *nextButton;
@property (nonatomic,weak)IBOutlet UIButton *sendAgainButton;
@property (nonatomic,weak)IBOutlet UITextField *confirmTextField;
@property(nonatomic,weak)IBOutlet UILabel *firstTitleLabel;
@property(nonatomic,weak)IBOutlet UILabel *secTitleLabel;
@property(nonatomic,weak)IBOutlet UILabel *confirmMessLabel;
@property(nonatomic,assign)BOOL isupdate;
@property(nonatomic,strong)NSString *phone_number;
-(IBAction)nextButtonClicked:(id)sender;
-(IBAction)sendAgainButtonClicked:(id)sender;


@end
