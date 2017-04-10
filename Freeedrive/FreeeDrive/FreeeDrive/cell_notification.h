//
//  cell_notification.h
//  EddystoneScannerSample
//
//  Created by user on 4/01/2017.
//
//

#import <UIKit/UIKit.h>

@interface cell_notification : UITableViewCell
@property(nonatomic,weak)IBOutlet UILabel *lbl_title;
@property(nonatomic,weak)IBOutlet UILabel *lbl_message;
@property(nonatomic,weak)IBOutlet UIButton *btn_dropdown;
-(void)setText_message: (NSString *) text;
-(void)setText: (NSString *) text;
@end
