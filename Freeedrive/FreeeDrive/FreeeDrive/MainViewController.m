//
//  MainViewController.m
//  FreeeDriveStore
//
//  Created by KL on 3/9/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//
#import "MainViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+FreeeDrive.h"
#import "RateUsViewController.h"
#import "SignupViewController.h"
#import "CreditsViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Ride.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "Detector.h"
#import "SOMotionDetector.h"
#import "UIUtils.h"
#import "SOStepDetector.h"
#import "DatabaseManager.h"
#import "iBeaconManager.h"
#import "SlideNavigationController.h"
#import "NSMutableAttributedString+Color.h"
#import "SynchronizationManager.h"
#import "Ride_utilRec.h"
#import "MZTimerLabel.h"
#import "UICKeyChainStore.h"
@import FirebaseInstanceID;
@import FirebaseInstanceID;
@import CoreText;
#define kFrequency 2.0f
@interface MainViewController ()
{
    
    
    BOOL allowEndRidenoti;
    int stepCount;
    NSTimer *shortTimer;
    NSTimer *lostTimer;
    NSTimer *longTimer;
    BOOL isShaking;
    BOOL isswitch;
    float demospeed;
    BOOL isallow_checkspeed;
    BOOL isallow_shorttimer;
    NSString *type;
    NSMutableArray *array_rideutilRec;

    AppDelegate *_appDelegate;
    
    int syncIncr;
    NSString *allridetime;
    NSString * lastridetime;
    NSString *lastridearrival;
    NSString *allridearrival;
    NSString  *lastridetime_params;
    NSString *allridetime_params;
    MZTimerLabel *totalTime_speedLimitIncrease;
    
}

@property(nonatomic,weak)IBOutlet UILabel *lbl_lr_distractions;

@property(nonatomic,weak)IBOutlet UILabel *lbl_lr_distractions_title;


@property(nonatomic,weak)IBOutlet UILabel *lbl_Ar_distractions;

@property(nonatomic,weak)IBOutlet UILabel *lbl_Ar_distractions_title;


@property(nonatomic,strong) CBCentralManager *bluetoothManager;
@property (weak, nonatomic) IBOutlet UILabel *lbl_LastRideData;
@property (weak, nonatomic) IBOutlet UIImageView *img_behaviour;
@property (weak, nonatomic) IBOutlet UIImageView *img_thumbsup;
@property (weak, nonatomic) IBOutlet UILabel *lbl_AllRideData;
@property (weak, nonatomic) IBOutlet UILabel *lbl_totalScores;
@property (weak, nonatomic) IBOutlet UILabel *lbl_TotalScores_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_messageTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_message;
@property (strong) UIAlertView *avNotif;
@property (strong) Ride *currentRide;
@property (strong) Ride_utilRec *currentRide_utilRec;
@property (strong) UITapGestureRecognizer *hideInfoGest;
@property BOOL isDecoDuringRide;

@end

#pragma mark -
#pragma mark Init / Lifecycle

@implementation MainViewController
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [[SlideNavigationController sharedInstance]  toggleRightMenu];
    return YES;
}

-(void)toggleMenu{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lang_changed_menu" object:nil];

    
   
    [[SlideNavigationController sharedInstance]  toggleRightMenu];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    lastridearrival=@"";
    lastridetime_params=@"";
    lastridetime=@"";
    [self detectBluetooth];
    syncIncr=0;
  //  NSLog(@"mydict= %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"account"]);
   
   
    [self.gaugeLastRide setDelegate:self];
    self.gaugeLastRide.minValue = 0;
    self.gaugeLastRide.maxValue = 100;
    self.gaugeLastRide.limitValue = 100;
    [self.backButton setHidden:YES];
    isallow_checkspeed=false;
    [self.navigationController setNavigationBarHidden:YES];
    [[UIUtils singleton] configureLabel:_lbl_TotalScores_title withSyle:@"bold" size:19 color:[UIColor lightGrayColor] andText:LocalizedString(@"total_scores", nil)];
    [[UIUtils singleton] configureLabel:_lbl_totalScores withSyle:@"bold" size:50 color:[UIColor bleuColor] andText: [NSString stringWithFormat:@"%i",[self calculateScore]]];
    
    
    [[UIUtils singleton] configureLabel:_lbl_Ar_distractions_title withSyle:@"bold" size:19 color:[UIColor bleuColor] andText:LocalizedString(@"total_distractions", nil)];
    [[UIUtils singleton] configureLabel:_lbl_Ar_distractions withSyle:@"bold" size:50 color:[UIColor bleuColor] andText: @"0"];
    //[[UIUtils singleton] configureLabel:_lbl_messageTitle withSyle:@"bold" size:17 color:[UIColor bleuColor] andText:@"Good Job!"];
    //[[UIUtils singleton] configureLabel:_lbl_message withSyle:@"normal_center" size:20 color:[UIColor bleuColor] andText:@"you need some more experience"];
    [self.lbl_message sizeToFit];
    [self.lbl_totalScores sizeToFit];
    [self.navigationController setNavigationBarHidden:NO];
    self.isDecoDuringRide = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidAppear:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getToken:) name:kFIRInstanceIDTokenRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideIsFinished) name:@"rideFinished" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isBTPaired) name:@"btFoundFromAuto" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkspeed) name:@"speedchanged" object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sync_completed) name:@"sync_completed" object:nil];

    
    
  //  [self checkOnlineVersion];
    UITapGestureRecognizer *tapGuageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gaugaelastRideClicked:)];
    tapGuageGesture.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapGuageAllGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gaugaeAllRideClicked:)];
    tapGuageGesture.numberOfTapsRequired = 1;
    //  [self.gaugeAllRide addGestureRecognizer:tapGuageAllGesture];
    [[iBeaconManager sharedInstance] startLocation];
    [self.navigationController setNavigationBarHidden:YES];
    [self configureGaugeViews];
    
    
    [self.menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    


    [self.syncHiddenButton addTarget:self action:@selector(btn_sync_clicked) forControlEvents:UIControlEventTouchUpInside];


    
    /*******************************************
     * Stopwatch with controls and time format
     * Adjust starting Value
     ********************************************/
    totalTime_speedLimitIncrease = [[MZTimerLabel alloc] initWithLabel:totalTime_speedLimitIncrease andTimerType:MZTimerLabelTypeStopWatch];
    totalTime_speedLimitIncrease.timeFormat = @"HH:mm:ss";
    

   
    
  
   /* [NSTimer scheduledTimerWithTimeInterval:5                                     target:self
                                   selector:@selector(targetmethod)
                                   userInfo:nil
                                    repeats:NO];

    
    */
    
   
    



}

