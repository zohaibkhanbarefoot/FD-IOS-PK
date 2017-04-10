//
//  Localization.h
//  FreeeDriveStore
//
//  Created by KL on 3/22/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Localization : NSObject

@property (nonatomic, strong, readonly) NSBundle *bundle;
@property (strong, nonatomic) NSString *languageString;

+(Localization *)singleton;
-(id)init;
- (void)setLanguage:(NSString *)lang;
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;

@end
