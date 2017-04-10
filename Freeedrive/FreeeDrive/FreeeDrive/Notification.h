//
//  Notification.h
//  EddystoneScannerSample
//
//  Created by user on 4/01/2017.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Notification : BaseViewController
@property(nonatomic,weak)IBOutlet UITableView *tbl_view;
@property(nonatomic,weak)IBOutlet UILabel *lbl_headerTitle;
@property(nonatomic,weak)IBOutlet UIButton *btn_cross;
@property(nonatomic,weak)IBOutlet UILabel *lbl_noNotifcations;
@property(nonatomic,strong)UIRefreshControl *refreshConrol;
-(IBAction)btn_cross_clicked:(id)sender;
@end
