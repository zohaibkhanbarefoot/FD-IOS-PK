//
//  Contactus.h
//  EddystoneScannerSample
//
//  Created by user on 5/01/2017.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Contactus : BaseViewController


@property(nonatomic,weak)IBOutlet UILabel *lbl_title;
@property(nonatomic,weak)IBOutlet UITextView *txtView_message;
@property(nonatomic,weak)IBOutlet UIButton *btn_cross;
@property(nonatomic,weak)IBOutlet UIButton *btn_send;
-(IBAction)btn_send_clicked:(id)sender;
-(IBAction)btn_cross_clicked:(id)sender;

@end