-(void)targetmethod{
    

    
    
    NSString *deviceId = @"";
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.FreeeDriveStore"];
    if(keychain && keychain[@"device_id3"])
    {
        deviceId = keychain[@"device_id3"];
        NSLog(@"found device_id: %@", deviceId);
    }
    else
    {
        CFUUIDRef uuid = CFUUIDCreate(nil);
        deviceId = CFBridgingRelease(CFUUIDCreateString(nil, uuid));
        keychain[@"device_id1"] = deviceId;
        NSLog(@"spawned device_id: %@", deviceId);
    }
    
    
    
    
    
}

-(void)btn_sync_clicked{


    syncIncr++;
    
    
    if(syncIncr==7){
    
        syncIncr=0;
    
        
        NSLog(@"json = %@",[[DatabaseManager sharedInstance] getallRides_localdb] );
       
        [[UDOperator singleton] postLocalScore:[[DatabaseManager sharedInstance] getallRides_localdb] withCompletionBlock:^(id response) {
            if(response){
                NSLog(@"responsejsnonlocalmainscore =%@",response);
                             
                
                
            }
       
        }];
   
        

        
    
    }

}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







- (void) setColors_LastRideData
{
    NSLog(@"lastridetimeparams =%@",lastridetime_params);
    NSString *str=[NSString stringWithFormat:@"%@: %@ | %@: %@",LocalizedString(@"latest_ride", nil),lastridetime,LocalizedString(@"arrival", nil) ,lastridearrival];
    NSString *lastridetitle=LocalizedString(@"latest_ride", nil);
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange boldedRange = NSMakeRange(0, lastridetitle.length);
    UIFont *fontText = [UIFont fontWithName:@"DINNextLTPro-MediumCond" size:_lbl_LastRideData.font.pointSize];
    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
    [attrString setAttributes:dictBoldText range:boldedRange];
    NSLog(@"my string  = %@",str);
    // string = [[NSMutableAttributedString alloc] initWithString:str];
    [attrString setColorForText:@"Latest Ride:" withColor:[UIColor bleuColor]];
    [attrString setColorForText:lastridetime withColor:[UIColor bleuColor]];
    if ([lastridetime rangeOfString:@"h"].location != NSNotFound) {
        NSLog(@"string does not contain bla");
         [attrString setColorForText:@"h" withColor:[UIColor bleuColor]];
    }
    if ([lastridetime rangeOfString:@"m"].location != NSNotFound) {
        NSLog(@"string does not contain bla");
        [attrString setColorForText:@"m" withColor:[UIColor bleuColor]];
    }
    [attrString setColorForText:@"|" withColor:[UIColor bleuColor]];
    [attrString setColorForText:@"arrival:" withColor:[UIColor bleuColor]];
    [attrString setColorForText:lastridearrival withColor:[UIColor bleuColor]];
    _lbl_LastRideData.attributedText = attrString;
  }


- (void) setColors_AllRideData
{

  

    
  
    NSLog(@"allridetime==%@",allridetime);
 
  
    NSString *allridetitle=LocalizedString(@"all_rides", nil);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@",LocalizedString(@"all_rides", nil),allridetime]];
    NSRange boldedRange = NSMakeRange(0, allridetitle.length);
    UIFont *fontText = [UIFont fontWithName:@"DINNextLTPro-MediumCond" size:_lbl_LastRideData.font.pointSize];
    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
    [string setAttributes:dictBoldText range:boldedRange];
    
    
      [string setColorForText:[NSString stringWithFormat:@"%@",allridetime] withColor:[UIColor bleuColor]];

    
    
    if ([allridetime rangeOfString:@"h"].location != NSNotFound) {
    [string setColorForText:@"h" withColor:[UIColor bleuColor]];
    }
    if ([allridetime rangeOfString:@"m"].location != NSNotFound) {
        NSLog(@"string does not contain bla");
        [string setColorForText:@"m" withColor:[UIColor bleuColor]];
    }
    _lbl_AllRideData.attributedText = string;
    }




