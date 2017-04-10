//
//  Detector.m
//

#import "Detector.h"
//#import "MDBluetoothManager.h"
#import <dlfcn.h>
@import AVFoundation;
#import <notify.h>
#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/sysctl.h>

@implementation Detector

static Detector *gInstance = NULL;
NSMutableArray *movePitchArray;
NSMutableArray *moveYawArray;
NSMutableArray *moveRollArray;
AppDelegate *appDelegate;


//SMS
extern CFStringRef const kCTMessageReceivedNotification;
CFNotificationCenterRef CTTelephonyCenterGetDefault();
void CTTelephonyCenterAddObserver(CFNotificationCenterRef ct, void* observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior sb);
void CTTelephonyCenterRemoveObserver(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object);
//static int (*IMDMessageRecordGetMessagesSequenceNumber)();

#pragma mark -
#pragma mark Init / Lifecycle

+(Detector *)singleton
{
    @synchronized(self)
    {
        if(gInstance == NULL)
        {
            gInstance = [[Detector alloc] init];
            
        }
    }
    
    return gInstance;
}

-(void)readAwesomeMessage:(NSNotification *)notif
{
    NSLog(@"SMS");
}

-(id)init
{
    self = [super init];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager setDeviceMotionUpdateInterval:0.5f];
    movePitchArray = [NSMutableArray new];
    moveYawArray = [NSMutableArray new];
    moveRollArray = [NSMutableArray new];
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark -
#pragma mark Detection

-(void)startDetection{
    
    [self detectMovement];
}

-(void)run{
    //no account? bail
    /*if(![[NSUserDefaults standardUserDefaults]objectForKey:@"account"])
     return;
     
     self.processing = YES;
     
     //inner loop
     if(self.inBackground)
     {
     NSLog(@"detection loop start");
     
     if(![self screenBrightness] || [self isScreenLocked])
     {
     self.goodUsage = YES;
     }
     else
     {
     
     if(self.goodUsage)
     {
     //networking?
     NSArray *dc = [self getDataCounters];
     long sent = [[dc objectAtIndex:0]longLongValue];
     long received = [[dc objectAtIndex:1]longLongValue];
     NSLog(@"sent: %lu received: %lu", sent, received);
     NSLog(@"old sent: %lu received: %lu", self.sentBytes, self.receivedBytes);
     if(self.sentBytes == -1 && self.receivedBytes == -1)
     {
     self.sentBytes = sent;
     self.receivedBytes = received;
     }
     else
     {
     long recv = labs(received - self.receivedBytes);
     NSLog(@"recv: %lu", recv);
     if(labs(sent - self.sentBytes) > kTresholdBytes ||
     labs(received - self.receivedBytes) > kTresholdBytes)
     {
     self.goodUsage = NO;
     [self alertUser];
     NSLog(@"networking");
     }
     else
     {
     //energy consumption?
     [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
     UIDevice *myDevice = [UIDevice currentDevice];
     [myDevice setBatteryMonitoringEnabled:YES];
     double batLeft = (float)[myDevice batteryLevel];            //2% granularity
     if(self.batteryLevel == -1.0f)
     {
     self.batteryLevel = batLeft;
     }
     else
     {
     if(fabs(batLeft - self.batteryLevel) > kTresholdBattery)
     {
     self.goodUsage = NO;
     [self alertUser];
     NSLog(@"gaming");
     }
     self.batteryLevel = batLeft;
     }
     }
     self.sentBytes = sent;
     self.receivedBytes = received;
     }
     }
     //}
     }
     NSLog(@"detection loop end");
     }
     else
     {
     
     self.goodUsage = YES;
     }
     
     [self logBehavior];
     [self resetIvars];
     self.processing = NO;
     */
}

/*-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
 {
 [self.locationManager stopUpdatingLocation];
 self.locationManager = nil;
 
 self.location = [locations lastObject];
 
 NSLog(@"at location: %.6f %.6f", self.location.coordinate.latitude, self.location.coordinate.longitude);
 }*/

-(void)resetIvars
{
    //self.rotationX = -MAXFLOAT;
    //self.rotationY = -MAXFLOAT;
    //self.rotationZ = -MAXFLOAT;
    self.moved = NO;
    //self.goodUsage = NO;
    //self.keyboardUsed = NO;
    //self.sentBytes = -1;
    //self.receivedBytes = -1;
    //self.batteryLevel = -1.0f;
}

