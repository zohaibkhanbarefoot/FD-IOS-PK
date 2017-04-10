//
//  KeepAliveManager.h
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 14/10/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeepAliveManager : NSObject


+(KeepAliveManager *)sharedInstance;

-(void)keepAlive:(BOOL)backgroundTaskNeeded;
-(void)stopKeepAlive;
-(void)launchBackGroundTask;

@end
