//
//  synchronizationManager.m
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 14/10/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import "SynchronizationManager.h"
#import "DatabaseManager.h"
#import "UDOperator.h"
@implementation SynchronizationManager{
    bool synchoAlreadyStarted;
}

+(SynchronizationManager *)sharedInstance{
    static dispatch_once_t onceToken;
    static SynchronizationManager *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        if(sharedInstance == nil){
            sharedInstance = [[self alloc]init];
        }
    });
    return sharedInstance;
}
-(void)isyncfalse{

    synchoAlreadyStarted=false;
}
- (void)startSynchroIfNeeded{
    
    
    NSLog(@"myauthinsync=%@ and %i and %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"auth"],synchoAlreadyStarted, [[NSUserDefaults standardUserDefaults]objectForKey:@"lastSynchro"]
);
    
    [NSTimer scheduledTimerWithTimeInterval:30
                                     target:self
                                   selector:@selector(isyncfalse)
                                   userInfo:nil
                                    repeats:NO];

    
    
    
    NSLog(@"issync=%i",synchoAlreadyStarted);
    
    if(!synchoAlreadyStarted && [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]){
        synchoAlreadyStarted = YES;
        int sec;
        //int seconds=39600;
        int seconds=1;
        
        if(_issyncnow)
            seconds=1;
        //TODO:dont forget to change value 5 & 500
#if DEBUG
        sec = 1;
#else
        sec = 1;
#endif
       
        
        
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            double oldTimestamp = ((NSNumber*)[[NSUserDefaults standardUserDefaults]objectForKey:@"lastSynchro"]).doubleValue;
            double now = [[NSDate date] timeIntervalSince1970];
            //SYNCHRO if last synchro >= 39600 sec (11hours)
            NSLog(@"oldtimestamp=%f",oldTimestamp);
          /*  if([[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:oldTimestamp]] >= seconds){*/
                _issyncnow=false;
                [[UDOperator singleton] postUnsendScore:[[DatabaseManager sharedInstance] getUnsendRides] withCompletionBlock:^(id response) {
                    if(response){
                        NSLog(@"responsejsnonscore =%@",response);
                        [[DatabaseManager sharedInstance] updateRideUnsend:response];
                        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithDouble:now] forKey:@"lastSynchro"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self fetchProfiledata:[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] valueForKey:@"phone_number"]];
                        }
                    synchoAlreadyStarted = NO;
                }];
          //  }
        });
    }
}




-(void)fetchProfiledata:(NSString *)phone_number{
    
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:phone_number forKey:@"phone_number"];

    [[UDOperator singleton]fetchProfile:payload withCompletionBlock:^(id response) {
        
        
        
        
        if(response && [response isKindOfClass:[NSDictionary class]]){
            //NSLog(@" login response %@",rez);
            //let user in app
            
            
            NSMutableDictionary *rez = [response mutableCopy];
            NSArray * x = [response allKeys];
            for (NSString *key in x)
            {
                //Remove all the "nul" value in order to save the account in the NSUserDefault
                if([rez objectForKey:key] == (id)[NSNull null]){
                    [rez setValue:nil forKey:key];
                }
            }
            //NSLog(@" login response %@",rez);
            //let user in app
            [[NSUserDefaults standardUserDefaults]setObject:rez forKey:@"account"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sync_completed" object:nil];
            
            
            
            
        }
        
        
        
    } ];
    
    
    
    
}

@end
