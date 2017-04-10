//
//  MTBViewController.h
//  MTBBarcodeScannerExample
//
//  Created by Mike Buss on 2/8/14.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface QRCodeScanner : BaseViewController


@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property(nonatomic,weak)IBOutlet UILabel *firstTitleLabel;
@property(nonatomic,weak)IBOutlet UILabel *secTitleLabel;
@property(nonatomic,strong)NSString *phone_number;

@end
