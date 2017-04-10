//
//  BaseViewController.h
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "UIUtils.h"
#import "Localization.h"

#define LocalizedString(key, comment) [[Localization singleton] localizedStringForKey:(key) value:(comment)]

@interface BaseViewController : UIViewController

@property (strong, nonatomic) UIView *topBarView;
@property (strong, nonatomic) UIButton *menuButton, *backButton , *syncHiddenButton;
@end
