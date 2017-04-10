//
//  Ride_utilRec.m
//  FreeeDrive
//
//  Created by user on 22/02/2017.
//  Copyright © 2017 Barefoot. All rights reserved.
//

#import "Ride_utilRec.h"

@implementation Ride_utilRec

- (Ride_utilRec*)init{
    self = [super init];
    if (self) {
  
            }
    
    return self;
}

- (NSNumber*)calculStartToEndDifference{
    int timeElapsed = [self.end_time timeIntervalSinceDate:self.start_time];
    //IF time  < 60 sec (1min) , shouldn't happen
    //Set the time to 60sec in order to have at least one minute
    if(timeElapsed <= 60){
      //  return @1;
    }
    self.time_elapsed=[NSNumber numberWithInt:timeElapsed];
    
    NSLog(@"utilelapsedtime=%@",self.time_elapsed);
    return [NSNumber numberWithInt:timeElapsed];
}
- (void)setStartTime{
    
    self.start_time = [NSDate date];
    
    NSLog(@"mystarttime=%@",self.start_time);
}
- (void)setEndTime{
   self.end_time = [NSDate date];
     NSLog(@"myendtime=%@",self.end_time);
}


@end