-(void)detectMovement
{
   
    NSLog(@"i am moving");
 
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"account"])
        return;
    
    
    if ([self.motionManager isGyroAvailable]) {
        if ([self.motionManager isGyroActive] == NO) {
            [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
                if (appDelegate.BT && [self isDeviceMoved:motion]) {
                    appDelegate.deviceMove = 1;
                    [appDelegate repeatSpeech];
                } else if (appDelegate.deviceMove) {
                    appDelegate.deviceMove = 0;
                    //BT stop so we stop the update of the gyroscope
                } else if (!appDelegate.BT) {
                    //[self.motionManager stopGyroUpdates];
                    appDelegate.deviceMove = 0;
                }
                
            }];
        }
    }
}

-(void)stopMovementDetection{

    if([self.motionManager isGyroActive] == YES){
        [self.motionManager stopGyroUpdates];
        appDelegate.deviceMove = 0;
    }

}

- (BOOL)isDeviceMoved:(CMDeviceMotion*)motion {
    //NSLog(@"Roll: %.2f Pitch: %.2f Yaw: %.2f", motion.attitude.roll, motion.attitude.pitch, motion.attitude.yaw);
    //NSLog(@"Roll: %.2f° Pitch: %.2f° Yaw: %.2f°", motion.attitude.roll * (180.0/M_PI), motion.attitude.pitch * (180.0/M_PI), motion.attitude.yaw* (180.0/M_PI));
    
    [movePitchArray addObject: [NSNumber numberWithFloat:(motion.attitude.pitch * (180.0/M_PI))]];
    [moveYawArray addObject: [NSNumber numberWithFloat:(motion.attitude.yaw * (180.0/M_PI))]];
    [moveRollArray addObject: [NSNumber numberWithFloat:(motion.attitude.roll * (180.0/M_PI))]];
    
    if(![self processMovementData:movePitchArray andWhichData:1]){
        if(![self processMovementData:moveYawArray andWhichData:2]){
            return [self processMovementData:moveRollArray andWhichData:3];
            
        }else{
            return YES;
        }
    }else{
        return YES;
    }
    
}

- (BOOL)processMovementData:(NSMutableArray*)data andWhichData:(int)choice {
    BOOL moved = 0;
    if([data count] != 2){
        return NO;
    }
    
    float x = ((NSNumber*) data[0]).floatValue;
    float  y = ((NSNumber*) data[1]).floatValue;
    //pitch
    if(choice == 1){
        if( (x < 0.0f && y > 0.5f) || (y < 0.0f && x > 0.5f) ){
            moved = 1;
        }else{
            moved =  fabs(x-y) > 6.0f  ? YES : NO;
            
        }
        //yaw
    }else if(choice == 2){
        moved =   fabs(x-y) > 5.0f  ? YES : NO;
    }else{
        if( (x < 0.0f && y > 0.0f) || (y < 0.0f && x > 0.0f) ){
            moved = 1;
        }else{
            moved =  fabs(x-y) > 9.5f  ? YES : NO;
        }
    }
    
    [self cleanMoveArray];
    return moved ;
    
}

-(void)cleanMoveArray{
    
    if([movePitchArray count] == 2){
        [movePitchArray removeAllObjects];
    }
    
    if([moveYawArray count] == 2){
        [movePitchArray removeAllObjects];
    }
    
    if([moveRollArray count] == 2){
        [moveRollArray removeAllObjects];
    }
    
}

- (NSArray *)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;
    
    NSString *name = nil;
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiSent],[NSNumber numberWithInt:WiFiReceived], nil];
}

//-(BOOL)isScreenLocked
//{
//    bool locked;
//    bool passcode;
//    mach_port_t sbPort;
//    void *sbserv = dlopen(SBSERVPATH, RTLD_LAZY);
//    void* (*SBGetScreenLockStatus)(mach_port_t* port, bool *lockStatus, bool *passcodeEnabled) = dlsym(sbserv, "SBGetScreenLockStatus");
//    SBGetScreenLockStatus(&sbPort, &locked, &passcode);
//    return locked;
//}

-(int)screenBrightness
{
    @try
    {
        float brightness = [UIScreen mainScreen].brightness;
        if (brightness < 0.0 || brightness > 1.0)
        {
            return -1;
        }
        return (brightness * 100);
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
    return 0;
}

#pragma mark -
#pragma mark API

-(void)logBehavior
{
 
}



-(void)alertUser
{
   
}

@end
