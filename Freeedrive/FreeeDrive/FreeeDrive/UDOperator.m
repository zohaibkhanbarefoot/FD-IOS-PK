
#import "UDOperator.h"
#import "Reachability.h"
#import "AppDelegate.h"

@interface UDOperator()
@property (weak) Reachability *internetReachability;

@end
@implementation UDOperator

static UDOperator *gInstance = NULL;

#pragma mark -
#pragma mark Init / Lifecycle

+(UDOperator *)singleton
{
    @synchronized(self)
    {
        if(gInstance == NULL)
        {
            gInstance = [[UDOperator alloc]init];
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

void UIImageFromURL( NSURL * URL, void (^imageBlock)(UIImage * image), void (^errorBlock)(void) )
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void)
                   {
                       NSData * data = [[NSData alloc] initWithContentsOfURL:URL];
                       UIImage * image = [[UIImage alloc] initWithData:data];
                       dispatch_async( dispatch_get_main_queue(), ^(void){
                           if( image != nil )
                           {
                               imageBlock( image );
                           } else {
                               errorBlock();
                           }
                       });
                   });
}

-(BOOL)validateEmail:(NSString *)candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

-(BOOL)isConnected{
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    
    [self.internetReachability startNotifier];

    NetworkStatus internetStatus = [self.internetReachability currentReachabilityStatus];
    
    switch (internetStatus) {
        case NotReachable: {
            
            
        
            
            return false;
            break;
        }
            
        case ReachableViaWiFi: {
            //WIFI
            return true;
            break;
        }
            
        case ReachableViaWWAN: {
            //3G / 4G
            return true;
            break;
        }
        default:{
            return false;
            break;
        }
    }
}

#pragma mark -
#pragma mark API INTERCOMM

-(void) getFunctions:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock
{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kFunctionsURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager GET:path
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         id rez = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSLog(@"rez: %@", rez);
         
         id ret = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:NSJSONReadingMutableLeaves
                                                    error:nil];
         if(ret && [ret isKindOfClass:[NSArray class]])
         {
             completionBlock(ret);
         }
         else
             completionBlock(nil);
         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@", error);
         completionBlock(nil);
     }];
}

-(void) getDepartments:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock
{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kDepartmentsURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager GET:path
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //id rez = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         //NSLog(@"rez: %@", rez);
         
         id ret = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:NSJSONReadingMutableLeaves
                                                    error:nil];
         if(ret && [ret isKindOfClass:[NSArray class]])
         {
             completionBlock(ret);
         }
         else
             completionBlock(nil);
         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@", error);
         completionBlock(nil);
     }];
}

-(void)checkOnlineVersion{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //NSString *path = [kRootURL stringByAppendingString:kWorksitesURL];
    //NSLog(@"calling %@ with %@", path, params);
    [manager GET:@"https://s3-eu-west-1.amazonaws.com/freedrive.enterprise/live+version/version.json"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject){
             NSDictionary *version = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
             
#if DEBUG
             /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
              message:[NSString stringWithFormat:@"version : %@  current : %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [version objectForKey:@"current-version"] ]
              delegate:nil
              cancelButtonTitle:@"OK"
              otherButtonTitles:nil];
              [alert show];*/
             if(version && [version objectForKey:@"current-version"]){
                 if(![[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] isEqualToString:[version objectForKey:@"current-version"]]){
                     [self downloadNewVersion];
                 }
                 
             }
#else
             if(version && [version objectForKey:@"current-version"]){
                 if(![[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] isEqualToString:[version objectForKey:@"current-version"]]){
                     [self downloadNewVersion];
                 }
             }
#endif
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@", error);
     }];
    
}

-(void)downloadNewVersion{
    @try {
        NSURL *installationURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",[@"https://s3-eu-west-1.amazonaws.com/freedrive.enterprise/manifest.plist" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [[UIApplication sharedApplication] openURL:installationURL];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

-(void) getWorksites:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock
{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kWorksitesURL];
    //NSLog(@"calling %@ with %@", path, params);
    [manager GET:path
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //id rez = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         //NSLog(@"rez: %@", rez);
         id ret = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:NSJSONReadingMutableLeaves
                                                    error:nil];
         if(ret && [ret isKindOfClass:[NSArray class]])
         {
             completionBlock(ret);
         }
         else
             completionBlock(nil);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@", error);
         completionBlock(nil);
     }];
}

