// Copyright 2015 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


/// update phone status cod 409 (new phone number already exist)


#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>
#import "FileLogger.h"
#import "MainViewController.h"
#import "Ride.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (strong, nonatomic) UIWindow *window;
@property(strong,nonatomic)NSTimer *timer_monitorBattery;
@property(strong,nonatomic)NSTimer *timer_reachability;
@property(nonatomic,strong)NSMutableArray *array_locations;
@property(nonatomic,strong)NSMutableArray *array_badCount_timestamps;
@property BOOL  isMonitorBattery;
@property BOOL  isinteruption;
@property BOOL movement; //1 is car
@property BOOL BT; //1 is BT connected
@property BOOL passenger; //1 is passenger
@property BOOL walkDrive; //1 is walking
@property BOOL deviceMove; //1 is walking
@property BOOL unlocked; //1 is unlocked
@property BOOL enabled;
@property double currentspeed;
@property BOOL Beacon; //if found beacon
@property double speed; // if speed >5 then speed =1 else if speed <5 during ride then speed 0.5  if speed <5 without ride than speed=0;
@property double manual_speed;
@property (nonatomic,strong) Ride *currentRide;
-(void)gotoMenu;
-(void)repeatSpeech;
-(void)launchBackGroundTask;
-(void)killBackGroundTask;
-(void)startTimer_Reachability;
-(void)stopTimer_Reachability;
-(void)playSpeech:(NSString*)text andVolume:(float)volume;
-(void)logout;
+(BOOL) runningInBackground;
+(BOOL) runningInForeground;
@end

