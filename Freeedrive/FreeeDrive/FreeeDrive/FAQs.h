#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "FRHyperLabel.h"
@interface FAQs : BaseViewController
@property(nonatomic,weak)IBOutlet UITableView *tbl_view;
@property(nonatomic,weak)IBOutlet UILabel *lbl_headerTitle;
@property(nonatomic,weak)IBOutlet UIButton *btn_cross;

@property(nonatomic,weak)IBOutlet UILabel *lbl_versionInfo;
@property(nonatomic,weak)IBOutlet FRHyperLabel *lbl_website;
@property(nonatomic,weak)IBOutlet UITextView *txtview_website;

-(IBAction)btn_cross_clicked:(id)sender;
-(IBAction)btn_linkclicked:(id)sender;
@end