-(void)checkspeed{
    //for test
    isShaking=false;
    if(!_appDelegate)
        _appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        // self.lastRideTitle.text=[NSString stringWithFormat:@"%.2f km/h ",[SOMotionDetector sharedInstance].currentSpeed * 3.6f];
   
    
       NSLog(@"temp.beacon= %i",_appDelegate.Beacon);
    if(_appDelegate.Beacon){
        float currentspeed_manual;
        
        

        
        currentspeed_manual = [SOMotionDetector sharedInstance].currentSpeed * 3.6f;
        NSLog(@"appdelegate.currentspeed = %f",currentspeed_manual);
        NSLog(@"myboolvalue=%i",[[NSUserDefaults standardUserDefaults] boolForKey:@"isswitch"]);
        if(self.currentRide){
            if(currentspeed_manual < speedlimit)
            {
                
              //  [self pauseStopWatch];

                
                if(_currentRide_utilRec){
                    [_currentRide_utilRec setEndTime];
                    [_currentRide_utilRec calculStartToEndDifference];
                    [array_rideutilRec addObject:_currentRide_utilRec];
                    _currentRide_utilRec=nil;
                }
                if([iBeaconManager sharedInstance].isDecoBeaconDuringRide){
                    _appDelegate.speed=1;
                    [[iBeaconManager sharedInstance] startBeaconLostTimer:YES];
                }
                else
                {
            if(!shortTimer){
                    NSLog(@"i m startin short timer");
                    [longTimer invalidate];
                    shortTimer=   [NSTimer scheduledTimerWithTimeInterval:pauseTimerVal
target:self
                                                                 selector:@selector(shortTimer_timeout)
                                                                 userInfo:nil
                                                                  repeats:NO];
                    //  [self showNotification:@"speed < 5 and beacon = 1 timer start"];
                }
                else{
                    NSLog(@"i am not starting = %i %@", shortTimer.valid , shortTimer);
                }
                //shor timer  start
                }
            }
            else{//if speed >  10
                [[iBeaconManager sharedInstance] startBeaconLostTimer:NO];
                if(currentspeed_manual>maxSpeedLimit)
                {
                if(!_currentRide_utilRec)
                {  self.currentRide_utilRec=[Ride_utilRec new];
                    [_currentRide_utilRec setStartTime];
                }
                  //  [self startStopWatch];
                }
                else{
                       NSLog(@"i am below 120");
                    if(_currentRide_utilRec){
                        [_currentRide_utilRec setEndTime];
                        [_currentRide_utilRec calculStartToEndDifference];
                        [array_rideutilRec addObject:_currentRide_utilRec];
                        _currentRide_utilRec=nil;
                    }
                  //  [self pauseStopWatch];
                }
                NSLog(@"reseting timer to nil");
                [shortTimer invalidate];
                shortTimer=nil;
                [longTimer invalidate];
                longTimer=nil;
                // [self showNotification:@"speed > 5 and beacon = 1"];
                if(_appDelegate.Beacon)
                {
                    _appDelegate.speed=2;
                }
            }//inavlidate timer else
        }//if ride continue
        else{// too start fresh ride
            shortTimer=nil;
            NSLog(@"mylocations=%@",_appDelegate.array_locations);
            NSLog(@"currentsppeedmanual= %f",currentspeed_manual);
            if (currentspeed_manual > speedlimit){
                if(_appDelegate.Beacon)
                {

                  
                    NSNumber *num;
                    float allok=true;
                    
                    
                    
                    if(_appDelegate.array_locations.count>1){
                    for(int i=0;i<_appDelegate.array_locations.count;i++){
                    
                   
                        num=[_appDelegate.array_locations objectAtIndex:i];
                        if (num.floatValue<= speedlimit) {
                            allok=false;
                            break;
                        }

                        if(i>3)
                            break;
                    }
                    if(allok){
                    _appDelegate.speed=2;
                    [self isBTPaired];
                    }
                    }
                }
            }
        }
    }//main beacon off
}

/*******************************************
 * Method for stopwatch
 ********************************************/
/*- (void)startStopWatch {
    if(![totalTime_speedLimitIncrease counting]){
     [totalTime_speedLimitIncrease start];
    }
  
    
}


-(void)pauseStopWatch{
    if([totalTime_speedLimitIncrease counting]){
        [totalTime_speedLimitIncrease pause];
        
    }

}
- (void)resetStopWatch {
    [totalTime_speedLimitIncrease reset];
}
*/
-(void)pausespeed
{
}


-(void)demospeed{
    

    
    demospeed=44;
    [NSTimer scheduledTimerWithTimeInterval:60
                                     target:self
                                   selector:@selector(demospeed_timeout)
                                   userInfo:nil
                                    repeats:NO];
    
    
    
    
    [_appDelegate playSpeech:@"demo starting" andVolume:0.1];
}

-(void)demospeed_timeout{
    
    demospeed=0;
    NSLog(@"I am getting decrease");
    
    
    [NSTimer scheduledTimerWithTimeInterval:60
                                     target:self
                                   selector:@selector(demospeed_timeout1)
                                   userInfo:nil
                                    repeats:NO];

    [_appDelegate playSpeech:@"demo decreasing " andVolume:0.7];
    
}

-(void)demospeed_timeout1{
    
    demospeed=50;
    
    
    NSLog(@"I am getting increae");
    
    
    [NSTimer scheduledTimerWithTimeInterval:60
                                     target:self
                                   selector:@selector(demospeed_timeout2)
                                   userInfo:nil
                                    repeats:NO];
    
   // [_appDelegate playSpeech:@"demo finished" andVolume:0.1];
    
}
-(void)demospeed_timeout2{

    demospeed=0;
}
-(void)shortTimer_timeout{
    
    _appDelegate.speed=1;
    if(self.currentRide){
        [longTimer invalidate];
        longTimer=nil;
        longTimer=   [NSTimer scheduledTimerWithTimeInterval:rideFinishTimerVal
                                                      target:self
                                                    selector:@selector(longTimer_timeout)
                                                    userInfo:nil
                                                     repeats:NO];
       // [_appDelegate playSpeech:@"Ride is getting paused" andVolume:1.0];
       // [self showNotification:@"short timer timeout"];
    }
    
    
    
}
-(void)longTimer_timeout{
    //finish ride
 //   [self showNotification:@"long timer timeout"];
    _appDelegate.speed=0;
    if(_appDelegate.Beacon)
    {
        [self btHasBeenDisconnected];
    }
    else
    {
        shortTimer=nil;
        
        // [_appDelegate playSpeech:@"Ride is already finsihed due to beacon disconnectivity" andVolume:1.0f];
        
        
    }
    
    
    
}

- (IBAction)switchToggled:(id)sender{
    
    if([sender isOn]){
        NSLog(@"Switch is ON");
        //isswitch=true;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isswitch"];
    } else{
        NSLog(@"Switch is OFF");
        
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isswitch"];
        
    }
    
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    
    
}









-(IBAction)btn_freeDriveLogo_clicked:(id)sender{
    
    // [self gaugaeAllRideClicked:self];
    //[self gaugaelastRideClicked:self];
}


