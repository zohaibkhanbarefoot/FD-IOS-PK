



//
//  AppDelegate.m
//  FreeeDriveEnterprise
//
//  Created by KL on 4/15/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//  Adapted by Eddy Van Hoeserlande www.appsolute.be
@import MediaPlayer;

#import "AppDelegate.h"
#import "StartViewController.h"

@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;
#import <notify.h>
#import "Detector.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SOMotionDetector.h"
#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/sysctl.h>
#import "SOLocationManager.h"
#import "Ride.h"
#import "iBeaconManager.h"
#import "KeepAliveManager.h"
#import "DatabaseManager.h"
#import "RightMenuViewController.h"
#import "SynchronizationManager.h"
#import "Reachability.h"
#import "UICKeychainStore.h"
#include <sys/sysctl.h>

#import "TwilioClient.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


typedef struct kinfo_proc kinfo_proc;
@interface AppDelegate ()
{
    bool backgroundedToLockScreen;
    NSTimer *timer_reinitialize;
    Reachability *internetReachable;
    NSMutableArray *array_batteryStatus;
    TCDevice* _phone;
    TCConnection* _connection;
    BOOL isplay;
   
    
    
}
@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property (strong, nonatomic) iBeaconManager* iBeaconManager;
@property (strong, nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) AVPlayer *player;
@property (atomic,assign) __block UIBackgroundTaskIdentifier background_task;
@property UIAlertView *avNotif;
@end

@implementation AppDelegate {
    
}

bool lockComplete;

//currently no hack is able to detect if the screen if unlock when the app is launched because the hack "observe" the event
//when the app launched, no event about being lock/unlock happen.

