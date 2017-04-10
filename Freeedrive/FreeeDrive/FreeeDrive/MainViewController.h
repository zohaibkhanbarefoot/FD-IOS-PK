//
//  MainViewController.h
//  FreeeDriveStore
//
//  Created by KL on 3/9/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "BaseViewController.h"
////#import "MDBluetoothManager.h"
#import "LMGaugeView.h"
#import "AppDelegate.h"
#import "SlideNavigationController.h"


@protocol notify_syncComplete <NSObject>
- (void)sync_completed;
@end
@interface MainViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, LMGaugeViewDelegate,SlideNavigationControllerDelegate>

{
    BOOL isGuageLast;
    float kSideMenuWidth;


}
//@property(nonatomic,strong)  AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet LMGaugeView *gaugeLastRide;
@end
