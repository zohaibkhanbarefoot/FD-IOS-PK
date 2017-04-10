//
//  DatabaseManager.m
//  FreeeDriveEnterprise
//
//  Created by ADNEOM on 11/07/16.
//  Copyright © 2016 ColeStreet. All rights reserved.
//

#import "DatabaseManager.h"
#import "FMDB.h"
#import "Ride.h"
#import <sqlite3.h>
#import "UICKeychainStore.h"

@implementation DatabaseManager

+(DatabaseManager *)sharedInstance{
    static dispatch_once_t onceToken;
    static DatabaseManager *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        if(sharedInstance == nil){
            sharedInstance = [[self alloc]init];
        }
    });
    return sharedInstance;
}

- (BOOL)createDataBase{
    //if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isdelete"])
    //[self deleteallrides];
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open]){
        // NSLog(@"db exist = %i",fileExists);
        //Table doesn't exist so we need to create it
        if(![db tableExists:@"rides"]){

        NSString *sql = @"CREATE TABLE IF NOT EXISTS rides (remote_id integer primary key autoincrement, departure_time real, arrival_time real, departure_location text, arrival_location text, time_elapsed real , score real, driver_id text, company_id text, send integer, score_pond real, all_location INTEGER DEFAULT 0,bd_count INTEGER DEFAULT 0);";
            NSLog(@"sql=%@",sql);
            if(![db executeStatements:sql]){
                NSLog(@"DB : %@",[db lastError]);
                [db close];
                return false;
            }else{
                NSLog(@"DB :  creation ok");
              //  [db close];
               // return true;
            }
            
        }
        
        

      /*  //In previous version ( < 1.2 ) the column "time_elapsed_breakspeedlimit doesn't exist"
        if(![db columnExists:@"time_elapsed_breakspeedlimit" inTableWithName:@"rides"]){
            NSString *sql = @"ALTER TABLE rides ADD COLUMN time_elapsed_breakspeedlimit real;";
            if(![db executeStatements:sql]){
                NSLog(@"DB : %@",[db lastError]);
                [db close];
                return false;
            }else{
                NSLog(@"DB :  time_elapsed_breakspeedlimit add ok");
                [db close];
               
                return true;
            }
        }
        */
        

        
        if(![db columnExists:@"all_location" inTableWithName:@"rides"]){
            NSString *sql = @"ALTER TABLE rides ADD COLUMN all_location integer DEFAULT 0;";
            if(![db executeStatements:sql]){
                NSLog(@"DB : %@",[db lastError]);
              //  [db close];
             //   return false;
            }else{
                NSLog(@"DB :  all_location add ok");
                //[db close];
                [self checkAllLocationAfterAlter];
              //  return true;
            }
        }
        
        

        //In previous version ( < 2.1 ) the column "ride_end_reason doesn't exist"
        if(![db columnExists:@"ride_end_reason" inTableWithName:@"rides"]){
            NSString *sql = @"ALTER TABLE rides ADD COLUMN ride_end_reason integer DEFAULT 0;";
            if(![db executeStatements:sql]){
                NSLog(@"DB : %@",[db lastError]);
               // [db close];
              //  return false;
            }else{
                NSLog(@"DB :  ride_end_reason add ok");
            //    [db close];
              //  return true;
            }
        }
        
        
        
        
        //In previous version ( < 1.5 ) the column "bd_count doesn't exist"
        if(![db columnExists:@"bd_count" inTableWithName:@"rides"]){
            
            [self deleteallrides];
            NSString *sql = @"ALTER TABLE rides ADD COLUMN bd_count integer DEFAULT 0;";
            if(![db executeStatements:sql]){
                NSLog(@"DB : %@",[db lastError]);
                //[db close];
               // return false;
            }else{
                NSLog(@"DB :  bd_count add ok");
               // [db close];
               // return true;
            }
            
            
            
        }
        
        
        //In previous version ( < 1.5 ) the column "bd_count doesn't exist"
        if(![db columnExists:@"time_elapsed_breakspeedlimit" inTableWithName:@"rides"]){
            
            [self deleteallrides];
            NSString *sql = @"ALTER TABLE rides ADD COLUMN time_elapsed_breakspeedlimit real;";
            if(![db executeStatements:sql]){
                NSLog(@"DB : %@",[db lastError]);
                //[db close];
               // return false;
            }else{
                NSLog(@"DB :  time_elapsed_breakspeedlimit add ok");
               // [db close];
               // return true;
            }
            
            
            
        }

        [db close];
        return true;
        
    }
    [db close];
    return false;
}

