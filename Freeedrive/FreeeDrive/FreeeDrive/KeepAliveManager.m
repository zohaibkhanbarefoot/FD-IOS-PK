//
//  KeepAliveManager.m
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 14/10/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import "KeepAliveManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@interface KeepAliveManager()
@property (strong, nonatomic) AVQueuePlayer *player;
@property (atomic,assign) __block UIBackgroundTaskIdentifier background_task;
@end
@implementation KeepAliveManager {
    int timesExtended;
}

+(KeepAliveManager *)sharedInstance{
    static dispatch_once_t onceToken;
    static KeepAliveManager *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        if(sharedInstance == nil){
            sharedInstance = [[self alloc]init];
        }
        
    });
    return sharedInstance;
}

/**
 * Launch a task who play a sound to keep the app alive
 * and launch the background task
 *@params backgroundTaskNeeded bool who indicates if we need to launch the background task.
 */
-(void)keepAlive:(BOOL)backgroundTaskNeeded{
    if(self.player){
        [self stopKeepAlive];
    }
    
    if(backgroundTaskNeeded){
        [self launchBackGroundTask];
    }
    
    NSLog(@"keep alive launched");
    timesExtended = 0;
    NSArray *queue = @[[AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"10sec" withExtension:@"mp3"]]];
    self.player = [[AVQueuePlayer alloc] initWithItems:queue];
    [self.player setMuted:YES];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    [self.player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];
    [self.player play];
}

/**
 * Stop the audio and stop the background task
 */
-(void)stopKeepAlive{
    if(self.player){
        @try {
            [self.player removeObserver:self forKeyPath:@"currentItem" context:nil];
        } @catch (NSException *exception) {
            
        } @finally {
            [self.player pause];
//            [self.player removeAllItems]; //Crashes the app!!
            self.player = nil;
            
            if( _background_task && _background_task != UIBackgroundTaskInvalid){
                [[UIApplication sharedApplication] endBackgroundTask:_background_task];
                _background_task = UIBackgroundTaskInvalid;
            }
            NSLog(@"keep alive stopped");
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentItem"]){
        if (timesExtended > KEEPBACKGROUNDTIMESALIFE) {
            [self stopKeepAlive];
            return;
        }
//        NSLog(@"keep alive extended : %d", ++timesExtended);
        [self.player insertItem:[AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"10sec" withExtension:@"mp3"]] afterItem:nil];
    }
}

/**
 * Launch a background task to keep the app alive
 */
-(void)launchBackGroundTask{
    
    if( _background_task == UIBackgroundTaskInvalid || !_background_task){
        
        _background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:_background_task];
            _background_task = UIBackgroundTaskInvalid;
        }];
    }
    
}

@end
