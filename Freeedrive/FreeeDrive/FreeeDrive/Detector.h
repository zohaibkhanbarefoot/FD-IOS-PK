//
//  Detector.h
//  FreeeDriveStore
//
//  Created by KL on 3/22/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>
#import "UDOperator.h"
#import <CoreLocation/CoreLocation.h>
#import "BaseViewController.h"
#import "AppDelegate.h"

#define kTresholdMoved 0.1f                      //0.1 rotation on any axis
#define kTresholdBytes 1E5                      //10KB, i.e a couple flicks in Facebook
#define kTresholdBattery 0.005f                  //2%
#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

@interface Detector : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic) double rotationX, rotationY, rotationZ;
@property (nonatomic) BOOL moved, goodUsage, processing, inBackground, keyboardUsed;
@property (nonatomic) long sentBytes, receivedBytes;
@property (nonatomic) double batteryLevel;
/*@property (strong, nonatomic) CLLocationManager *locationManager;
 @property (strong, nonatomic) NSDate *lastNotificationTimestamp;
 @property (strong, nonatomic) CLLocation *location;
 @property (strong, nonatomic) NSURL *presentedItemURL;

  */
@property (strong, nonatomic) NSString *frameWorkPath;
@property (strong,nonatomic) AppDelegate *appDelegate;

+(Detector *)singleton;
-(id)init;
-(void)startDetection;
-(void)stopMovementDetection;

//- (NSArray *)getDataCounters;
-(int)screenBrightness;
//-(BOOL)isScreenLocked;
//-(void)logBluetooth:(BOOL )bluetoothConnected;

@end