static void displayStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    // the "com.apple.springboard.lockcomplete" notification will always come after the "com.apple.springboard.lockstate" notification
    
    
    
   
    
    NSString *lockState = (__bridge NSString*)name;
    NSLog(@"lockState : %@", (__bridge NSString*)name);
    AppDelegate *appDelegate = (__bridge AppDelegate*)observer;
    
    
    appDelegate.isMonitorBattery=0;
    [appDelegate.timer_monitorBattery invalidate];
    appDelegate.timer_monitorBattery=nil;
    if([lockState isEqualToString:@"com.apple.springboard.lockcomplete"])
    {
        
        
        NSLog(@"** LOCK");
        appDelegate.unlocked = 0;
        appDelegate.deviceMove = 0;
        lockComplete = 1;
        if (appDelegate.Beacon){
            //  [appDelegate launchPlaySpeech:[[Localization singleton] localizedStringForKey:@"PHONE_LOCKED" value:nil]    ];
            //  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
              [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isrideandlocked"];
              [[NSUserDefaults standardUserDefaults] setValue:@"1"  forKey:@"lockedstatus"];
              [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else if ([lockState isEqualToString:@"com.apple.springboard.lockstate"]) {
        if (!lockComplete){
            
            NSLog(@"** UNLOCK");
            if (appDelegate.Beacon){
                //   [appDelegate launchPlaySpeech:[[Localization singleton] localizedStringForKey:@"PHONE_UNLOCKED" value:nil]  ];
                //  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                //if ride is not finished and phone unlock
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isrideandlocked"];
                
                [[NSUserDefaults standardUserDefaults] setValue:@"0"  forKey:@"lockedstatus"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                
            }
            appDelegate.deviceMove = 0;
            appDelegate.unlocked = 1;
            lockComplete = 1;
            
            
            
            
        } else {
            lockComplete = 0;
        }
    }
    
    
    
    
}



#pragma mark - state

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    displayStatusChanged,
                                    CFSTR("com.apple.springboard.lockcomplete"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    displayStatusChanged,
                                    CFSTR("com.apple.springboard.lockstate"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    [[NSUserDefaults standardUserDefaults] setObject:@"suspended" forKey:@"suspended"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBuildVersion"];
    NSString *appBuild = [infoDict objectForKey:@"CFBuildNumber"];
    
    
   // [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    
   if( [[UDOperator singleton]isConnected])
    [self setupvoip];
    

    _isinteruption=false;
    isplay=false;
    NSString *fileName;
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"] isEqualToString:@"en"])
        fileName=@"ennotify_ios";
    else  if([[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"] isEqualToString:@"fr"])
        fileName=@"frnoti_ios";
    else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"] isEqualToString:@"nl"])
        fileName=@"nlnotify_ios";
    else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"] isEqualToString:@"es"])
        fileName=@"esnotify_ios";
    else
        fileName=@"ennotify_ios";
    //    NSArray *queue = @[[AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp3"]]];
    /*
    self.player = [[AVPlayer alloc] initWithPlayerItem:[AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp3"]]];
    [self.player addObserver:self
                  forKeyPath:@"rate"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];*/
    _array_locations=[[NSMutableArray alloc] initWithCapacity:5];
    _array_badCount_timestamps=[[NSMutableArray alloc] init];
    NSString *str=[NSString stringWithFormat:@"%i",self.unlocked];
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertTitle=@"Lockedstatus";
    notification.alertBody =str;
     if([[NSUserDefaults standardUserDefaults] valueForKey:@"lockedstatus"]==nil){
        
        [[NSUserDefaults standardUserDefaults ] setValue:@"0" forKey:@"lockedstatus"];
        self.unlocked = 1;
        [[NSUserDefaults standardUserDefaults] synchronize];
    
    }

  /*  NSLog(@"\nVersion : %@ build %@\n\
          Name : %@\n\
          Platform : %@ %@ %@",
          appVersion,
          appBuild,
          [UIDevice currentDevice].name,
          [self platform],
          [UIDevice currentDevice].systemName,
          [UIDevice currentDevice].systemVersion);
   
   
   */
    //use Keychain to persist the device ID
    NSString *deviceId = @"";
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.FreeeDriveStore"];
    if(keychain && keychain[@"device_id"])
    {
        deviceId = keychain[@"device_id"];
        NSLog(@"found device_id: %@", deviceId);
    }
    else
    {
        CFUUIDRef uuid = CFUUIDCreate(nil);
        deviceId = CFBridgingRelease(CFUUIDCreateString(nil, uuid));
        keychain[@"device_id"] = deviceId;
        NSLog(@"spawned device_id: %@", deviceId);
    }

    
    
    
    //stateResult = 0;
    @try {
        [FIRApp configure];
    }@catch (NSException *exception) {
        NSLog(@"FIRApp configure error");
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"isrideandlocked"] ;
    [[NSUserDefaults standardUserDefaults] synchronize];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioHardwareRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    //Phone lock no possible if app in foreground(except lock button)
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    //Op1P8VlT
    //alain@barefoot-studio.be
    //ASK PERMISSION for notif
    /*
     
     barefoot2017
     
     [7:49]
     my account haha
     
     [7:49]
     wait
     [7:50]
     JKeG4HD4
     [7:50]
     info@barefoot-studio.be  ==> z8lAcLa8eIaF
     [7:50]
     alain@barefoot-studio.be  ==> Op1P8VlT
     [7:50]
     alain.pecourt@barefoot-studio.be  ==> JKeG4HD4
     */
    //barefoot2017
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
              [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else{
        UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    //ASK PERMISSION for geoloc (beacon)
    CLLocationManager *locationManager;
    if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager requestWhenInUseAuthorization];
    locationManager = nil;
    //Insert first date for synchro >= 12h
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"lastSynchro"]){
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"lastSynchro"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
   // [[SOLocationManager sharedInstance] startSignificant];
    //Configure audio
    self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    self.speechSynthesizer.delegate = self;
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:audiosession_Category
                  withOptions:audiosession_CategoryOptions
                        error:nil];
  // [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [audioSession setActive:NO error:nil];
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];

    
  
    

    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    
    

    
    //start with device language
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language rangeOfString:@"en"].location != NSNotFound)
        language = @"en";
    if([language rangeOfString:@"fr"].location != NSNotFound)
        language = @"fr";
    if([language rangeOfString:@"nl"].location != NSNotFound)
        language = @"nl";

    if([language rangeOfString:@"es"].location != NSNotFound)
        language = @"es";

    
    if(![language isEqualToString:@"en"] && ![language isEqualToString:@"fr"] && ![language isEqualToString:@"nl"] && ![language isEqualToString:@"es"])
        language = @"en";
    [[Localization singleton]setLanguage:language];
    
    //start with Start if no account yetr
 
    [[DatabaseManager sharedInstance] createDataBase];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"account"]){

            [SynchronizationManager sharedInstance].issyncnow=false;
            [[SynchronizationManager sharedInstance]startSynchroIfNeeded];
        
        
        [[iBeaconManager sharedInstance] startLocation];
        [self gotoMenu];
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StartViewController *startViewController = [storyboard instantiateViewControllerWithIdentifier:@"StartViewController"];
       

      [[SlideNavigationController sharedInstance] pushViewController:startViewController animated:YES];
    }
    
    
   

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMediaServicesReset)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:nil];
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    /*	LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard
     instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];*/
    RightMenuViewController *rightMenu = (RightMenuViewController*)[mainStoryboard
                                                                    instantiateViewControllerWithIdentifier: @"RightMenuViewController"];
    [SlideNavigationController sharedInstance].rightMenu = rightMenu;
    //[SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    
    // Creating a custom bar button for right menu
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];
   
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        // For iOS 10 data message (sent via FCM)
     //   [FIRMessaging messaging].remoteMessageDelegate = self;
#endif
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    // Override point for customization after application launch.
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    //When the app is launch we need to concider the application as unlock
    //The previous observer doesn't work when the app is launched.
   // [self.timer_monitorBattery invalidate];
   // self.timer_monitorBattery=nil;
    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    _isMonitorBattery=false;
    NSLog(@"becomeactive");
    self.unlocked = 1;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Application Did ResignActive");
}