- (void)checkOnlineVersion{
    if(!_appDelegate.BT){
        [[UDOperator singleton] checkOnlineVersion];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[Localization singleton] setLanguage: [[Localization singleton]languageString]];
    
    
    
    _appDelegate.isinteruption=false;
    [self configureGaugeViews];
}

-(void)viewDidAppear:(BOOL)animated
{
   
    
    
    
    [super viewDidAppear:animated];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([CLLocationManager locationServicesEnabled]){
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                                            message:@"Location disabled, to re_enable, please go to Settings and turn on Location Service for this app."
                                                           delegate:nil
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil];
            //       [alert show];
        }
    }
    [self getToken:nil];
    [self isBTPaired];
}
-(void)viewWillDisappear:(BOOL)animated{
}


-(void)configureGaugeViews{
        // Configure gauge view
    self.gaugeLastRide.minValue = 0;
    self.gaugeLastRide.maxValue = 100;
    self.gaugeLastRide.limitValue = 100;
   [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(updateGaugeTimer:) userInfo:nil repeats:NO];
}

/**
 * Get new firebase token when kFIRInstanceIDTokenRefreshNotification occurs
 */
-(void)getToken:(NSNotification*)notif{
   /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableDictionary *payload = [NSMutableDictionary new];
        // NSLog(@" firebase token %@", [[FIRInstanceID instanceID] token] );
        if([[FIRInstanceID instanceID] token] ){
            [payload setObject:[[FIRInstanceID instanceID] token] forKey:@"gcm_token"];
            
            [[UDOperator singleton]postAccount:payload withCompletionBlock:^(id response){
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                //NSLog(@" postAccount response %@", response);
                
            }];
        }
    });*/
    
    
   // NSLog(@"postaccount = %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"account"]);
    
}
- (void)isBTPaired{
    
    NSLog(@"appeleaget.beacon = %i",_appDelegate.Beacon);
    if(_appDelegate.Beacon){
        [self forceFoundBT];
        
    }
    else
    {
        [self btHasBeenDisconnected];
    }
    
}

-(void)forceFoundBT{
    
    [[NSUserDefaults standardUserDefaults] setObject:@"zohaib" forKey:@"first_name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(_appDelegate.speed>0){
        NSLog(@"ForceFoundBT");
        
        
        
        
        
        [_appDelegate launchBackGroundTask];
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isrideandlocked"] isEqualToString:@"1"]){
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"isrideandlocked"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // self.currentRide=_appDelegate.currentRide;
        }
        //NO RIDE && !DECO
        if(!self.currentRide){
            
            
            
         /*   AVAudioSession* audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback
                          withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                error:nil];
            // [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            [audioSession setActive:YES error:nil];
          */
           /* if([[NSUserDefaults standardUserDefaults] objectForKey:@"suspended"] && [[[NSUserDefaults standardUserDefaults]objectForKey:@"account"] objectForKey:@"first_name"]){*/
                UILocalNotification *notification = [UILocalNotification new];
            NSString *str_hi=[[Localization singleton] localizedStringForKey:@"hi" value:nil];
            NSString *str_welcomeMessage=[[Localization singleton] localizedStringForKey:@"welcome_back_Ready_for_a_safe_drive" value:nil];
            notification.alertBody = [NSString stringWithFormat:@"%@ %@, %@", str_hi,[[[NSUserDefaults standardUserDefaults]objectForKey:@"account"] objectForKey:@"first_name"],str_welcomeMessage];
            //   [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                //if we're connected to the BT we don't need to see the local notification about "ready for a safe drive"
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"suspended"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            //}
            //start a new ride
            //  [self resetStopWatch];
            
            
            allowEndRidenoti=true;
            array_rideutilRec =[[NSMutableArray alloc] init];
         
            self.currentRide = [Ride new];
            //[self.currentRide setTime:YES];
            [self.currentRide setLocation];
            // _appDelegate.currentRide=[Ride new];
            //    [_appDelegate.currentRide setLocation];
            // _appDelegate.currentRide=self.currentRide;
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"score"];
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"bd_count"];
            [[Detector singleton] startDetection];
        }else if(self.currentRide && self.isDecoDuringRide){
            //IF ride & deco during ride
            //it means it's the same ride
            self.isDecoDuringRide = NO;
        }
    }
    
}

-(void)syncScoreImmediate{

    
 //   [[DatabaseManager sharedInstance] updateUncorrectLocation];
    
    [SynchronizationManager sharedInstance].issyncnow=true;
    [SynchronizationManager sharedInstance].delegate=self;
    [[SynchronizationManager sharedInstance]startSynchroIfNeeded];
    
    


}
/**
 * Set arrival_time & arrival_location
 * stop movement detection & set @"suspended" in order to display the "ready for" when BT is connected
 */
#pragma mark - RIDE
/**
 * Start the dispatch in order to see if the user reconnect his device to the right BT
 */
- (void)btHasBeenDisconnected{
    //self.appDelegate.BT = 0;
    // self.appDelegate.Beacon=0;
    if(self.currentRide){
        [shortTimer invalidate];
        [longTimer invalidate];
        //longTimer=nil;
        self.isDecoDuringRide = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.isDecoDuringRide){
                
                [self endRide];
                
            }
        });
    }
    [shortTimer invalidate];
    shortTimer=nil;
    [longTimer invalidate];
    longTimer=nil;
}
/**
 * Set arrival_time & arrival_location
 * stop movement detection & set @"suspended" in order to display the "ready for" when BT is connected
 */