/**
 * This method get all the ride in the DB and check if there are 2 correct location (= 2 cities) for a ride
 * If there're 2 city for a ride we must update its field "all_location" to 1 in order to not update its location.
 */
- (void)checkAllLocationAfterAlter{
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open]){
        NSMutableArray *rideIds = [NSMutableArray new];
        FMResultSet *res = [db executeQuery:@"SELECT remote_id, arrival_location, departure_location FROM rides WHERE all_location = 0"];
        while([res next]) {
            if( [[res stringForColumn:@"departure_location"] rangeOfString:@","].location == NSNotFound && [[res stringForColumn:@"arrival_location"] rangeOfString:@","].location == NSNotFound){
                [rideIds addObject:[NSNumber numberWithInt:[res intForColumn:@"remote_id"]]];
            }
        }
        
        [db close];
        
        if([rideIds count]){
            [self updateAllLocationAfterAlter:rideIds];
        }
    }
}

#pragma mark -  insert/update
/**
 * This function updates the field all_location (1 or default 0 ) in the table after the alter in order to update the location when possible with the city
 * @params rideIds an array which contains all the ride's id where the ride has 2 correct location
 */
-(void)updateAllLocationAfterAlter:(NSArray*)rideIds{
    
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    int count = 0;
    if([db open]){
        for(int i =0; i < [rideIds count]; i++){
            if([db executeUpdate:@"UPDATE RIDES SET all_location = 1 WHERE remote_id = ?",[rideIds[i] objectForKey:@"remote_id"]]){
                count +=1;
                if(count == [rideIds count])
                    [db close];
            }
        }
    }
    
}