-(void)applicationWillTerminate:(UIApplication *)application{
    self.unlocked = 0;
    self.BT = 0;
    self.Beacon=0;
    self.deviceMove = 0;
    [[NSUserDefaults standardUserDefaults] setObject:@"suspended" forKey:@"suspended"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[iBeaconManager sharedInstance] resumeLocation];
    NSLog(@"suspended");
}




-(void)gotoMenu{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *main = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:main];
      //  [navigationController setNavigationBarHidden:YES];
     //   [self.window setRootViewController:navigationController];
    // [self.window setRootViewController:nc];
    
    
    [[SlideNavigationController sharedInstance] pushViewController:main animated:YES];
}

-(NSString *)platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString* platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    //https://www.theiphonewiki.com/wiki/Models
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7 (WiFi)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7 (Cellular)";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9 (WiFi)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"AppleTV5,3"])   return @"Apple TV 4";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}


#pragma mark - push notification iOS < 10
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {



}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    application.applicationIconBadgeNumber = 0;
    if([notification.alertTitle isEqualToString:[[Localization singleton] localizedStringForKey:@"BADBEHAVIOR" value:nil]] && !_avNotif){
        _avNotif= [[UIAlertView alloc] initWithTitle:[[Localization singleton] localizedStringForKey:@"BADBEHAVIOR" value:nil]                                message:[[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil]
                                            delegate:nil
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil];
        [_avNotif show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_avNotif dismissWithClickedButtonIndex:nil animated:YES];
            _avNotif = nil;
        });
    }
}


#pragma mark push notification iOS 10
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    if([notification.request.content.title isEqualToString:[[Localization singleton] localizedStringForKey:@"BADBEHAVIOR" value:nil]] && !_avNotif){
        _avNotif= [[UIAlertView alloc] initWithTitle:[[Localization singleton] localizedStringForKey:@"BADBEHAVIOR" value:nil]
                                             message:[[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil]
                                            delegate:nil
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil];
        [_avNotif show];
        
        
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_avNotif dismissWithClickedButtonIndex:nil animated:YES];
            _avNotif = nil;
        });
    }
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}
//sashay
//shakeel express.

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    completionHandler();
}


