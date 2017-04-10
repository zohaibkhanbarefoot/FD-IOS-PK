//
//  FileLogger.h
//  WaiterOne
//
//  Created by Eddy Van Hoeserlande on 01/04/15.
//
//

#import <Foundation/Foundation.h>

//Logging
#define NSLog(frmt, ...) [[FileLogger sharedInstance] log:@"<%@:%d> %s : %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:frmt, ##__VA_ARGS__]]

@interface FileLogger : NSObject {

    NSFileHandle *logFile;
    NSDateFormatter *formatter;

}

+ (FileLogger *)sharedInstance;

- (void)log:(NSString *)format, ...;

@end