-(void) postRegister:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock
{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kRegisterURL];
    NSLog(@"calling %@ with %@", path, params);
    
    [manager POST:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              completionBlock([NSNumber numberWithLong:[operation response].statusCode]);
              
              
          }failure:^(AFHTTPRequestOperation *operation, NSError *error){
              NSLog(@"signuperror: %@", error);
              completionBlock([NSNumber numberWithLong:[operation response].statusCode]);
          }];
}
-(void) fetchProfile:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:@"/api/getuserdata"];
    NSLog(@"calling %@ with %@", path, params);
    // [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
    
    [manager POST:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              //  completionBlock([NSNumber numberWithLong:[operation response].statusCode]);
              
              //  NSLog(@"Myresponseobject = %@",[NSNumber numberWithLong:[operation response].statusCode]);
              
              completionBlock([NSNumber numberWithLong:[operation response].statusCode]);
              
              if( [[operation response] statusCode] == 200){
                
                  
                  completionBlock((NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil]);
              }else{
                  completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
              }
              
          }failure:^(AFHTTPRequestOperation *operation, NSError *error){
              NSLog(@"error: %@", error);
              completionBlock([NSNumber numberWithLong:[[operation response] statusCode]]);
          }];


}
-(void) postLogin:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    //score update
    //profile update
    //store.
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kLoginURL];
    NSLog(@"calling %@ with %@", path, params);
   // [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        
    [manager POST:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject){
            //  completionBlock([NSNumber numberWithLong:[operation response].statusCode]);
             
      //  NSLog(@"Myresponseobject = %@",[NSNumber numberWithLong:[operation response].statusCode]);
              
        completionBlock([NSNumber numberWithLong:[operation response].statusCode]);
              
              
              
              

        if( [[operation response] statusCode] == 200){
            
            NSString *myString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            NSLog(@"mystring=%@",myString);
            
            
            //[dict setValue: myString forKey:@"auth"];
            [[NSUserDefaults standardUserDefaults] setObject:myString forKey:@"auth"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"dict= %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"auth"]);
            
            
            completionBlock((NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil]);
        }else{
            completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error: %@", error);
        completionBlock([NSNumber numberWithLong:[[operation response] statusCode]]);
    }];
}


-(void) getNotifications:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kGetNotificationURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        if(responseObject && [[operation response] statusCode] == 200){
            completionBlock((NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil]);
        }else{
            completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error: %@", error);
        completionBlock([NSNumber numberWithLong:[[operation response] statusCode]]);
    }];
}



-(void) postSmsVerification:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:ksmsVerification];
    NSLog(@"calling %@ with %@", path, params);
    [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"my resposne object = %@",json);
        if([[operation response] statusCode] == 200){
            
            NSString *myString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            //[dict setValue: myString forKey:@"auth"];
            [[NSUserDefaults standardUserDefaults] setObject:myString forKey:@"auth"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"dict= %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"auth"]);
            
            
            completionBlock([NSNumber numberWithInteger:[[operation response]statusCode]]);
        }else{
            completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error: %@", error);
        completionBlock([NSNumber numberWithLong:[[operation response] statusCode]]);
    }];
}

-(void) post_contactus:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kFeedbackURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"my resposne object = %@",json);
        if(responseObject && [[operation response] statusCode] == 200){
            completionBlock([NSNumber numberWithInteger:[[operation response]statusCode]]);
        }else{
            completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error: %@", error);
        completionBlock([NSNumber numberWithLong:[[operation response] statusCode]]);
    }];
}