- (void)endRide{
    [_appDelegate.array_locations removeAllObjects];
    
    self.currentRide.time_elapsed_breakspeedlimit=0;
    int timeElapse = 0;
    for(Ride_utilRec *ride_util in array_rideutilRec)
    {
    timeElapse = timeElapse+ride_util.time_elapsed.intValue;
     // self.currentRide.time_elapsed_breakspeedlimit=[NSNumber numberWithInt:timeElapse];
    }
    
    
    
    
   NSLog(@"mybreakelapsedtime=%i",timeElapse);
    
    
    [array_rideutilRec removeAllObjects];
    
    [self.currentRide setTime_elapsed_breakspeedlimit:timeElapse];
    
    //get arrival location
    [self.currentRide setTime:NO];
    
    float timeElapsed_breakSpeedlimit= [totalTime_speedLimitIncrease getTimeCounted];
   // [self.currentRide setTime_elapsed_breakspeedlimit:[NSNumber numberWithFloat:timeElapsed_breakSpeedlimit]];
    [self.currentRide setLocation];
    [[Detector singleton] stopMovementDetection];
    self.isDecoDuringRide = NO;
    _appDelegate.speed=0;
    [[NSUserDefaults standardUserDefaults] setObject:@"suspended" forKey:@"suspended"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"END RIDE");
   if(_appDelegate.Beacon)
    {
        // [_appDelegate playSpeech:@"Ride is finished" andVolume:1];
    }
    else{
        if(allowEndRidenoti){
       // [_appDelegate playSpeech:@"Ride is finished due to beacon disconnectivity" andVolume:1];
            allowEndRidenoti=false;
        }
    }
}
/**
 * delete the current ride
 * update the gauge
 */
- (void)rideIsFinished{
    //  if(!_appDelegate.Beacon)
/*
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:nil];
    // [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
       [audioSession setActive:NO error:nil];
*/
     //   [[SOMotionDetector sharedInstance] stopDetection];
    [lostTimer invalidate];
    lostTimer = nil;
    lostTimer=   [NSTimer scheduledTimerWithTimeInterval:locServiceStopTimerVal
                                                  target:self
                                                selector:@selector(lostimer_timeout)
                                                userInfo:nil
                                                 repeats:NO];
    
    [_appDelegate.array_locations removeAllObjects];
    self.currentRide = nil;
    shortTimer=nil;
    _appDelegate.speed=0;
    isallow_checkspeed=true;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"score"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateGaugeTimer:) userInfo:nil repeats:NO];


    [self syncScoreImmediate];
    
    
    [_appDelegate startTimer_Reachability];

}
#pragma mark - LMGAUGEVIEW
- (UIColor *)gaugeView:(LMGaugeView *)gaugeView ringStokeColorForValue:(CGFloat)value{
    return [UIColor greenColor];
}
// Set value for gauge view
- (void)updateGaugeTimer:(NSTimer *)timer{
    [self setGaugeValue:nil];
    [self setGaugeValue:[[DatabaseManager sharedInstance]getLastRide]];
}



-(long)calculatetotalridetimes{
    long totaltimeofallrides=[[DatabaseManager sharedInstance] getAllRidesTime];
    
    totaltimeofallrides=(totaltimeofallrides*60)+ ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] valueForKey:@"total_time_elapsed"] intValue]*60);
    NSLog(@"totalrime= %ld",totaltimeofallrides);
    return totaltimeofallrides ? totaltimeofallrides : 0;
}
-(int)calculateScore{
      long totaltimeofallrides=[[DatabaseManager sharedInstance] getAllRidesTime];
    NSArray *array=(NSArray *)[[DatabaseManager sharedInstance] getAllRides];
    double temp=0;;
    
    for(int i=0;i<array.count;i++){
        Ride *ride=array[i];
        double ridetime=ride.time_elapsed.intValue;
        double temp2=ridetime/totaltimeofallrides;
        temp=  temp+  ride.score.intValue*temp2;
    
    
    
        NSLog(@"temp2=%f",temp2);
        NSLog(@"temp=%f",temp);
        NSLog(@"ride.score= %i",ride.score.intValue);
        
        NSLog(@"total time of all rises = %li",totaltimeofallrides);
    
    
    }
    
    
    
    
    
    
    
    NSLog(@"tempbefore= %f",temp);
    if(array.count<1){
        // temp=[[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] valueForKey:@"avg_score"] intValue];
        [[NSUserDefaults standardUserDefaults]setObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] valueForKey:@"avg_score"] forKey:@"avg_score_local"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        temp=[[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] valueForKey:@"avg_score"] intValue];
    }
    else{
        int    temp_serverscore=[[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] valueForKey:@"avg_score"] intValue];
        NSLog(@"temp_localScore=%i",temp_serverscore);
        if(temp_serverscore<1){
            temp_serverscore=0;
        }
        else{
            temp=temp+ temp_serverscore;
            temp=temp/2;
        }
        NSLog(@"tempafter= %f",temp);
    }
    
    
    
    NSLog(@"temp=%f",temp);
    if(temp>0)
        return  temp;
    else if(temp<1)
        return 0;
    else
        return 0;
    
    NSLog(@"myscore = %f",temp);
    return temp ? temp : 100;
    
    
    
    
    
}