- (BOOL)insertRide:(Ride*)ride{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    BOOL success ;
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open]){
        @try {
            success = [db executeUpdate:@"INSERT INTO rides (departure_time, arrival_time, departure_location, arrival_location, time_elapsed, score, driver_id, company_id, send, score_pond, all_location, bd_count,time_elapsed_breakspeedlimit,ride_end_reason) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ? ,?)", [NSNumber numberWithDouble:[[ride departure_time] timeIntervalSince1970]], [NSNumber numberWithDouble:[[ride arrival_time]timeIntervalSince1970]], [ride departure_location], [ride arrival_location],[ride calculStartToEndDifference], [ride score], [ride driver_id] ,[ride company_id], [ride send], [ride calculScorePond], [ride isLocationOk],[ride bd_count],[ride time_elapsedSpeedLimit],[ride ride_end_reason]];
            if(!success){
                NSLog(@" %@",[db lastError]);
            }else{
                NSLog(@" Ride inserted new %@",ride);
                
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }else{
        NSLog(@" DB not open");
        
    }
    
    return success;
}

- (BOOL)insertALLRides:(NSArray*)rides{
    
    
    /*
    

    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    BOOL success ;
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    
    
  //  NSLog(@"myrides= %i",rides.count);
    
    if([db open]){
        @try {

            
            
   
            for ( int i=0 ; i < rides.count ; i++)
            {
                
                NSDictionary *dic_ride=[rides objectAtIndex:i];
                
                
                Ride *ride=[Ride new];
                ride.arrival_time= [NSDate dateWithTimeIntervalSince1970:[[dic_ride valueForKey:@"arrival_time"] intValue]];
                ride.arrival_location = [dic_ride valueForKey:@"arrival_location"];
              //  ride.arrival_time = [NSDate dateWithTimeIntervalSince1970:1490605361];
                ride.company_id =[dic_ride valueForKey:@"company_id"];
                ride.bd_count = [NSNumber numberWithInt:[[dic_ride valueForKey:@"count_bad_behaviour"] intValue]];
               // ride.createdat = 2017-03-27 11:08:32";
               // ride.departure_time = @"2017-03-27";
                ride.departure_location =[dic_ride valueForKey:@"departure_location"];
                ride.departure_time= [NSDate dateWithTimeIntervalSince1970:[[dic_ride valueForKey:@"departure_time"] intValue]];
                ride.driver_id = [dic_ride valueForKey:@"driver_id"];
                //ride.high_ride_distance = [NSNumber numberWithInt:44];
                ride.time_elapsedSpeedLimit = [NSNumber numberWithInt:[[dic_ride valueForKey:@"high_ride_time"] intValue]];
               // ride.id = 4959;
                ride.remote_id = [NSNumber numberWithInt:[[dic_ride valueForKey:@"remote_id"] intValue]];
                ride.score = [NSNumber numberWithInt:[[dic_ride valueForKey:@"score"] intValue]];
                ride.time_elapsed = [NSNumber numberWithInt:[[dic_ride valueForKey:@"time_elapsed"] intValue]];
                ride.send =[NSNumber numberWithInt:1];
                ride.company_id=[dic_ride valueForKey:@"company_id"];
              //  ride.updatdat = @"2017-03-27 11:08:32";
                
             //   NSLog(@"mydict_scores= %@",ride);
     
            
               
                

                success = [db executeUpdate:@"INSERT INTO rides (departure_time, arrival_time, departure_location, arrival_location, time_elapsed, score, driver_id, company_id, send, score_pond, all_location, bd_count,time_elapsed_breakspeedlimit) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ? )", [ride departure_time], [ride arrival_time], [ride departure_location], [ride arrival_location],[ride time_elapsed], [ride score], [ride driver_id] ,[ride company_id], [ride send], [ride calculScorePond], [NSNumber numberWithDouble:1],[ride bd_count],[ride time_elapsedSpeedLimit]];
                
                
                

            
                
            
            
            if(!success){
                NSLog(@"insert error %@",[db lastError]);
            }else{
              //  NSLog(@" Ride inserted new %@",ride);
                
            }
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }else{
        NSLog(@" DB not open");
        
    }
    
    return success;

     
     */
    
    
    return YES;
     }



- (BOOL)deleteallrides{
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isdelete"];
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    BOOL success ;
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open]){
        @try {
            success = [db executeUpdate:@"delete from rides"];
            if(!success){
                NSLog(@" %@",[db lastError]);
            }else{
               // NSLog(@" Ride inserted %@",ride);
                NSLog(@"deleteallprevious");
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }else{
        NSLog(@" DB not open");
        
    }
    
    return success;
}


/**
 *  This method updates all the unsend ride following their remote_id
 * @param rideIds an array which contains all the ride { remote_id : x } send to the backend and well save in online DB
 */
-(void)updateRideUnsend:(NSArray*)rideIds{
    
    if ([rideIds count]>0) {
        
        NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
        int count = 0;
        if([db open]){
            for(int i =0; i < [rideIds count]; i++){
                if([db executeUpdate:@"UPDATE RIDES SET send = 1 WHERE remote_id = ?",[rideIds[i] objectForKey:@"remote_id"]]){
                    count +=1;
                    if(count == [rideIds count])
                        [db close];
                }
            }
        }
    }
}

/**
 *  This method updates a ride whose one of the location was a coordinate
 * @param ride the ride with 2 cities
 */
-(void)updateRideLocation:(Ride*)ride{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open]){
        if([db executeUpdate:@"UPDATE RIDES SET departure_location = ? , arrival_location = ? , all_location = 1 , send = 0 WHERE remote_id = ?" withArgumentsInArray:@[[ride departure_location],  [ride arrival_location], [ride remote_id]]]){
         
            
            
            [db close];
        }else{
            NSLog(@" %@",[db lastError]);
        }
    }
}
#pragma mark - select

