//
//  DatabaseManager.h
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 11/07/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Ride;
@interface DatabaseManager : NSObject

+ (DatabaseManager *)sharedInstance;
- (BOOL)createDataBase;

#pragma mark - insert/update
- (BOOL)insertRide:(Ride*)ride;
- (BOOL)insertALLRides:(NSArray*)rides;




- (void)updateRideUnsend:(NSArray*)rideIds;
- (void)updateUncorrectLocation;
-(NSArray *)getAllRides;
#pragma mark - select
- (Ride*)getLastRide;

/**
 *  This method get the average of the score for all the ride
 *  @return the average of all the ride'score
 */
- (double)getAllRidesAverage;

/**
 *  This method get total time of all the ride
 *  @return the sum of time of all the ride'score
 */
- (long)getAllRidesTime;

/**
 *  This method get total time AVG of all the ride
 *  @return the sum of time of all the ride'score
 */
- (long)getAllRidesAVGTimeInMinute;
-(int)getAllRidesBd_count;
/**
 *  This method is used for synchro.
 *  Select all the ride un send in order to send them to the backend
 *  @return rides unsend , in JSON format
 */
- (NSString*)getUnsendRides;
- (NSString*)getallRides_localdb;

/**
 *  This method calcul the avegare with ponderation
 *  @return score following ponderation
 */
- (long)getAllRidePonderation;

//For test purpose
- (void)populate;

@end