-(void) postQrcode:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kqrcodeURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"my resposne object = %@",json);
        if([[operation response] statusCode] == 200){
            
            NSString *myString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            //[dict setValue: myString forKey:@"auth"];
            [[NSUserDefaults standardUserDefaults] setObject:myString forKey:@"auth"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"dict= %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"auth"]);
            
            
            completionBlock([NSNumber numberWithInteger:[[operation response]statusCode]]);
        }else{
            completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error: %@", error);
        completionBlock([NSNumber numberWithLong:[[operation response] statusCode]]);
    }];
}


-(void) updateQrcode:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kupdateqrcodeURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"my resposne object = %@",json);
        if(responseObject && [[operation response] statusCode] == 200){
            completionBlock([NSNumber numberWithInteger:[[operation response]statusCode]]);
        }else{
            completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error: %@", error);
        completionBlock([NSNumber numberWithLong:[[operation response] statusCode]]);
    }];
}


-(void) postResendEmail:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock
{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kResendEmailURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager POST:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         id rez = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSLog(@"rez: %@", rez);
         
         id ret = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:NSJSONReadingMutableLeaves
                                                    error:nil];
         if(ret && [ret isKindOfClass:[NSDictionary class]])
         {
             completionBlock(ret);
         }
         else
             completionBlock(nil);
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@", error);
         completionBlock(nil);
     }];
}



-(void) postResendCode:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock
{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kResendSmsURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager POST:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         id rez = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSLog(@"rez: %@", rez);
         
         id ret = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:NSJSONReadingMutableLeaves
                                                    error:nil];
         if(ret && [ret isKindOfClass:[NSDictionary class]])
         {
             completionBlock(ret);
         }
         else
             completionBlock(nil);
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@", error);
         completionBlock(nil);
     }];
}


-(void) postRateUs:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    
    NSString *strURL = [NSString stringWithFormat:@"%@%@", kRootURL_feedback,kFeedbackURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"]]  forHTTPHeaderField: @"Authorization"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    
    
    
    NSLog(@"myauth= %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"auth"]);
    NSLog(@"rateus= %@  %@",strURL,params);
    //NSString* json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setHTTPBody:jsonData /* [json dataUsingEncoding:NSUTF8StringEncoding]*/];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        
        if ([operation response].statusCode == 200){
            
            completionBlock([NSNumber numberWithInteger:[[operation response]statusCode]]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"responseObject %@",error.userInfo);
        
        completionBlock([NSNumber numberWithInteger:[[operation response]statusCode]]);    }];
    
    [op start];
    
}

-(void) postUsage:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    if(![self isConnected]){
        completionBlock(@"no_internet");
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kUsageURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager POST:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         id rez = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSLog(@"rez: %@", rez);
         
         id ret = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:NSJSONReadingMutableLeaves
                                                    error:nil];
         if(ret && [ret isKindOfClass:[NSDictionary class]])
         {
             completionBlock(ret);
         }
         else
             completionBlock(nil);
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@", error);
         completionBlock(nil);
     }];
}

-(void) postBluetoothUsage:(NSDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock
{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kBluetoothUsageURL];
    //NSLog(@"calling %@ with %@", path, params);
    [manager POST:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         id ret = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:NSJSONReadingMutableLeaves
                                                    error:nil];
         if(ret && [ret isKindOfClass:[NSDictionary class]])
         {
             completionBlock(ret);
         }
         else
             completionBlock(nil);
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@", error);
         completionBlock(nil);
     }];
}

- (void)postUnsendScore:(NSString *)json withCompletionBlock:(CompletionBlock)completionBlock{
    AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    if(!json){
     //   AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate stopTimer_Reachability];
        completionBlock(nil);
    }else{
        NSLog(@" string json %@",json);
    }
    if(![self isConnected]){
        
        completionBlock(nil);
        return;
    }
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@",kRootURL,kScorekURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    //NSLog(@" account : %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"account"]);
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"] ] forHTTPHeaderField: @"Authorization"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [json dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    NSLog(@"myjsonscore=%@",json);
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
         NSLog(@"responseObjectjsonscore %d",[operation response].statusCode);
        if (responseObject && [operation response].statusCode == 200){
            
            @try {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                //NSLog(@"json %@",[json objectForKey:@"data"]);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sync_completed" object:nil];
                
                completionBlock([json objectForKey:@"data"]);
            } @catch (NSException *exception) {
                completionBlock(nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"responseObjecterrorscore %@",error.userInfo);
        
        
        
        if([operation response].statusCode == 401)
        {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"account"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [delegate logout];
        }
        
        completionBlock(nil);
    }];
    
    [op start];
    
}