- (Ride*)getLastRide{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open]){
        @try {
            FMResultSet *res = [db executeQuery:@"SELECT * FROM rides  ORDER BY datetime(arrival_time) DESC Limit 1 "];
            Ride* ride = [Ride new];
            
            
            
            if ([res next]) {
                
                
                
                
                ride.departure_time = [res stringForColumn:@"departure_time"];
                ride.arrival_time = [res stringForColumn:@"arrival_time"];
                
                
                int temp_timeelapse= [res doubleForColumn:@"time_elapsed"];
                temp_timeelapse=temp_timeelapse*60;
                ride.time_elapsed =  [NSNumber numberWithInt:temp_timeelapse];
                ride.departure_location = [res stringForColumn:@"departure_location"];
                ride.arrival_location =  [res stringForColumn:@"arrival_location"];
                ride.score = [NSNumber numberWithDouble:[res doubleForColumn:@"score"]];
                ride.bd_count = [NSNumber numberWithInt:[res intForColumn:@"bd_count"]];
                if([res intForColumn:@"bd_count"]<1)
                    ride.bd_count=0;
                NSLog(@"bd_count=%d", [res intForColumn:@"bd_count"]);
                //Always the current driver
                /* ride.driver_id = [res stringForColumn:@"driver_id"];
                 ride.company_id = [res stringForColumn:@"company_id"];*/
                //ride.send = [NSNumber numberWithInt:[res intForColumn:@"send"]];
            }
            
            else{
                if([[NSUserDefaults standardUserDefaults] valueForKey:@"account"])
                {
                    // Ride * lastride_local=[Ride new];
                    Ride *lastride_local_temp=[Ride new];
                    lastride_local_temp=  [[[NSUserDefaults standardUserDefaults] valueForKey:@"account"] valueForKey:@"LastRide"];
                    ride.arrival_time=  [lastride_local_temp valueForKey:@"arrival_date"];
                    ride.arrival_location  =  [lastride_local_temp valueForKey:@"arrival_location"];
                    ride.arrival_time =  [lastride_local_temp valueForKey:@"arrival_time"];
                    ride.company_id= [lastride_local_temp valueForKey:@"company_id"];
                    ride.bd_count=   [lastride_local_temp valueForKey:@"count_bad_behaviour"];
                    int temp_timeelapse= [[lastride_local_temp valueForKey:@"time_elapsed"] intValue]*60;
                    ride.time_elapsed=[NSNumber numberWithInt:temp_timeelapse];
                    ride.departure_time = [lastride_local_temp valueForKey:@"departure_date"];
                    ride.departure_location= [lastride_local_temp valueForKey:@"departure_location"];
                    ride.departure_time = [lastride_local_temp valueForKey:@"departure_time"];
                    ride.driver_id=[lastride_local_temp valueForKey:@"driver_id"];
                    ride.time_elapsedSpeedLimit=  [lastride_local_temp valueForKey:@"high_ride_time"];
                    ride.score=   [lastride_local_temp valueForKey:@"score"];
                }
                
            }
            //NSLog(@"Last ride : %@", ride);
            return ride;
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }else{
        return nil;
    }
}

/**
 *  This method get the average of the score for all the ride
 *  @return the average of all the ride'score
 */
