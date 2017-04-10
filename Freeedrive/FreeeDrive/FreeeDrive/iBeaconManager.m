//
//  iBeaconManager.m
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 22/08/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import "iBeaconManager.h"
#import "AppDelegate.h"
#import "KeepAliveManager.h"
#import "SOLocationManager.h"
#import "SOMotionDetector.h"
@implementation iBeaconManager{
@private BOOL hasStopped;
@private BOOL alreadyEnter;
@private BOOL found;
    NSTimer* myTimer;
    bool lost;
    NSTimer *lostimer;
    NSTimer *losttimer_temp;
    int timesSearchedFor;
    
}

+(iBeaconManager *)sharedInstance{
    static dispatch_once_t onceToken;
    static iBeaconManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        if(sharedInstance == nil){
            sharedInstance = [[self alloc]init];
        }
    });
    return sharedInstance;
}
-(void)initBeacon{
    
    if (!self.locationManager){
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[self formateuuid]];
        NSLog(@"mybeaconid= %@",[self formateuuid]);
        //NSLog(@"init beacon");
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        

        [self.locationManager requestWhenInUseAuthorization];
        
      // Create a NSUUID with the same UUID as the broadcasting beacon
      //  NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BEACON];
        
      // Setup a new region with that UUID and same identifier as the broadcasting beacon
        self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                      major:BEACON_MAJOR
                                                                      minor:BEACON_MINOR
                                                                 identifier:BEACON_IDENTIFIER];
        self.myBeaconRegion.notifyEntryStateOnDisplay = YES;
        // Tell location manager to start monitoring for the beacon region
        
        [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
      //  [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    }
}

- (void)startLocation{
    
    [self initBeacon];
    // Check if beacon monitoring is available for this device
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitoring not available"
                                                        message:@"iBeacon detection are not available with your device"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
}

- (void)stopLocation{
    
    
    
    if(self.myBeaconRegion){
   [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
   [self.locationManager stopMonitoringForRegion:self.myBeaconRegion];
    }
   //self->hasStopped = YES;
  //  self.locationManager=nil;
    
    // [self.locationManager stopUpdatingHeading];
    // [self.locationManager stopMonitoringVisits];
}

- (void)resumeLocation{
    

    if(!self.locationManager){
        [self startLocation];
        return;
    }
    
   // NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BEACON];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[self formateuuid]];
    // Setup a new region with that UUID and same identifier as the broadcasting beacon
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                  major:BEACON_MAJOR
                                                                  minor:BEACON_MINOR
                                                             identifier:BEACON_IDENTIFIER];
    self.myBeaconRegion.notifyEntryStateOnDisplay = YES;
    
    // Tell location manager to start monitoring for the beacon region
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
    
    
}