-(void)setGaugeValue:(Ride*)ride{
    
   
    
    
    
    
    
    long seconds;
    NSString *str_lr_count;
    if ([ride bd_count].integerValue==0){
        
        str_lr_count=[NSString stringWithFormat:@"0"];
    }else
        str_lr_count=[NSString stringWithFormat:@"%@",[ride bd_count]];
    
    
 
    
    
    if(!ride){
        seconds = [self calculatetotalridetimes];//[[DatabaseManager sharedInstance]getAllRidesTimeInSeconds];
     _lbl_totalScores.text = [NSString stringWithFormat:@"%i",[self calculateScore]];//[[DatabaseManager sharedInstance]getAllRidePonderation];
        
        
        [[UIUtils singleton] configureLabel:_lbl_Ar_distractions_title withSyle:@"bold" size:19 color:[UIColor lightGrayColor] andText:LocalizedString(@"total_distractions", nil)];
          [[UIUtils singleton] configureLabel:_lbl_Ar_distractions withSyle:@"bold" size:50 color:[UIColor bleuColor] andText:  [NSString stringWithFormat:@"%i",[[DatabaseManager sharedInstance]getAllRidesBd_count]]];
        
        
        
         [[UIUtils singleton] configureLabel:_lbl_TotalScores_title withSyle:@"bold" size:19 color:[UIColor lightGrayColor] andText:LocalizedString(@"total_scores", nil)];

    }else{
        NSLog(@"lastrideelaped=%@",ride.time_elapsed);
        seconds = ride.time_elapsed.longValue;
        [[UIUtils singleton] configureLabel:_lbl_lr_distractions withSyle:@"bold" size:60 color:[UIColor bleuColor] andText:[NSString stringWithFormat:@"%li",(long)(ride.bd_count ? ride.bd_count.integerValue : 0)]];
        [[UIUtils singleton] configureLabel:_lbl_lr_distractions_title withSyle:@"bold" size:21 color:[UIColor lightGrayColor] andText:LocalizedString(@"distraction", nil)];
        NSString * arrivaltimestamp=[NSString stringWithFormat:@"%@",ride.arrival_time];
        NSDate *date_arival = [NSDate dateWithTimeIntervalSince1970:[arrivaltimestamp doubleValue]];
       // self.gaugeLastRide.distractions=ride.bd_count ? ride.bd_count.integerValue : 0;
        self.gaugeLastRide.value = ride.score ? ride.score.integerValue : 0;
        lastridearrival=[NSString stringWithFormat:@"%@",[self convertToLocalTime:ride.arrival_time] ?[self convertToLocalTime:ride.arrival_time]  : @""];//ride.arrival_time;
    
        //[self convertToLocalTime:ride.arrival_time]
        
        NSLog(@"lastridescore= %@",ride.score);
        
        
    }
    
    
  
    
    //TODO::: See if < 119 sec displayed 1 minute isn't an issue for the client
    if(seconds > 119){
        
        if(seconds >= 3600){
            //get the rest
            long secondsModulo = labs(seconds)%60;
            //get the rest
            long minutesModulo = ((labs(seconds) - secondsModulo)/60)%60;
            //get the minute sharped
            long minutes = ((labs(seconds) - secondsModulo)/60);
            //get the hours sharped
            long hours = (minutes - labs(minutes%60))/60;
            
            if(!ride){
               allridetime = seconds > 3600 ? [NSString stringWithFormat:LocalizedString(@"hours_minutes", nil),hours, minutesModulo] : [NSString stringWithFormat:LocalizedString(@"hours_minutes", nil),hours,0];
            
            
            }else{
            lastridetime = seconds > 3600 ? [NSString stringWithFormat:LocalizedString(@"hours_minutes", nil),hours, minutesModulo] : [NSString stringWithFormat:LocalizedString(@"hours_minutes", nil),hours,0];
                
                
                
            }
            
        }else{
            if(!ride){
               allridetime = [NSString stringWithFormat:LocalizedString(@"minutes", nil), (seconds- (labs(seconds)%60) )/60];
            }else{
            lastridetime  = [NSString stringWithFormat:LocalizedString(@"minutes", nil), (seconds- (labs(seconds)%60) )/60];
            }
            
        }
    }else{
        if(!ride){
            allridetime = [NSString stringWithFormat:LocalizedString(@"minute", nil),seconds < 60? 0:1];
        }else{
            
            
        
            
            lastridetime  = [NSString stringWithFormat:LocalizedString(@"minute", nil),seconds < 60? 0:1];
            
            
            
            
        }
    }
    
    
    
    
    NSLog(@"lastridetime=%@",lastridetime);
  
    
    if(ride)
    {
        
        [self setColors_LastRideData];
        
        
   
        
    [self bdcount_responder:ride.bd_count ? ride.bd_count.intValue : 0];
    }
    else
        [self setColors_AllRideData];

   

    
  /*  long seconds;
    NSString *str_lr_count;
    if ([ride bd_count].integerValue==0){
        
        str_lr_count=[NSString stringWithFormat:@"0"];
    }else
        str_lr_count=[NSString stringWithFormat:@"%@",[ride bd_count]];
    NSString *str_Ar_count=[NSString stringWithFormat:@"%i",[[DatabaseManager sharedInstance]getAllRidesBd_count]];
    
    
    //2 good
   // 2 greater watch out
   // 5 k baad scene yes
    
    if(!ride){
        seconds = [[DatabaseManager sharedInstance]getAllRidesTimeInSeconds];
       // self.gaugeAllRide.value = [self calculateScore];//[[DatabaseManager sharedInstance]getAllRidePonderation];
        
        
        
    }else{
        
     

         self.gaugeLastRide.value = [ride.bd_count intValue] ? [ride.bd_count intValue] : 0;
        seconds = ride.time_elapsed.longValue;
       // self.gaugeLastRide.value = ride.score ? ride.score.integerValue : 0;
        lastridearrival=[NSString stringWithFormat:@"%@",ride.arrival_time ? ride.arrival_time : @""];//ride.arrival_time;
        
        
    }
    
    //TODO::: See if < 119 sec displayed 1 minute isn't an issue for the client
    if(seconds > 119){
        
        if(seconds >= 3600){
            
            //get the rest
            long secondsModulo = labs(seconds)%60;
            //get the rest
            long minutesModulo = ((labs(seconds) - secondsModulo)/60)%60;
            //get the minute sharped
            long minutes = ((labs(seconds) - secondsModulo)/60);
            //get the hours sharped
            long hours = (minutes - labs(minutes%60))/60;
            
           if(!ride){
         allridetime_params=LocalizedString(@"hours_minutes", nil);
         allridetime = seconds > 3600 ? [NSString stringWithFormat:@"%ld %ld",hours, minutesModulo] : [NSString stringWithFormat:@"%ld %d",hours,0];
            }else{
                
                lastridetime_params=LocalizedString(@"hours_minutes", nil);
            lastridetime = seconds > 3600 ? [NSString stringWithFormat:@"%ld %ld",hours, minutesModulo] : [NSString stringWithFormat:@"%ld %d",hours,0];
            }
        }
        else{
            if(!ride){
                
                allridetime_params=LocalizedString(@"minutes", nil);

                allridetime = [NSString stringWithFormat:@"%ld", (seconds- (labs(seconds)%60) )/60];
            }else{
                
                
                lastridetime_params=LocalizedString(@"minutes", nil);
                lastridetime = [NSString stringWithFormat:@"%ld", (seconds- (labs(seconds)%60) )/60];
            }
        }
    }else{
        if(!ride){
            
         allridetime_params=@"minute";//LocalizedString(@"minute", nil);
          allridetime = [NSString stringWithFormat:LocalizedString(@"minute", nil),seconds < 60? 0:1];
        }else{
            
         lastridetime_params=@"minute";//LocalizedString(@"minute", nil);
          lastridetime = [NSString stringWithFormat:@"%i",seconds < 60? 0:1];
        }
    }
    
    
    NSLog(@"my lastride time= %@" , lastridetime);
    NSLog(@"all ride time = %@", allridetime);
    
    _lbl_totalScores.text=[NSString stringWithFormat:@"%i",[self calculateScore]];
    
    
    
    _lbl_AllRideData.text=[NSString stringWithFormat:@"%ld %@" , [self calculatetotalridetimes]];
    
    if(ride)
    {[self setColors_LastRideData];
    
    
    
    
        [self bdcount_responder:ride.bd_count ? ride.bd_count.intValue : 0];
    }
    */
}