/*
- (void)postLocalScore:(NSString *)json withCompletionBlock:(CompletionBlock)completionBlock{
    if(!json){
        completionBlock(nil);
    }else{
        NSLog(@" string json %@",json);
    }
    if(![self isConnected]){
        completionBlock(nil);
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://192.168.10.11/pk_freeedrive_backend-master/public/mail"] parameters:json success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        
        NSLog(@"responseObjectjsonlocalscore %@",responseObject);
        if (responseObject && [operation response].statusCode == 200){
            @try {
           
                
                completionBlock(nil);
            } @catch (NSException *exception) {
                completionBlock(nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"responseObjecterrorscoreerror %@",error.userInfo);
        
        completionBlock(nil);
    }];
    
   
    
}


*/


- (void)postLocalScore:(NSString *)json withCompletionBlock:(CompletionBlock)completionBlock{
    
    if(!json){
        completionBlock(nil);
    }else{
        NSLog(@" string json %@",json);
    }
    if(![self isConnected]){
        completionBlock(nil);
        return;
    }
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@",kRootURL,kpostLocalScore];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    //NSLog(@" account : %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"account"]);
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"] ] forHTTPHeaderField: @"Authorization"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [json dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    NSLog(@"myjsonscorelocal=%@",json);
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"responseObjectjsonscore %@",responseObject);
        if (responseObject && [operation response].statusCode == 200){
            
            @try {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                //NSLog(@"json %@",[json objectForKey:@"data"]);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sync_completed" object:nil];
                
                completionBlock([json objectForKey:@"data"]);
            } @catch (NSException *exception) {
                completionBlock(nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"responseObjecterrorscore %@",error.userInfo);
        
        
        
        if([operation response].statusCode == 401)
        {
            
            
            AppDelegate *delegte=[[UIApplication sharedApplication] delegate];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"account"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [delegte logout];
        }
        
        completionBlock(nil);
    }];
    
    [op start];
    
}


-(void) getAccount:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    
    if(![self isConnected]){
        completionBlock(@"no_internet");
        return;
    }
    
    //NSLog(@"Error: %@",[NSString stringWithFormat:@"%@%@", kRootURL,kaccountURL]);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@%@", kRootURL,kaccountURL] parameters:@{@"token":[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"token"] } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(responseObject && [operation response].statusCode == 200){
            completionBlock(responseObject);
        }else{
            completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
        
    }];
}

-(void) postAccount:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock
{
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    NSString *strURL = [NSString stringWithFormat:@"%@%@", kRootURL,kaccountURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"] ] forHTTPHeaderField: @"Authorization"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    //NSString* json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setHTTPBody:jsonData /* [json dataUsingEncoding:NSUTF8StringEncoding]*/];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        
        if ([operation response].statusCode == 200){
            
            @try {
                completionBlock([NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil]);
            } @catch (NSException *exception) {
                completionBlock(nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"responseObject %@",error.userInfo);
        
        completionBlock(nil);
    }];
    
    [op start];
    
}
-(void) updatePhoneNumber:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock{
    
    if(![self isConnected])
    {
        completionBlock(@"no_internet");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_internet", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        
        
        return;
    }

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *path = [kRootURL stringByAppendingString:kUpdatePhoneNumURL];
    NSLog(@"calling %@ with %@", path, params);
    [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"my resposne object = %@",json);
        if(responseObject && [[operation response] statusCode] == 200){
            completionBlock([NSNumber numberWithInteger:[[operation response]statusCode]]);
        }else{
            completionBlock([NSNumber numberWithLong:[[operation response]statusCode]]);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error: %@", error);
        completionBlock([NSNumber numberWithLong:[[operation response] statusCode]]);
    }];

    



}

@end
