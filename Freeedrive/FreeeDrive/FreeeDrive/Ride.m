//
//  Ride.m
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 11/07/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import "Ride.h"
#import "SOMotionDetector.h"
#import "DatabaseManager.h"
@implementation Ride

- (Ride*)init{
    self = [super init];
    if (self) {
        self.send = [NSNumber numberWithInteger:0];
        self.driver_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"phone_number"];
        self.company_id =   @"1";//[[[NSUserDefaults standardUserDefaults]objectForKey:@"account"]objectForKey:@"company_id"];
        self.departure_time =[NSDate date] ;
    }
    return self;
}
/**
 *  Calcule the time difference in min between two date
 *  @return the time difference in min
 */
- (NSNumber*) calculStartToEndDifference{
    int timeElapsed = [self.arrival_time timeIntervalSinceDate:self.departure_time];
    
    //IF time  < 60 sec (1min) , shouldn't happen
    //Set the time to 60sec in order to have at least one minute
    if(timeElapsed <= 60){
        return @1;
    }
    return [NSNumber numberWithInt:(timeElapsed/60)];
}
/**
 *  Calcule the time difference in sec between two date
 *  @return the time difference in sec
 */
- (NSNumber*)calculStartToEndDifferenceInSec{
    
    int timeElapsed = [self.arrival_time timeIntervalSinceDate:self.departure_time];
    return timeElapsed > 60 ? [NSNumber numberWithInt:timeElapsed] : @60;
    
}

/**
 *  Calcul the percentage of a score following score/time traject in minute (*60)
 *  @return the percentage
 */
- (NSNumber*)calculScoreInPercent{
    //if score >= time
    // well... very bad driver , this case shouldn't happen but who knows ?
    NSNumber *timeDif = [self calculStartToEndDifferenceInSec];
    if(self.score.intValue >= timeDif.intValue){
        return @0;
    }
    int timeElapsed = timeDif.doubleValue;
    
    if(self.score.intValue != 0){
        double score = (1-(self.score.doubleValue/timeElapsed))*100;
        return [NSNumber numberWithInteger:(int)score];
    }else{
        return @100;
    }
}

/**
 *  Calcul score with a weight (time in sec)
 *  @return score * weight
 */
- (NSNumber*)calculScorePond{
    //NSLog(@"Date start %i \nDate end %i ",[self calculScoreInPercent].intValue,[self calculStartToEndDifferenceInSec].intValue );
    return [NSNumber numberWithInteger:([self calculScoreInPercent].intValue * [self calculStartToEndDifferenceInSec].intValue) ];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"Time elapsed  %lu - Score : %lu - Date start %@ - Date end %@ ", [self calculStartToEndDifferenceInSec].longValue, self.score.longValue, self.departure_time, self.arrival_time];
}

/**
 *  Set the location of the ride following
 *  If we may, the locality is saved, otherwise the coordinate are saved
 */
- (void)setLocation{
    
    //This var is used to prevent the several called of the Geocoder
    //because the location changed block is called ~ 3 times.
  


    if(!self.departure_location){
    self.departure_cllocation=[[SOLocationManager sharedInstance] lastLocation];
    self.departure_location = [NSString stringWithFormat:@"%f,%f",_departure_cllocation.coordinate.latitude,_departure_cllocation.coordinate.longitude];
    NSLog(@"departure location = %@",self.departure_location);
    
    
    }
    else{
        
        if(self.departure_location && !self.arrival_location){
          
            
             self.arrival_cllocation=[[SOLocationManager sharedInstance] lastLocation];
            
                self.arrival_location = [NSString stringWithFormat:@"%f,%f",_arrival_cllocation.coordinate.latitude,_arrival_cllocation.coordinate.longitude];
            
            
            
                    NSLog(@"arrival location = %@",self.arrival_location);
            
            
            
            //We got the both date so the ride is finished
            if(self.departure_time && self.arrival_time){
                self.bd_count =[[NSUserDefaults standardUserDefaults] objectForKey:@"bd_count"];
                
                
                AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                
                
                
                NSDate *newDate = [[self arrival_time] dateByAddingTimeInterval:-15];

                
                double arrivaltimestamp=[newDate timeIntervalSince1970];

                for (int i=0;i<delegate.array_badCount_timestamps.count;i++){
                    
                    
                 //   NSLog(@"check1=%i",arrivaltimestamp);
                   // NSLog(@"check2=%@",)
                    
                    
                    
                    if([[delegate.array_badCount_timestamps objectAtIndex:i] doubleValue]>arrivaltimestamp){
                        
                        
                        
                        int value = [self.bd_count intValue];
                        self.bd_count = [NSNumber numberWithInt:value - 1];
                        
                        
                        NSLog(@"I am greater please help");
                        
                    }
                }
                
                
                NSLog(@"departruetime= %@",self.departure_time);
                NSLog(@"arrival time  = %@",self.arrival_time);
                 NSLog(@"arrival timestamp  = %f",arrivaltimestamp);
                NSLog(@"arrival time stamp array = %@",delegate.array_badCount_timestamps);
                
                if(self.bd_count.integerValue>19){
                    self.score= [NSNumber numberWithInt:0];
                }
                else{
                    
                self.score = [NSNumber numberWithInt:100-(5*self.bd_count.intValue)];
                }
                
                
                if(delegate.Beacon){ // ride end due to speed
                    self.ride_end_reason=[NSNumber numberWithInteger:1];
                    
                
                }
                else{ // ride end due to beacon disconnectivity
                 self.ride_end_reason=[NSNumber numberWithInteger:2];
                
                }
                
                
                
                NSLog(@"scorebeforeinsert=%i",self.time_elapsedSpeedLimit.intValue);
                if([[DatabaseManager sharedInstance]insertRide:self]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"rideFinished" object:nil];
                
                
                    [_array_badCount_timestamps removeAllObjects];
                }
            }
            
        }



    }
}

   /*
    __block BOOL alreadyCalled = NO;
    [[SOMotionDetector sharedInstance] startDetection];

    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
    
        if(!alreadyCalled) {
            alreadyCalled = TRUE;
            //[[SOMotionDetector sharedInstance] stopDetection];
            CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
            [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                //IF the user don't have internet/4g we can't get his locality
                if(!self.departure_location){
                    if(placemark && [placemark locality ]){
                        self.departure_location = [placemark locality];
                    }else{
                        self.departure_location = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
                    }
                }else{
                    
                    if(self.departure_location && !self.arrival_location){
                        if(placemark && [placemark locality]){
                            self.arrival_location = [placemark locality];
                        }else{
                            self.arrival_location = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
                        }
                        //We got the both date so the ride is finished
                        if(self.departure_time && self.arrival_time){
                            self.bd_count =[[NSUserDefaults standardUserDefaults] objectForKey:@"bd_count"];
                            
                            
                            if(self.bd_count.integerValue>19){
                                self.score=0;
                            }
                            else{
                                self.score = [NSNumber numberWithInt:100-(5*self.bd_count.intValue)];
                            }
                            NSLog(@"scorebeforeinsert=%i",self.score.intValue);
                            if([[DatabaseManager sharedInstance]insertRide:self]){
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"rideFinished" object:nil];
                                }
                        }
                        
                    }
                }
                
            }];
        }
    };
    
}

/**
 *  Set the time of the ride following the state of "BT"
 */