- (void)detectBluetooth
{
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}



- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(self.bluetoothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off.";
         /*   [[SOMotionDetector sharedInstance] resetSpeed];
            _appDelegate.Beacon=0;
            _appDelegate.BT=0;
            _appDelegate.speed=0;
            [shortTimer invalidate];
            [longTimer invalidate];
            shortTimer=nil;
            //[self showNotification:@"bluetooth off"];
          
            [self isBTPaired];
            [lostTimer invalidate];
            lostTimer=nil;
            lostTimer=   [NSTimer scheduledTimerWithTimeInterval:locServiceStopTimerVal
                                                          target:self
                                                        selector:@selector(lostimer_timeout)
                                                        userInfo:nil
                                                         repeats:NO];*/
            
            [[iBeaconManager sharedInstance] setIsDecoBeaconDuringRide:YES];
            [self checkspeed];
            


            
            NSLog(@"I am off");
            break;
        case CBCentralManagerStatePoweredOn: stateString = @"Bluetooth is currently powered on and available to use.";
           /* _appDelegate.Beacon=0;
            _appDelegate.BT=0;
            _appDelegate.speed=0;
            //[self isBTPaired];
            [shortTimer invalidate];
            [longTimer invalidate];
            shortTimer=nil;*/
            [[iBeaconManager sharedInstance] resumeLocation];
            NSLog(@"I am on");
            break;
        default: stateString = @"State unknown, update imminent."; break;
    }
    
}
-(void)showNotification:(NSString *)str{
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertTitle=@"Status";
    notification.alertBody =str;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
}


