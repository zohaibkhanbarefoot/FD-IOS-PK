//
//  iBeaconManager.h
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 22/08/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
@class Ride;
@class AppDelegate;
@interface iBeaconManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) AppDelegate* appDelegate;
//@property (nonatomic, strong) AVQueuePlayer *player;

@property BOOL isDecoBeaconDuringRide;
+(iBeaconManager *)sharedInstance;

-(void)startBeaconLostTimer:(BOOL) isstart;
-(void)startLocation;
-(void)stopLocation;
-(void)resumeLocation;

@end