-(void)setTime_elapsed_breakspeedlimit:(int)time_elapsed{
    self.time_elapsedSpeedLimit=[NSNumber numberWithInt:time_elapsed];
  

}
- (void)setTime:(BOOL)BT{
    
    //IF BT > departure
    if(BT){
        if(!self.departure_time){
            self.departure_time = [NSDate date];
        }
        //IF !BT > arrival
    }else{
        self.arrival_time = [NSDate date];
    }
}

/**
 *  Check if one of the name contains ","
 *  if contains "," it means there's at least one coordinate > set 0
 */
- (NSNumber*)isLocationOk{
    return [NSNumber numberWithBool:([self.departure_location rangeOfString:@","].location == NSNotFound && [self.departure_location rangeOfString:@","].location == NSNotFound)];
}


- (void)updateLocationWithCallback:(void (^)(BOOL, Ride*))completion{
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    
    CLLocation *locationD;
    NSArray *departure;
    //__block NSArray *arrival;
    
    if([self.departure_location rangeOfString:@","].location != NSNotFound){
        departure = [self.departure_location componentsSeparatedByString:@","];
        locationD =  [[CLLocation alloc]initWithLatitude:((NSString*)departure[0]).doubleValue longitude:((NSString*)departure[1]).doubleValue];
        
        [geoCoder reverseGeocodeLocation:locationD completionHandler:^(NSArray *placemarks, NSError *error) {
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if([self.departure_location rangeOfString:@","].location != NSNotFound){
                if(placemark && [placemark locality]){
                    self.departure_location = [placemark locality];
                }else{
                    completion(NO,nil);
                    return;
                }
                
            }
            
            if([self.arrival_location rangeOfString:@","].location != NSNotFound){
                [self updateArrivalWithCallback:(void (^)(BOOL, Ride*))completion];
            }else{
                completion(YES,self);
                
            }
        }];
        
    }else{
        
        [self updateArrivalWithCallback:(void (^)(BOOL, Ride*))completion];
    }
    
}

- (void)updateArrivalWithCallback:(void (^)(BOOL, Ride*))completion{
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    __block NSArray *arrival;
    
    if([self.arrival_location rangeOfString:@","].location != NSNotFound){
        arrival = [self.arrival_location componentsSeparatedByString:@","];
        CLLocation *locationA =  [[CLLocation alloc]initWithLatitude:((NSString*)arrival[0]).doubleValue longitude:((NSString*)arrival[1]).doubleValue];
        
        [geoCoder reverseGeocodeLocation:locationA completionHandler:^(NSArray *placemarks, NSError *error) {
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            if([self.arrival_location rangeOfString:@","].location != NSNotFound){
                if(placemark && [placemark locality]){
                    self.arrival_location = [placemark locality];
                    completion(YES,self);
                }else{
                    completion(NO,nil);
                }
            }else{
                completion(YES,self);
            }
        }];
    }
    
    completion(YES,self);
}



@end