- (double)getAllRidesAverage{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open]){
        @try {
            int count = [db intForQuery:@"SELECT count(*) FROM rides"];
            if(count > 0){
                return [db doubleForQuery:@"SELECT AVG(rr.score) FROM rides rr WHERE rr.remote_id IN ( SELECT r.remote_id FROM rides r)"];
            }else{
                return 100;
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }
}

/**
 *  This method gets total time of all the ride
 *  @return the sum of time of all the ride'score
 */







-(NSMutableArray  *)getAllRides{
    
    
    
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    
    
    
    
    NSMutableArray *array=[[NSMutableArray alloc] init];
    if([db open]){
        
        FMResultSet *res = [db executeQuery:@"SELECT * from rides where send = 0"];
        
        while ([res next]) {
            Ride* ride = [Ride new];
            //  ride.time_elapsed = [NSNumber numberWithDouble:[res intForColumn:@"time_elapsed"]];
            ride.score = [NSNumber numberWithDouble:[res intForColumn:@"score"]];
            ride.time_elapsed =  [NSNumber numberWithDouble:[res intForColumn:@"time_elapsed"]];
            
            
            ride.arrival_location=[res stringForColumn:@"arrival_location"];
            ride.arrival_time=[res dateForColumn:@"arrival_time"];
            ride.bd_count=[NSNumber numberWithDouble:[res intForColumn:@"bd_count"]];
            ride.company_id=[res stringForColumn:@"company_id"];
            ride.departure_location=[res stringForColumn:@"departure_location"];
            ride.departure_time=[res dateForColumn:@"departure_time"];
            ride.driver_id=[res stringForColumn:@"driver_id"];
            // ride.hasLocation=[NSNumber numberWithDouble:[res intForColumn:@"hasLocation"]];
            ride.remote_id=[NSNumber numberWithDouble:[res intForColumn:@"remote_id"]];
            ride.send=[NSNumber numberWithDouble:[res intForColumn:@"send"]];
            
            [array addObject:ride];
            
            
            NSLog(@"my allrides= %@",ride);
            
            
        }
        
        
        return array;
    }
    return nil;
    
    
    
}
- (long)getAllRidesTime{
    //time in minutes 
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open]){
        @try {
            int count = [db intForQuery:@"SELECT count(*) FROM rides where send = 0"];
            if(count > 0){
                return [db doubleForQuery:@"SELECT SUM(rr.time_elapsed) FROM rides rr where send  = 0"];
            }else{
                return 0;
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }
}

/**
 *  This method gets total time AVG of all the ride
 *  @return the sum of time of all the ride'score
 */
- (long)getAllRidesAVGTimeInMinute{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open]){
        @try {
            int count = [db intForQuery:@"SELECT count(*) FROM rides"];
            if(count > 0){
                return [db doubleForQuery:@"SELECT AVG(rr.time_elapsed) FROM rides rr"]/60;
            }else{
                return 0;
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }
}

/**
 *  This method gets the AVG of all the ride (with weigth)
 *  @return the sum of time of all the ride'score
 */
- (long)getAllRidePonderation{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open]){
        @try {
            int count = [db intForQuery:@"SELECT count(*) FROM rides"];
            if(count > 0){
                long allTime = [db doubleForQuery:@"SELECT SUM(rr.time_elapsed) FROM rides rr"];
                long AllScore = [db doubleForQuery:@"SELECT SUM(rr.score_pond) FROM rides rr"];
                return AllScore/allTime;
            }else{
                return 100;
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }
}




- (int)getAllRidesBd_count{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open]){
        @try {
            int count = [db intForQuery:@"SELECT count(*) FROM rides where send = 0"];
            if(count > 0){
                int bd_count = [db doubleForQuery:@"SELECT SUM(rr.bd_count) FROM rides rr where send = 0"];
                
                
                
                NSLog(@"mybdcounts=%i",bd_count);
                
                
                
                bd_count=[[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] valueForKey:@"total_bad_counts"] intValue]+bd_count;
                
                
                return bd_count;
            }else{
                
                
                
                return [[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] valueForKey:@"total_bad_counts"] intValue];
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }
}

/**
 *  This method is used for synchro.
 *  Select all the ride unsend in order to send them to the backend
 *  @return rides unsend , in JSON format { data : [] }
 */


