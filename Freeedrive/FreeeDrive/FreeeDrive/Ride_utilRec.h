//
//  Ride_utilRec.h
//  FreeeDrive
//
//  Created by user on 22/02/2017.
//  Copyright © 2017 Barefoot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ride_utilRec : NSObject
@property (strong) NSDate *start_time;
@property (strong) NSDate *end_time;
@property (strong) NSNumber *time_elapsed;
@property BOOL isallow;

- (NSNumber*)calculStartToEndDifference;
- (void)setEndTime;
- (void)setStartTime;


@end