#pragma mark - handle audio event
-(void)handleMediaServicesReset{
    NSLog(@"handleMediaServiceReset");
    [[AVAudioSession sharedInstance] setActive:NO error: nil];
    [[AVAudioSession sharedInstance] setCategory:audiosession_Category
                                     withOptions:audiosession_CategoryOptions
                                           error:nil];
  //  [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}
-(void)audioHardwareRouteChanged:(NSNotification*)notification{
 /*  AVAudioSession *session = [ AVAudioSession sharedInstance ];*/
    NSString* seccReason = @"";
    NSInteger  reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    //  AVAudioSessionRouteDescription* prevRoute = [[notification userInfo] objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            seccReason = @"The route changed because no suitable route is now available for the specified category.";
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            seccReason = @"The route changed when the device woke up from sleep.";
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            seccReason = @"The output route was overridden by the app.";
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            seccReason = @"The category of the session object changed.";
        {
            self.speechSynthesizer =nil;
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
            
            
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:{
            seccReason = @"The previous audio output path is no longer available.";
            
            [[AVAudioSession sharedInstance] setActive:NO error: nil];
            self.speechSynthesizer =nil;
            
        }
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        { seccReason = @"A preferred new audio output path is now available.";
            
            
            
            
            
            
            
        }   break;
        case AVAudioSessionRouteChangeReasonUnknown:
        default:
            seccReason = @"The reason for the change is unknown.";
            break;
    }

    
    
   self.speechSynthesizer=nil;
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[KeepAliveManager sharedInstance] stopKeepAlive];
    [timer_reinitialize invalidate];
    timer_reinitialize=nil;
    timer_reinitialize=   [NSTimer scheduledTimerWithTimeInterval:2
                                                           target:self
                                                         selector:@selector(reinitialize_audiosession)
                                                         userInfo:nil
                                                          repeats:NO];
    NSLog(@"reason = %@",seccReason);
  /*  AVAudioSessionPortDescription *input = [[session.currentRoute.inputs count]?session.currentRoute.inputs:nil objectAtIndex:0];
    if (input.portType == AVAudioSessionPortHeadsetMic)
    {
    
    }*/
}

- (void)handleAudioSessionInterruption:(NSNotification*)notification {
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
        /*  _isinteruption=true;
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
            self.speechSynthesizer=nil;
            [[KeepAliveManager sharedInstance] stopKeepAlive];*/
             [self.player removeObserver:self forKeyPath:@"rate"];
            self.player=nil;
            self.speechSynthesizer=nil;
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
            [[KeepAliveManager sharedInstance] stopKeepAlive];
            [timer_reinitialize invalidate];
            timer_reinitialize=nil;
            timer_reinitialize=   [NSTimer scheduledTimerWithTimeInterval:5
                                                                   target:self
                                                                 selector:@selector(reinitialize_audiosession)
                                                                 userInfo:nil
                                                                  repeats:NO];

            
            NSLog(@"AVAudioSessionInterruptionTypeBegan");
            
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            NSLog(@"AVAudioSessionInterruptionTypeEnded");
                     self.speechSynthesizer=nil;
             [self.player removeObserver:self forKeyPath:@"rate"];
            self.player=nil;
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
            [[KeepAliveManager sharedInstance] stopKeepAlive];
            [timer_reinitialize invalidate];
            timer_reinitialize=nil;
                timer_reinitialize=   [NSTimer scheduledTimerWithTimeInterval:5
                                                                   target:self
                                                                 selector:@selector(reinitialize_audiosession)
                                                                 userInfo:nil
                                                                  repeats:NO];
            
            
        } break;
            
        default:
            NSLog(@"default :  interupt %lu",(unsigned long)interruptionType.unsignedIntegerValue);
            _isinteruption=false;
            break;
    }
}


-(void)reinitialize_audiosession{
    
    self.speechSynthesizer = nil;
    dispatch_time_t restartTime = dispatch_time(DISPATCH_TIME_NOW,
                                                1 * NSEC_PER_SEC);
    dispatch_after(restartTime, dispatch_get_global_queue(0, 0), ^{
        // [[KeepAliveManager sharedInstance] stopKeepAlive];
        // [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
        
        
        self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        //Configure audio
        self.speechSynthesizer.delegate = self;
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:audiosession_Category
                      withOptions:audiosession_CategoryOptions
                            error:nil];
      //   [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone
    //error:nil];
        [audioSession setActive:YES error:nil];
        [[KeepAliveManager sharedInstance] keepAlive:YES];
        _isinteruption=false;
        NSError *error;
        bool success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (!success)
            
        {  NSLog(@"AVAudioSession error activating: %@",error.debugDescription);
            [[KeepAliveManager sharedInstance] keepAlive:NO];
        }
    });
    
    
    
    NSLog(@"reinitialize_audiosession");
    
    
}
#pragma mark - speech

/**
 *  Use by the detector class
 */
