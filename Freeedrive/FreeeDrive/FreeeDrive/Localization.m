//
//  Localization.m
//  FreeeDriveStore
//
//  Created by KL on 3/22/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "Localization.h"

@implementation Localization

static Localization *gInstance = NULL;

#pragma mark -
#pragma mark Init / Lifecycle

+(Localization *)singleton
{
    @synchronized(self)
    {
        if(gInstance == NULL)
        {
            gInstance = [[Localization alloc]init];
        }
    }
    
    return gInstance;
}

-(id)init
{
    self = [super init];
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark -
#pragma mark Utils

- (void)setLanguage:(NSString *)lang
{
    NSString *path = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj"];
    if (!path)
    {
        _bundle = [NSBundle mainBundle];
        return;
    }
    
    _bundle = [NSBundle bundleWithPath:path];
    
    //also retain language in SP
    
    
    
    NSLog(@"mylang= %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"]);
    [[NSUserDefaults standardUserDefaults] setObject:lang forKey:@"lang"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:lang] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults]synchronize];


    //and as an ivar
    self.languageString = lang;
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment
{
    //NSLog(@"localizing text: %@ for language: %@", key, self.languageString);
    return [self.bundle localizedStringForKey:key value:comment table:nil];
}

@end
