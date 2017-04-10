//
//  synchronizationManager.h
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 14/10/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
@interface SynchronizationManager : NSObject
@property BOOL issyncnow;
+(SynchronizationManager *)sharedInstance;
- (void)startSynchroIfNeeded;

@property (nonatomic,strong) id <notify_syncComplete> delegate;
@end