- (void)repeatSpeech{
    if( (self.BT + self.deviceMove + self.unlocked+self.speed) >= TRIGGERSNEEDEDFORVOICE) {
        [self launchPlaySpeech:[[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil]];
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        //make a extra vibration , dispatch is use because the OS has a latency time between 2 vibration and we can't by pass this.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        });
    }
}
//5559 dell
- (void)launchPlaySpeech:(NSString *)text{
      @try {
        if ([self.speechSynthesizer isSpeaking]) {
            //DISPATCH USED Because if we are already speaking we must wait 1 sec for the score part.
            //Theorical logic, every 1 sec > movement ? >> bad score
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if( (self.BT + self.deviceMove + self.unlocked+self.speed) >= TRIGGERSNEEDEDFORVOICE || ![text isEqualToString:[[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil]] ){
                    //[self checkSilentMode:text];
                    [self playSpeech:text andVolume:1.0f];
                    UILocalNotification *notification = [UILocalNotification new];
                    notification.alertTitle = [[Localization singleton] localizedStringForKey:@"BADBEHAVIOR" value:nil];
                    notification.alertBody = [[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil];
                  //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                }
            });
        }else{
            //[self checkSilentMode:text];
            [self playSpeech:text andVolume:1.0f];
        }
    } @catch (NSException *exception) {
        NSLog (@"exception %@",exception.reason);
    }
}

-(void)playSpeech:(NSString*)text andVolume:(float)volume{

    
    //If sound = SPEECH_PHONEDOWN but the condition are not "ok", we must not play any SPEECH_DOWN
    if([text isEqualToString:[[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil]] && !((self.BT + self.deviceMove + self.unlocked+self.speed) >= TRIGGERSNEEDEDFORVOICE)){
        return;
    }
    if([text isEqualToString:[[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil]]){
        NSNumber *score = [[NSUserDefaults standardUserDefaults] objectForKey:@"score"];
        //        [self resolutionSize];
        
        if( [self resolutionSize] < 600){ //code to lok for iphone 5s and older
            score = [NSNumber numberWithDouble:(score.doubleValue + 1.80)];
        }else{
            score = [NSNumber numberWithDouble:(score.doubleValue + 1.35)];
        }
        [[NSUserDefaults standardUserDefaults] setObject:score forKey:@"score"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:score forKey:@"score"];
        NSNumber *bd_count = [[NSUserDefaults standardUserDefaults] objectForKey:@"bd_count"];
        bd_count= [NSNumber numberWithInteger:(bd_count.integerValue + 1)];
        [[NSUserDefaults standardUserDefaults] setObject:bd_count forKey:@"bd_count"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertTitle = [[Localization singleton] localizedStringForKey:@"BADBEHAVIOR" value:nil];
        notification.alertBody = [[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        //insert timestamp of badcounts.
        [_array_badCount_timestamps addObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]];
    }
    [self dialcall:self];
    //Force system sound to 1 > break the silent mode of the user \o/
    MPMusicPlayerController* musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if(musicPlayer.volume < 1){
       musicPlayer.volume = notificationVolume;
    }
    _isinteruption=false;
   if(!_isinteruption){
 /*  self.speechSynthesizer=nil;
   self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
   self.speechSynthesizer.delegate = self;
   //[[AVAudioSession sharedInstance] setActive:NO error:nil];
   //[[KeepAliveManager sharedInstance] stopKeepAlive];
   [[AVAudioSession sharedInstance] setActive:YES error:nil];*/
  /*  AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.volume = volume;
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"]];
    [self.speechSynthesizer speakUtterance:utterance];*/
    }
    
    
    

    NSString *fileName;
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"] isEqualToString:@"en"])
        fileName=@"ennotify_ios";
    else  if([[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"] isEqualToString:@"fr"])
        fileName=@"frnoti_ios";
    else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"] isEqualToString:@"nl"])
        fileName=@"nlnotify_ios";
    else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"] isEqualToString:@"es"])
        fileName=@"esnotify_ios";
    else
        fileName=@"ennotify_ios";
    //    NSArray *queue = @[[AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp3"]]];
    if(!self.player)
    {
    self.player = [[AVPlayer alloc] initWithPlayerItem:[AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp3"]]];
    [self.player addObserver:self
                  forKeyPath:@"rate"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];

    [self.player setMuted:NO];
   // self.player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    //[self.player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];
    //if(!isplay)
    [self.player play];
    }
    
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        if (rate == 0.0) {
            // Playback stopped
            NSLog(@"playerstopped");
            isplay=false;
             [self.player removeObserver:self forKeyPath:@"rate"];
            self.player=nil;
            
        } else if (rate == 1.0) {
            NSLog(@"playerplaying");
            isplay=true;
            // Normal playback
        } else if (rate == -1.0) {
            // Reverse playback
            NSLog(@"playerplayback");
            isplay=false;
             [self.player removeObserver:self forKeyPath:@"rate"];
            self.player=nil;
        }
    }
}

/**
 *  launchBackGroundTask is called when the user enter the beacon zone
 */
-(void)launchBackGroundTask{
    
    if( _background_task == UIBackgroundTaskInvalid || !_background_task){
        NSLog(@"start of background");
        _background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            if (_background_task != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:_background_task];
                _background_task = UIBackgroundTaskInvalid;
            }
        }];
            @try {
            // run background loop in a separate process
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[KeepAliveManager sharedInstance] keepAlive:NO];
                while(self.BT){
                    NSTimeInterval remaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
                    // background audio resets remaining time
                    [NSThread sleepForTimeInterval:5]; //wait for x sec*/
                    if(remaining <= 170){
                        [[KeepAliveManager sharedInstance] keepAlive:NO];
                        //those vibration help the eddy's hack to restart correctly to keep the app alive.
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                }
                
                if(_background_task != UIBackgroundTaskInvalid && !self.BT){
                    [[UIApplication sharedApplication] endBackgroundTask: _background_task];
                    _background_task = UIBackgroundTaskInvalid;
                    NSLog(@"end of background loop");
                }
            });
            
        } @catch (NSException *exception) {
            NSLog(@" Exception background task %@", [exception debugDescription]);
        }
    }
}

/**
 *  killBackGroundTask is called when the user left the beacon area
 */
-(void)killBackGroundTask{
    // [[Detector singleton] stopMovementDetection];
    if( _background_task != UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask:_background_task];
        _background_task = UIBackgroundTaskInvalid;
    }
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    //NSLog(@"didFinishSpeechUtterance");
    if([utterance.speechString isEqualToString:[[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil]] && (self.BT + self.deviceMove + self.unlocked+self.speed) != TRIGGERSNEEDEDFORVOICE){
        [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    //NSLog(@"didFinishSpeechUtterance");
    if([utterance.speechString isEqualToString:[[Localization singleton] localizedStringForKey:@"SPEECH_PHONEDOWN" value:nil]] && (self.BT + self.deviceMove + self.unlocked+self.speed) != TRIGGERSNEEDEDFORVOICE)
    {
        [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}
-(void)logout{

    
    [[iBeaconManager sharedInstance] stopLocation];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"account"];
    
    
//    NSLog(@"myaccount after logout = %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"account"]);
    

    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error"
                                                message:@"your phone number is already register with another device"
                                               delegate:self
                                      cancelButtonTitle:LocalizedString(@"ok", nil)
                                      otherButtonTitles:nil, nil];

    
    
    
    av.tag=-444454545;
    
    [av show];
    
    
    UIStoryboard *MainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UINavigationController *nav=[MainStoryBoard instantiateViewControllerWithIdentifier:@"nav"];

   // [[UIApplication sharedApplication].keyWindow setRootViewController:nav];
    
  
  
      //[[SlideNavigationController sharedInstance] popToViewController:startViewController animated:YES];
    [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];

 //   [[SlideNavigationController sharedInstance] pushViewController:startViewController animated:YES];

    
    

}
- (CGFloat)resolutionSize{
    CGFloat screenHeight = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        screenHeight = MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    } else {
        screenHeight = [[UIScreen mainScreen] bounds].size.height;
    }
    
    return screenHeight;
}

- (void) checkNetworkStatus:(NSNotification *)notice {
    // called after network status changes
    NetworkStatus internetStatus = [self.internetReachability currentReachabilityStatus];
    
    switch (internetStatus) {
        case NotReachable: {
            break;
        }
        case ReachableViaWiFi: {
            //WIFI
           [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
            [[SynchronizationManager sharedInstance]startSynchroIfNeeded];
            [self setupvoip];
            
          break;
        }
        case ReachableViaWWAN: {
            //3G / 4G
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
            [[SynchronizationManager sharedInstance]startSynchroIfNeeded];
            [self setupvoip];
            break;
        }
    }
}



+(BOOL) runningInBackground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    return state == UIApplicationStateBackground;
}

+(BOOL) runningInForeground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    return state == UIApplicationStateActive;
}

//setting push notification
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    // Connect to FCM since connection may have failed when attempted before having a token.
  //  [self connectToFcm];
    // TODO: If necessary send token to application server.
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
[[FIRInstanceID instanceID] setAPNSToken:deviceToken
                                        type:FIRInstanceIDAPNSTokenTypeSandbox];
    
    
}
-(void)monitorBattery{
    [_timer_monitorBattery invalidate];
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    double batLeft = (float)[myDevice batteryLevel] * 100;
    NSLog(@"left = %.f",batLeft);
    NSString * levelLabel = [NSString stringWithFormat:@"%.f%%", batLeft];
    NSLog(@"level =  %@",levelLabel);
    [array_batteryStatus addObject:levelLabel];
    NSString *str;
    if(array_batteryStatus.count>1){
        float val1=[[array_batteryStatus objectAtIndex:0] floatValue];
        float val2=[[array_batteryStatus objectAtIndex:1] floatValue];
        if(val1 == val2){
            self.unlocked=0;
        }
        else if(val2>val1){
            self.unlocked=0;
        }
        else
            self.unlocked=1;
        str=[NSString stringWithFormat:@"val1=%f and val2= %f",val1,val2];
    }
    _isMonitorBattery=0;
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertTitle=@"BatteryStatus";
    notification.alertBody =str;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    if(_Beacon){
    //postnotification to enable  locations
       //  [[SOMotionDetector sharedInstance] startDetection];
    }
}


//voip
-(void)setupvoip{

    NSURL *url = [NSURL URLWithString:@"http://xyperdemos.com/clientphp/token.php"];
    NSError *error = nil;
    NSString *token = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (token == nil) {
        NSLog(@"Error retrieving token: %@", [error localizedDescription]);
    } else {
        _phone = [[TCDevice alloc] initWithCapabilityToken:token delegate:self];
         [_phone setIncomingSoundEnabled:NO];
         [_phone setOutgoingSoundEnabled:NO];
        
    }
}


- (void)dialcall:(id)sender
{
    [_connection disconnect];
    NSDictionary *params = @{@"To": @""};
    _connection = [_phone connect:params delegate:nil];
}

- (void)hangup:(id)sender
{
    [_connection disconnect];
}

- (void)device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection
{
    NSLog(@"Incoming connection from: %@", [connection parameters][@"From"]);
    if (device.state == TCDeviceStateBusy) {
        [connection reject];
    } else {
        [connection accept];
        _connection = connection;
    }
}

- (void)deviceDidStartListeningForIncomingConnections:(TCDevice*)device
{
    NSLog(@"Device: %@ deviceDidStartListeningForIncomingConnections", device);
}

- (void)device:(TCDevice *)device didStopListeningForIncomingConnections:(NSError *)error
{
    NSLog(@"Device: %@ didStopListeningForIncomingConnections: %@", device, error);
}


-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
 
    
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    switch (status) {
        case NotReachable: {
            NSLog(@"no internet connection");
            
            
            
            
            break;
        }
        case ReachableViaWiFi: {
            NSLog(@"wifi");
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
            [[SynchronizationManager sharedInstance]startSynchroIfNeeded];
            [self setupvoip];

            
            
            
            
            
            break;
        }
        case ReachableViaWWAN: {
            NSLog(@"cellurar");
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
            [[SynchronizationManager sharedInstance]startSynchroIfNeeded];
            [self setupvoip];

            break;
        }
    }
    completionHandler(YES);
}
-(void)startTimer_Reachability{
    
    _timer_reachability=   [NSTimer scheduledTimerWithTimeInterval:time_reachAbilityCheckInterval
                                                            target:self
                                                          selector:@selector(checkNetworkStatus:)
                                                          userInfo:nil
                                                           repeats:YES];
    
    
}
-(void)stopTimer_Reachability{

    
    [_timer_reachability invalidate];
    _timer_reachability=nil;
    
}
@end