- (NSString*)getUnsendRides{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *results = [NSMutableArray new];
    
    if ([db open]){
        @try {
            FMResultSet *res = [db executeQuery:@"SELECT \
                                remote_id,bd_count as count_bad_behaviour, departure_time, arrival_time, time_elapsed as time_elapsed, arrival_location, departure_location, score, driver_id, company_id,time_elapsed_breakspeedlimit as high_ride_time , ride_end_reason as reason_end_ride  \
                                FROM rides \
                                WHERE send = 0"];
            
            while ([res next]) {
                [results addObject:[res resultDictionary]];
            }
            if ([results count]) {
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results
                                                                   options:0 //don't care about the readability
                                                                     error:&error];
                if (!jsonData) {
                    return nil;
                } else {
                    
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
                    
                    deviceId = [deviceId stringByReplacingOccurrencesOfString:@" " withString:@""];
                    
                    
                    return [NSString stringWithFormat:@"{ \"data\" : %@ , \"device_id\" : \"%@\"} ",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding],deviceId];
                }
            }else{
                return nil;
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }
}


- (NSString*)getallRides_localdb{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *results = [NSMutableArray new];
    
    if ([db open]){
        @try {
            FMResultSet *res = [db executeQuery:@"SELECT \
                                remote_id,bd_count as count_bad_behaviour, departure_time, arrival_time, time_elapsed as time_elapsed, arrival_location, departure_location, score, driver_id, company_id,time_elapsed_breakspeedlimit as high_ride_time  \
                                FROM rides "];
            
            while ([res next]) {
                [results addObject:[res resultDictionary]];
            }
            if ([results count]) {
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results
                                                                   options:0 //don't care about the readability
                                                                     error:&error];
                if (!jsonData) {
                    return nil;
                } else {
                    
                    

                    
                    return [NSString stringWithFormat:@"{ \"data\" : %@ , \"email\" : \"%@\"} ",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding],[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"email"]];
                    
                    
                    //[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"email"]
                }
            }else{
                return nil;
            }
        } @catch (NSException *exception) {
            NSLog(@" %@",[db lastError]);
        } @finally {
            [db close];
        }
    }
}

/**
 * Get all ride with at least one coordinate in it.
 * Update those ride with the correct location
 */
- (void)updateUncorrectLocation{
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *results = [NSMutableArray new];
    
    if([db open]){
        int count = [db intForQuery:@"SELECT count(*) FROM rides WHERE all_location = 0"];
        if(count <= 0){
            [db close];
            return ;
        }else{
            
            FMResultSet *res = [db executeQuery:@"SELECT remote_id,arrival_location,departure_location FROM rides WHERE all_location = 0"];
            
            while ([res next]) {
                Ride* ride = [Ride new];
                ride.remote_id = [NSNumber numberWithDouble:[res intForColumn:@"remote_id"]];
                ride.departure_location = [res stringForColumn:@"departure_location"];
                ride.arrival_location =  [res stringForColumn:@"arrival_location"];
                [results addObject:ride];
            }
            [db close];
            
            for(int i = 0; i < [results count]; i++){
                
                [results[i] updateLocationWithCallback:^(BOOL ok, Ride* ride) {
                    if(ok){
                       [self updateRideLocation:ride];
                    }
                }];
            }
        }
        
    }
}

/**
 *  Populate for test purpose only
 */
- (void)populate{
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"freeedriveDB.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]){
        
        [db executeUpdate:@"INSERT INTO rides (departure_time, arrival_time, departure_location, arrival_location, time_elapsed, score, driver_id, company_id, send, score_pond, all_location,bd_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]], [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970 ]],@"50.8265974,4.3859405",@"50.8265974,4.3859405", @5400 , @80,@"83",@"5", @1,@324000, @0];
        [db executeUpdate:@"INSERT INTO rides (departure_time, arrival_time, departure_location, arrival_location, time_elapsed, score, driver_id, company_id, send, score_pond, all_location,bd_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]], [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970 ]],@"50.8265974,4.3859405",@"Bruxelles", @5400 , @80,@"83",@"5", @1,@324000, @0];
        [db executeUpdate:@"INSERT INTO rides (departure_time, arrival_time, departure_location, arrival_location, time_elapsed, score, driver_id, company_id, send, score_pond, all_location,bd_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]], [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970 ]],@"Bruxellesaze",@"azeBruxelles", @5400 , @80,@"83",@"5", @1,@324000, @1];
        [db close];
        
        //NSLog(@"populate %@",[db lastError]);
        
    }
    
}
@end
