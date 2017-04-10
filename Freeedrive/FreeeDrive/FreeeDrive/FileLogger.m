//
//  FileLogger.m
//  WaiterOne
//
//  Created by Eddy Van Hoeserlande on 01/04/15.
//
//

#import "FileLogger.h"

@implementation FileLogger

- (void)dealloc {
    logFile = nil;
}

- (id) init {
    
    if (self == [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@LOG];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath])
            [fileManager createFileAtPath:filePath
                                 contents:nil
                               attributes:nil];
        logFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [logFile seekToEndOfFile];
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return self;
}

- (void)log:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    message = [NSString stringWithFormat:@"%@ %@", [formatter stringFromDate:[NSDate date]], message];
    
    printf("%s\n", [message UTF8String]);

    [logFile writeData:[[message stringByAppendingString:@"\n"]
                        dataUsingEncoding:NSUTF8StringEncoding]];
    [logFile synchronizeFile];
}

+ (FileLogger *)sharedInstance {
    static FileLogger *instance = nil;
    if (instance == nil) instance = [[FileLogger alloc] init];
    return instance;
}
@end