#pragma mark - monitoring event
//Auto start go here
- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region{
    // We entered a region, now start looking for our target beacons!\
    
    

    
    self.isDecoBeaconDuringRide=NO;
    [losttimer_temp invalidate];
    losttimer_temp=nil;
    [lostimer invalidate];
    lostimer=nil;
    
    
    [[KeepAliveManager sharedInstance] keepAlive:YES];
     [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    
    if(!_appDelegate.Beacon ){
        alreadyEnter= YES;
    
    
    
    [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = YES;
    //Starting motion detector
        
        
        
      
        [[SOMotionDetector sharedInstance] startDetection];
        
        UILocalNotification *notification = [UILocalNotification new];
        
        NSString *str_hi=[[Localization singleton] localizedStringForKey:@"hi" value:nil];
        NSString *str_welcomeMessage=[[Localization singleton] localizedStringForKey:@"welcome_back_Ready_for_a_safe_drive" value:nil];
        notification.alertBody = [NSString stringWithFormat:@"%@ %@, %@", str_hi,[[[NSUserDefaults standardUserDefaults]objectForKey:@"account"] objectForKey:@"first_name"],str_welcomeMessage];
        

    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    _appDelegate.speed=0;
    _appDelegate.Beacon=YES;
    _appDelegate.BT=YES;
       // [[SOLocationManager sharedInstance] reset:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"btFoundFromAuto" object:nil];


   
    
        
    }
  
}
-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion *)region
{
    
    
    if(_appDelegate.speed==2){

        self.isDecoBeaconDuringRide=YES;
    }
    else{
        self.isDecoBeaconDuringRide=NO;
    if(!losttimer_temp)
    losttimer_temp=   [NSTimer scheduledTimerWithTimeInterval:beaconLostTimerVal
                                                 target:self
                                               selector:@selector(outofregion)
                                               userInfo:nil
                                                repeats:NO];
    }
    

    
    
}

-(void)startBeaconLostTimer:(BOOL) isstart{

    
    
    NSLog(@"I am check connectivity");

    
    
    if(!isstart)
    {
    
        [losttimer_temp invalidate];
        losttimer_temp=nil;
    }
    else{
    if(!losttimer_temp)
        losttimer_temp=   [NSTimer scheduledTimerWithTimeInterval:beaconLostTimerVal
                                                           target:self
                                                         selector:@selector(outofregion)
                                                         userInfo:nil
                                                          repeats:NO];
    }


}

-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region
{
    // Beacon found!
    //self.statusLabel.text = @"Beacon found!";
  //  NSLog(@"beacoun found");
    //CLBeacon *foundBeacon = [beacons firstObject];
    // You can retrieve the beacon data from its properties
    //NSString *uuid = foundBeacon.proximityUUID.UUIDString;
    //NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
    //NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
}
//09edc26d-80cc-493c-b8f5-9cd035c4
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (state == CLRegionStateInside ){
        NSLog(@"is in the target region");
        self.isDecoBeaconDuringRide=NO;
        [losttimer_temp invalidate];
        losttimer_temp=nil;
        [lostimer invalidate];
        lostimer=nil;
        [[KeepAliveManager sharedInstance] keepAlive:YES];
         _appDelegate.speed=0;
        if(!_appDelegate.Beacon ){
            alreadyEnter= YES;
        [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = YES;
        //Starting motion detector
            
           
                [[SOMotionDetector sharedInstance] startDetection];
            

        
        UILocalNotification *notification = [UILocalNotification new];
        NSString *str_hi=[[Localization singleton] localizedStringForKey:@"hi" value:nil];
        NSString *str_welcomeMessage=[[Localization singleton] localizedStringForKey:@"welcome_back_Ready_for_a_safe_drive" value:nil];
        notification.alertBody = [NSString stringWithFormat:@"%@ %@, %@", str_hi,[[[NSUserDefaults standardUserDefaults]objectForKey:@"account"] objectForKey:@"first_name"],str_welcomeMessage];
       [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        _appDelegate.Beacon=YES;
        _appDelegate.BT=YES;
      //  [[SOLocationManager sharedInstance] reset:YES];
         _appDelegate.speed=0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"btFoundFromAuto" object:nil];
        
        }
        
    }else if (state == CLRegionStateOutside){
        NSLog(@"is out of target region");
        if(_appDelegate.speed==2){
         self.isDecoBeaconDuringRide=YES;
        
        }
        else{
        self.isDecoBeaconDuringRide=NO;
        if(!losttimer_temp)
        losttimer_temp=   [NSTimer scheduledTimerWithTimeInterval:beaconLostTimerVal
                                                           target:self
                                                         selector:@selector(outofregion)
                                                         userInfo:nil
                                                          repeats:NO];
            
        }

        
    }else{
        NSLog(@"Unknown region state , invalid uuid ?");
    }
}

-(void)outofregion{

 
   /*NSLog(@"is in the target region");
    self.isDecoBeaconDuringRide=NO;
    [losttimer_temp invalidate];
    losttimer_temp=nil;
    [lostimer invalidate];
    lostimer=nil;
    [[KeepAliveManager sharedInstance] keepAlive:YES];
    _appDelegate.speed=0;
    if(!_appDelegate.Beacon ){
        alreadyEnter= YES;
        [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = YES;
        //Starting motion detector
        [[SOMotionDetector sharedInstance] startDetection];
        
        UILocalNotification *notification = [UILocalNotification new];
        
        NSString *str_hi=[[Localization singleton] localizedStringForKey:@"hi" value:nil];
        NSString *str_welcomeMessage=[[Localization singleton] localizedStringForKey:@"welcome_back_Ready_for_a_safe_drive" value:nil];
        notification.alertBody = [NSString stringWithFormat:@"%@ %@, %@", str_hi,[[[NSUserDefaults standardUserDefaults]objectForKey:@"account"] objectForKey:@"first_name"],str_welcomeMessage];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        _appDelegate.Beacon=YES;
        _appDelegate.BT=YES;
        //  [[SOLocationManager sharedInstance] reset:YES];
        _appDelegate.speed=0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"btFoundFromAuto" object:nil];
    }*/
  
   _appDelegate.speed=0;
    if(_appDelegate.Beacon){
        alreadyEnter=false;
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertTitle =@"Lost";
        notification.alertBody = @"You beacon has disconnected";
      //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        _appDelegate.Beacon=NO;
        _appDelegate.BT=NO;
        _appDelegate.speed=0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"btFoundFromAuto" object:nil];
    }
    _isDecoBeaconDuringRide=NO;
    //lang_changed_menu
    // [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = NO;
    [lostimer invalidate];
    lostimer=nil;
    lostimer=   [NSTimer scheduledTimerWithTimeInterval:locServiceStopTimerVal
                                                 target:self
                                               selector:@selector(lostimer_timeout)
                                               userInfo:nil
                                                repeats:NO];
   
}

-(void)lostimer_timeout{
    if(!_appDelegate.Beacon)
    {
        [[SOMotionDetector sharedInstance] stopDetection];
        [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    }
}

-(NSMutableString *)formateuuid{
    
    
    
    
    NSMutableString *string = [NSMutableString stringWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"uuid"]];
    //string = [NSMutableString stringWithString:BEACON];

    if(string.length>30){
    if ([string rangeOfString:@"-"].location == NSNotFound) {
        [string insertString:@"-" atIndex:8];
        [string insertString:@"-" atIndex:13];
        [string insertString:@"-" atIndex:18];
        [string insertString:@"-" atIndex:23];
        // return string;
    } else {
        //  return string;
    }
    }
   
   // string= [NSMutableString stringWithString:BEACON];
    return string;
}

@end

