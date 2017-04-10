//
//  cell_menu.h
//  EddystoneScannerSample
//
//  Created by user on 4/01/2017.
//
//

#import <UIKit/UIKit.h>

@interface cell_menu : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel *lbl_item;
@property(nonatomic,weak)IBOutlet UISwitch *switch_findmycar;


@property(nonatomic,weak)IBOutlet UILabel *lbl_title;
@property(nonatomic,weak)IBOutlet UILabel *lbl_message1;
@property(nonatomic,weak)IBOutlet UISlider *slider_speed;
@property(nonatomic,weak)IBOutlet UILabel *lbl_message2;
@property(nonatomic,weak)IBOutlet UILabel *lbl_message3;
@property(nonatomic,weak)IBOutlet UILabel *lbl_message4;
@end
