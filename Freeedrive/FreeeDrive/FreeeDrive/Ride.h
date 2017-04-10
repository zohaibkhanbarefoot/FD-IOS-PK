//
//  Ride.h
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 11/07/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface Ride : NSObject

@property (strong) NSDate *departure_time;
@property (strong) NSDate *arrival_time;
@property (strong) NSString *departure_location;
@property (strong) NSString * arrival_location;
@property (strong) NSString *driver_id;
@property (strong) NSString *company_id;
@property (strong) NSNumber *time_elapsed;
@property (strong) NSNumber *time_elapsedSpeedLimit;
@property (strong) NSNumber *score;
@property (strong) NSNumber *send;
@property (strong) NSNumber *hasLocation;
@property (strong) NSNumber *remote_id;
@property (strong) NSNumber *ride_end_reason;
@property (strong) NSNumber *bd_count;
@property (nonatomic) CLLocation *arrival_cllocation;
@property (nonatomic) CLLocation *departure_cllocation;
@property(strong) NSMutableArray *array_badCount_timestamps;
- (NSNumber*)calculStartToEndDifference;
- (NSNumber*)calculScoreInPercent;
- (NSNumber*)calculStartToEndDifferenceInSec;
- (NSNumber*)calculScorePond;
- (void)setLocation;
-(void)setTime_elapsed_breakspeedlimit:(int)time_elapsed;
- (void)setTime:(BOOL)BT;
- (NSNumber*) isLocationOk;
- (void)updateLocationWithCallback:(void (^)(BOOL, Ride*))completion;

@end