-(void)bdcount_responder:(int)bdcount{
    
    
    
    NSLog(@"bdcountlast=%i",bdcount);
    
    
    if(bdcount<2){
        
        [self.img_behaviour setImage:[UIImage imageNamed:@"blue_outline.png"]];
        
        
        
        //[self.img_faceExpression setImage:[UIImage imageNamed:@"sadface"]];
        [[UIUtils singleton]configureLabel:self.lbl_messageTitle withSyle:@"bold" size:22 color:[UIColor bleuColor] andText:LocalizedString(@"well_done", nil)];
        [[UIUtils singleton]configureLabel:self.lbl_message withSyle:@"normal_center" size:19.0f color:[UIColor darkGrayColor] andText:LocalizedString(@"keep_on_safe_driving", nil)];
        
       /* [[UIUtils singleton]configureLabel:self.lbl_distraction withSyle:@"normal" size:19.0f color:[UIColor bleuColor] andText:LocalizedString(@"Distraction", nil)];
        [[UIUtils singleton]configureLabel:self.lbl_drivingTime withSyle:@"normal" size:19.0f color:[UIColor bleuColor] andText:LocalizedString(@"drive_time", nil)];
        */
        [self.img_thumbsup setHidden:NO];
        [self.lbl_message sizeToFit];
    }
    else if (bdcount>1&&bdcount<=5){
        
        [self.img_behaviour setImage:[UIImage imageNamed:@"orange_outline.png"]];
        [[UIUtils singleton]configureLabel:self.lbl_messageTitle withSyle:@"bold" size:19 color:[UIColor orangeColor] andText:LocalizedString(@"watch_out", nil)];
        [[UIUtils singleton]configureLabel:self.lbl_message withSyle:@"normal_center" size:19.0f color:[UIColor darkGrayColor] andText:LocalizedString(@"have_you_been_distracted", nil)];
        
      /*  [[UIUtils singleton]configureLabel:self.lbl_distraction withSyle:@"normal" size:19.0f color:[UIColor bleuColor] andText:LocalizedString(@"Distraction", nil)];
        [[UIUtils singleton]configureLabel:self.lbl_drivingTime withSyle:@"normal" size:19.0f color:[UIColor bleuColor] andText:LocalizedString(@"drive_time", nil)];*/
        [self.lbl_message sizeToFit];
         [self.img_thumbsup setHidden:YES];
        
        
    }
    else if(bdcount > 5)
    {
        [self.img_behaviour setImage:[UIImage imageNamed:@"red_outline.png"]];
        [[UIUtils singleton]configureLabel:self.lbl_messageTitle withSyle:@"bold" size:17 color:[UIColor redColor] andText:LocalizedString(@"risky_behavior", nil)];
        [[UIUtils singleton]configureLabel:self.lbl_message withSyle:@"normal_center" size:19.0f color:[UIColor darkGrayColor] andText:LocalizedString(@"cant_your_smartphone_wait", nil)];
       /* [[UIUtils singleton]configureLabel:self.lbl_distraction withSyle:@"normal" size:19.0f color:[UIColor bleuColor] andText:LocalizedString(@"Distraction", nil)];
        [[UIUtils singleton]configureLabel:self.lbl_drivingTime withSyle:@"normal" size:19.0f color:[UIColor bleuColor] andText:LocalizedString(@"drive_time", nil)];
        */
         [self.lbl_message sizeToFit];
         [self.img_thumbsup setHidden:YES];
        
        
    }
}


    -(NSString *)convertToLocalTime:(NSString *)globaltimestamp{

        if (globaltimestamp == (id)[NSNull null] || globaltimestamp.length == 0 ) return @"";

        
          NSLog(@"myglobaltime=%@",globaltimestamp);
        
        double timestamp= [globaltimestamp doubleValue];
        
        
        NSDate* globaltime = [NSDate dateWithTimeIntervalSince1970:timestamp];
      
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"dd/MM/yyyy HH:mm"];
        //Create the date assuming the given string is in GMT
        df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        //NSDate *date = [df dateFromString:gmtDateString];
        //Create a date string in the local timezone
        df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
        NSString *localDateString = [df stringFromDate:globaltime];
        NSLog(@"mydate = %@", localDateString);
        //NSDate *currentDate=[df dateFromString:localDateString];
      /*  BOOL isDayLightSavingTime = [[NSTimeZone localTimeZone] isDaylightSavingTimeForDate:currentDate];
        if (isDayLightSavingTime) {
            NSTimeInterval timeInterval = [[NSTimeZone localTimeZone]  daylightSavingTimeOffsetForDate:currentDate];
            currentDate = [currentDate dateByAddingTimeInterval:timeInterval];
          localDateString = [df stringFromDate:currentDate];
        }*/
        return localDateString;
    /*
         -(NSDate *)convertToLocalTime:(NSDate *)globaltime{
         NSLog(@"mydateglobal=%@",globaltime);
         NSDateFormatter *df = [NSDateFormatter new];
         [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
         //Create the date assuming the given string is in GMT
         df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
         //NSDate *date = [df dateFromString:gmtDateString];
         //Create a date string in the local timezone
         df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
         NSString *localDateString = [df stringFromDate:globaltime];
         NSLog(@"mydatestringLocal = %@", localDateString);
         
         
         
         
         
         
         NSDateFormatter *df1 = [NSDateFormatter new];
         [df1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
         //Create the date assuming the given string is in GMT
         df1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
         //NSDate *date = [df dateFromString:gmtDateString];
         //Create a date string in the local timezone
         
         
         NSDate *currentDate=[df1 dateFromString:localDateString];
         
         
         
         
         
         NSTimeZone* CurrentTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
         NSTimeZone* SystemTimeZone = [NSTimeZone systemTimeZone];
         
         NSInteger currentGMTOffset = [CurrentTimeZone secondsFromGMTForDate:currentDate];
         NSInteger SystemGMTOffset = [SystemTimeZone secondsFromGMTForDate:currentDate];
         NSTimeInterval interval = SystemGMTOffset - currentGMTOffset;
         
         NSDate* TodayDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:currentDate];
         NSLog(@"Current time zone Today Date : %@", TodayDate);
         
         
         
         
         BOOL isDayLightSavingTime = [[NSTimeZone localTimeZone] isDaylightSavingTimeForDate:TodayDate];
         if (isDayLightSavingTime) {
         NSTimeInterval timeInterval = [[NSTimeZone localTimeZone]  daylightSavingTimeOffsetForDate:TodayDate];
         TodayDate = [TodayDate dateByAddingTimeInterval:timeInterval];
         }
         
         NSLog(@"mydatecurrent=%@",TodayDate);
         return TodayDate;
         
         }
         */
    }

-(NSMutableAttributedString *)boldfirst:(float)size boldString:(NSString *)lightStr lightString:(NSString *)boldStr color:(UIColor *)color{
    
    
    color=[UIColor colorWithRed:((float) 50 / 255.0f)
                          green:((float) 0 / 255.0f)
                           blue:((float) 75 / 255.0f)
                          alpha:1.0f];
    NSMutableAttributedString *aAttrString;
    UIFont *HelveticaNeueCondensedBold = [UIFont fontWithName:@"DINNextLTPro-MediumCond" size:size];
    NSDictionary *boldDict = [NSDictionary dictionaryWithObject:HelveticaNeueCondensedBold forKey:NSFontAttributeName];
    UIFont *HelveticaNeueLight = [UIFont fontWithName:@"DINNextLTPro-LightCondensed" size:10];
    NSDictionary *lightdict = [NSDictionary dictionaryWithObject:HelveticaNeueLight forKey:NSFontAttributeName];
    aAttrString = [[NSMutableAttributedString alloc] initWithString:boldStr attributes: boldDict];
  
    NSMutableAttributedString *vAttrString = [[NSMutableAttributedString alloc]initWithString: lightStr attributes:lightdict];
    if(lightStr.length>1){
        [vAttrString addAttribute:NSForegroundColorAttributeName value:color range:(NSMakeRange(0, lightStr.length-1))];
        [aAttrString appendAttributedString:vAttrString];
    }
    else {
    }
    return  aAttrString;
}
-(void)lostimer_timeout{
    NSLog(@"I am out");
    [lostTimer invalidate];
    if(!_appDelegate.Beacon)
        [[SOMotionDetector sharedInstance] stopDetection];
    else{
        
        [_appDelegate.array_locations removeAllObjects];
        [[SOMotionDetector sharedInstance] startDetection];
    }
}

- (void)sync_completed{

//refresh data,
    
    [_appDelegate stopTimer_Reachability];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateGaugeTimer:) userInfo:nil repeats:NO];
    
    
    
    NSLog(@"scorecomplete Notify");


}

@end
