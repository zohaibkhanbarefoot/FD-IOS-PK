
// KL

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "AFNetworking.h"


//zootopia
//urls
//#define kRootURL @"http://dev-freedrive.colestreet.com/freedriveapi/"
//#define kRootURL @"http://webapp.freeedrive.com/freedriveapi/"
#define kRootURL @"http://xyperdemos.com/pk_freeedrive_backend-master/public"
//#define kRootURL @"http://192.168.100.4"
//#define kRootURL_feedback @"http://192.168.100.4"
#define kRootURL_feedback @"http://xyperdemos.com/pk_freeedrive_backend-master/public"
#define kFunctionsURL   @"getfunctions"
#define kDepartmentsURL @"getdepartments"
#define kWorksitesURL   @"getworksites"
//#define kRegisterURL    @"userregister"
#define kRegisterURL    @"/api/register"
//#define kRegisterURL    @"/api/signup"

/////
#define ksmsVerification    @"/api/smsVerification"
//#define kLoginURL       @"userlogin"
//#define kLoginURL    @"/api/auth"
#define kpostLocalScore    @"/api/mail"
#define kLoginURL    @"/api/ioslogin"

//#define kLoginURL    @"/api/signin"

#define kFeedbackURL    @"/api/feedback"
#define kScoreURL @"/api/score"
#define kaccountURL @"/api/profile"
#define kScorekURL @"/api/score"
#define kUpdatePhoneNumURL @"/api/updatePhonenumber"
#define kResendEmailURL @"sendemail"
#define kResendSmsURL @"/api/mobileresendsms"
#define kGetNotificationURL @"/api/getnotifications"
#define kAllowedAppsURL @"getallowedapps"
#define kAllowedCategoriesURL @"getallowedcats"
#define kRateUsURL            @"postcomment"
#define kUsageURL             @"usage_log"
#define kBluetoothUsageURL    @"usage_bluetooth"
#define kAccountURL 		@"getuseraccount"
#define kUpdateAccountURL 	@"/api/profile"
#define kqrcodeURL 	@"/api/uuid"
#define kupdateqrcodeURL 	@"/api/UpdateUuid"

typedef void (^CompletionBlock)(id response);

@interface UDOperator : NSObject <NSURLConnectionDelegate, NSCopying>
{
}
@property (strong, nonatomic) CompletionBlock cBlock;
+(UDOperator *)singleton;
-(id)init;
-(BOOL)validateEmail:(NSString *)candidate;
-(BOOL)isConnected;
-(void) getFunctions:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) getDepartments:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) getWorksites:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postRegister:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postLogin:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) fetchProfile:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;

-(void) getNotifications:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) post_contactus:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postQrcode:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) updateQrcode:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) updatePhoneNumber:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postResendEmail:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postResendCode:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
//-(void) getAllowedApps:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
//-(void) getAllowedCategories:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postRateUs:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postUsage:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postBluetoothUsage:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) getAccount:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postAccount:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postSmsVerification:(NSMutableDictionary *)params withCompletionBlock:(CompletionBlock)completionBlock;
-(void) postUnsendScore:(NSString *)json withCompletionBlock:(CompletionBlock)completionBlock;

//send to email for testing
-(void) postLocalScore:(NSString *)json withCompletionBlock:(CompletionBlock)completionBlock;

-(void) getNotificatons:(NSMutableDictionary *)params ;
-(void) checkOnlineVersion;



@end
