//
//  LoginViewController.m
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "LoginViewController.h"
#import "UDOperator.h"
#import "MBProgressHUD.h"
#import "UICKeychainStore.h"
#import "AppDelegate.h"
#import "QRCodeScanner.h"
#import "SignupViewController.h"
#import "ConfirmPhoneNumber.h"
#include <sys/sysctl.h>
#import "UIButton+Extensions.h"
#import "CountryPicker.h"
#import "iBeaconManager.h"
#import "CountryListViewController.h"
#import "DatabaseManager.h"

@import Firebase;
@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property(weak , nonatomic) IBOutlet UILabel *titleLabel;



@property(weak , nonatomic) IBOutlet UILabel *newphNoLabel;
@property(weak , nonatomic) IBOutlet UILabel * newconnectorLabel;
@property (weak, nonatomic) IBOutlet UIButton *newph_hereButton;
@property (weak, nonatomic) IBOutlet UIButton *newconnector_hereButton;



-(IBAction)newph_hereButton_clicked:(id)sender;
-(IBAction)newconnector_hereButton_clicked:(id)sender;
@end

@implementation LoginViewController

#pragma mark -
#pragma mark Init / Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self setupTerms_Condition];
    [_view_newPhoneNum setHidden:YES];
    //configure UI
  //  [self.wheelButton setHidden:YES];
    [self.backButton addTarget:self
                        action:@selector(back:)
              forControlEvents:UIControlEventTouchUpInside];
    self.phoneNumber.layer.borderWidth = 1.0f;
    self.phoneNumber.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_selectContryCode.layer.borderWidth = 1.0f;

    self.btn_selectContryCode.layer.borderColor = [UIColor lightGrayColor].CGColor;

    
    [self.menuButton setHidden:YES];
    [[UIUtils singleton]configureField:self.phoneNumber withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"phone", nil)];
     [self.phoneNumber setKeyboardType:UIKeyboardTypePhonePad];
    
    
    
    
    
    self.phoneNumber.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
    [[UIUtils singleton]configureButton:self.loginButton withSyle:@"normal" size:24 andTitle:LocalizedString(@"next", nil)];
      [[UIUtils singleton]configureButton:self.newph_hereButton withSyle:@"bold" size:17.0f andTitle:LocalizedString(@"here", nil)];
      [[UIUtils singleton]configureButton:self.newconnector_hereButton withSyle:@"bold" size:17.0f andTitle:LocalizedString(@"here", nil)];
    
    [[UIUtils singleton]configureButton:self.btn_selectContryCode withSyle:@"normal" size:17.0f andTitle:LocalizedString(@"+32", nil)];
    

    [[UIUtils singleton] configureLabel:self.titleLabel withSyle:@"bold" size:45 color:[UIColor bleuColor] andText:LocalizedString(@"hello", nil)];
        [[UIUtils singleton] configureLabel:self.newphNoLabel withSyle:@"normal" size:17 color:[UIColor grayColor] andText:LocalizedString(@"new_phone_number_update", nil)];
        [[UIUtils singleton] configureLabel:self.newconnectorLabel withSyle:@"normal" size:17 color:[UIColor grayColor] andText:LocalizedString(@"new_connector_update", nil)];
    [[UIUtils singleton]configureButton:_updatePhButton withSyle:@"bold" size:14 andTitle:LocalizedString(@"update", nil)];
      [[UIUtils singleton]configureButton:_cancelButton withSyle:@"bold" size:14 andTitle:LocalizedString(@"cancel", nil)];
    [[UIUtils singleton]configureField:_txt_newPhoneNum withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"Enter New Phone Number", nil)];
    [[UIUtils singleton]configureField:_txt_oldPhoneNum withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"Enter Old Phone Number", nil)];
    
    [self.txt_newPhoneNum setKeyboardType:UIKeyboardTypePhonePad];
    [self.txt_oldPhoneNum setKeyboardType:UIKeyboardTypePhonePad];
    
    

    
    

    
    
    


    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
  
    [_newph_hereButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [_newconnector_hereButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    [_newph_hereButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [_newconnector_hereButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    _view_newPhoneNum.layer.borderColor = [[UIColor grayColor]CGColor];
    _view_newPhoneNum.layer.borderWidth=1.0;

    
      [_view_termsCondition setHidden:YES];
    
}
-(void)dismissKeyboard
{
    [_phoneNumber resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UI Actions

-(void)back:(id )sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL )textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
  //  [self login:nil];
    return YES;
}

-(IBAction)login:(id)sender
{
    
    
    if(_phoneNumber.text.length<1)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
 
    if([_phoneNumber.text hasPrefix:@"+"]||[_phoneNumber.text hasPrefix:@"0"]) {
   
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_email", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];

        
        return;
    }




  
      [_view_termsCondition setHidden:NO];
    
}
-(void)sendAccountData{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *token = [[[NSUserDefaults standardUserDefaults]objectForKey:@"account"] objectForKey:@"token"];
    [payload setObject:token forKey:@"token"];
    NSString *firstName = [[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"first_name"];
    [payload setObject:firstName forKey:@"first_name"];
    NSString *lasttName = [[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"last_name"];
    [payload setObject:lasttName forKey:@"last_name"];
    
    NSString *email = [[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"email"];
    [payload setObject:email forKey:@"email"];
    NSString *phone_number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"phone_number"];
    [payload setObject:phone_number forKey:@"phone_number"];
    
    [payload setObject:[[Localization singleton]languageString].uppercaseString  forKey:@"lang"];
    [payload setObject:[self getModel] forKey:@"phone_model"];
    [payload setObject:[UIDevice currentDevice].name forKey:@"phone_name"];
    
    @try {
        if([[FIRInstanceID instanceID] token]) {
            [payload setObject:[[FIRInstanceID instanceID] token] forKey:@"gcm_token"];
        }
    } @catch (NSException *exception) {
        NSLog(@"firebase token error");
    } @finally {
        
    }
    
    
    [[Localization singleton] setLanguage: [[Localization singleton]languageString]];
    [[UDOperator singleton]postAccount:payload
                   withCompletionBlock:^(id response) {
                       
                       
                   }];
 }

- (NSString *)getModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *deviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return deviceModel;
}


-(IBAction)newph_hereButton_clicked:(id)sender{
    
    
    [_view_newPhoneNum setHidden:NO];

     [_txt_oldPhoneNum becomeFirstResponder];
    
    
}
-(IBAction)newconnector_hereButton_clicked:(id)sender{
    
    QRCodeScanner *qrcode = [self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeScanner"];
  //  [[SlideNavigationController sharedInstance] pushViewController:qrcode animated:YES];
    
    
    

}

-(IBAction)btn_updatePhNum:(id)sender{
    
    
    if(_txt_oldPhoneNum.text.length<1||_txt_newPhoneNum.text.length<1)
    {
        
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        
        return;
        
        
    }

    
    if(![_txt_oldPhoneNum.text hasPrefix:@"+"]||[_txt_oldPhoneNum.text hasPrefix:@"0"]||![_txt_newPhoneNum.text hasPrefix:@"+"]||[_txt_newPhoneNum.text hasPrefix:@"0"]) {
        
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_phone", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        
        
        return;
    }
    
    
    
    NSMutableDictionary *payload=[[NSMutableDictionary alloc] init];
    payload=[[NSMutableDictionary alloc] init];
    [payload setObject:_txt_oldPhoneNum.text forKey:@"phone_number_old"];
    [payload setObject:_txt_newPhoneNum.text forKey:@"phone_number"];
    [payload setObject: [[Localization singleton]languageString].uppercaseString  forKey:@"lang"];
    
    
    
    
    
    
    NSLog(@"myphonepayload=%@",payload);
    
    [[UDOperator singleton]updatePhoneNumber:payload withCompletionBlock:^(id response) {
        
        
        NSLog(@"myresponseqrcode=%@",response);
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        
        
        if(response && [response isKindOfClass:[NSNumber class]]){
            long status = [response longValue ];
            
            NSLog(@"mystatus = %li",status);
            if(status==200){
                
                
                
                
                [[NSUserDefaults standardUserDefaults] setObject:_txt_newPhoneNum.text forKey:@"temp_phone_number"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                
                
                
                ConfirmPhoneNumber *confirmController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmPhoneNumber"];
                
                
                confirmController.isupdate=true;
                confirmController.phone_number=_txt_newPhoneNum.text;
                [[SlideNavigationController sharedInstance] pushViewController:confirmController animated:YES];
                
                
            }else if(status == 404){
                //show sorry screen
                
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:LocalizedString(@"error", nil) message:LocalizedString(@"server_error", nil) delegate:self cancelButtonTitle:LocalizedString(@"ok", nil) otherButtonTitles:nil];
                [alert show];
                
                
            }else if(status == 401){
                // not register yet
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:LocalizedString(@"error", nil)
                                                            message:LocalizedString(@"error", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
                
            }
            else if(status == 403){
                // device already register
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:LocalizedString(@"error", nil)
                                                            message:LocalizedString(@"error", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
                
            }
            else if(status == 403){
                // server error
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:LocalizedString(@"error", nil)
                                                            message:LocalizedString(@"error", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
                
            }
            else if(status == 500){
                
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:LocalizedString(@"error", nil)
                                                            message:LocalizedString(@"number_already_exist", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
                
            }
            
            else{
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                            message:LocalizedString(@"error", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
                
            }
            
        }else{
            //error
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:LocalizedString(@"error", nil) message:LocalizedString(@"error", nil) delegate:self cancelButtonTitle:LocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
            [av show];
        }
    }];
    
    
    
    //updatePhonenumber
    [_view_newPhoneNum setHidden:YES];
    
    
    
    
    
    
    
    
}
-(IBAction)btn_cancel_clicked:(id)sender{
    
    [_view_newPhoneNum setHidden:YES];
    
    [_txt_oldPhoneNum resignFirstResponder];
    [_txt_newPhoneNum resignFirstResponder];
    
    
    
}

- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
   
   }


-(IBAction)btn_selectContryCode:(id)sender{

    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:NULL];
}

- (void)didSelectCountry:(NSDictionary *)country
{
    NSLog(@"%@", country);
  [self.btn_selectContryCode setTitle:[country valueForKey:@"dial_code"] forState:UIControlStateNormal];
}


-(void)fetchProfiledata:(NSString *)phone_number{
    
    
    
    
    NSString *phonenum=[NSString stringWithFormat:@"%@%@",self.btn_selectContryCode.titleLabel.text,self.phoneNumber.text];
    NSMutableDictionary *payload = [NSMutableDictionary new];
  [payload setObject:phonenum forKey:@"phone_number"];
  
 // [payload setObject:@"923335469641" forKey:@"phone_number"];

    
    NSLog(@"mypayload=%@",payload);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UDOperator singleton]fetchProfile:payload withCompletionBlock:^(id response) {
        
       
        
         NSLog(@"my response = %@",response);
        
        
        
        if(response && [response isKindOfClass:[NSDictionary class]]){
            //NSLog(@" login response %@",rez);
            //let user in app
            
            
            
            NSMutableDictionary *rez = [response mutableCopy];
            NSArray * x = [response allKeys];
            for (NSString *key in x)
            {
                //Remove all the "nul" value in order to save the account in the NSUserDefault
                if([rez objectForKey:key] == (id)[NSNull null]){
                    [rez setValue:nil forKey:key];
                }
            }
            //NSLog(@" login response %@",rez);
            //let user in app
            [[NSUserDefaults standardUserDefaults]setObject:rez forKey:@"account"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            
            [[DatabaseManager sharedInstance] insertALLRides:[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"scores"]];
            
            
            MainViewController *main = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            [[SlideNavigationController sharedInstance] pushViewController:main animated:YES];
        }
        
        
        
        
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        
        
    } ];
    
    
    
    
}

-(IBAction)btn_accept_clicked:(id)sender{
    
    [_view_termsCondition setHidden:YES];
    
    
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *phonenum=[NSString stringWithFormat:@"%@%@",self.btn_selectContryCode.titleLabel.text,self.phoneNumber.text];
    
    
    [payload setObject:phonenum forKey:@"phone_number"];
    // [payload setObject:@"923335469641" forKey:@"phone_number"];
    //use Keychain to persist the device ID
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
    
    
    
    [payload setObject:deviceId forKey:@"device_id"];
    
    @try {
        if([[FIRInstanceID instanceID] token]) {
            [payload setObject:[[FIRInstanceID instanceID] token] forKey:@"gcm_token"];
        }
    } @catch (NSException *exception) {
        NSLog(@"firebase token error");
    } @finally {
        
    }
    
    
    
    
    NSLog(@"mypayloadlogin=%@",payload);
    
    
    
    
    NSString *str=[NSString stringWithFormat:@"%@ , %@", deviceId,self.phoneNumber.text ];
    
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                message:str
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                      otherButtonTitles:nil, nil];
    //  [av show];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UDOperator singleton]postLogin:payload withCompletionBlock:^(id response) {
        NSLog(@"myresponse=%@",response);
        
        
        
        /*   if(response && [response isKindOfClass:[NSDictionary class]]){
         NSMutableDictionary *rez = [response mutableCopy];
         NSArray * x = [response allKeys];
         for (NSString *key in x)
         {
         //Remove all the "nul" value in order to save the account in the NSUserDefault
         if([rez objectForKey:key] == (id)[NSNull null]){
         [rez setValue:nil forKey:key];
         }
         }
         //NSLog(@" login response %@",rez);
         //let user in app
         
         
         //if number not 409 (to sms) // to verify number
         //uuid exst not 405 (to qrcode)
         //else goto menu
         
         
         
         }else */
        
        if(response && [response isKindOfClass:[NSNumber class]]){
            long status = [response longValue ];
            if(status == 200  ){
                ///auth token will recive
                
                
                
                
                [self fetchProfiledata:self.phoneNumber.text];
                
                
            }
            else if(status == 404){
                //show sorry screen
                
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:LocalizedString(@"error", nil) message:LocalizedString(@"server_error", nil)delegate:self cancelButtonTitle:LocalizedString(@"ok", nil) otherButtonTitles: nil];
                [alert show];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                
            }
            
            else if(status == 405){
                //show sorry screen
                
                
                QRCodeScanner *qrcode = [self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeScanner"];
                
                
                NSString *phonenum=[NSString stringWithFormat:@"%@%@",self.btn_selectContryCode.titleLabel.text,self.phoneNumber.text];
                //  [payload setObject:phonenum forKey:@"phone_number"];
                
                
                
                
                qrcode.phone_number=phonenum;
                [[SlideNavigationController sharedInstance] pushViewController:qrcode animated:YES];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                
                
                
            }
            else if(status == 403){
                
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                            message:LocalizedString(@"device_already_registered", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
            }
            
            
            
            
            
            
            else if(status == 409){
                
                // number is not verifed goto sms confirmation
                ConfirmPhoneNumber *confirmController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmPhoneNumber"];
                
                NSString *phonenum=[NSString stringWithFormat:@"%@%@",self.btn_selectContryCode.titleLabel.text,self.phoneNumber.text];
                [payload setObject:phonenum forKey:@"phone_number"];
                confirmController.phone_number=phonenum;
                [[SlideNavigationController sharedInstance] pushViewController:confirmController animated:YES];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
            
            else if(status == 401){
                
                
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                            message:LocalizedString(@"not_registered", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                
            }
            
            else{
                //error
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                            message:LocalizedString(@"error", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
        }
    }];

    
    
    
    
}


-(void)setupTerms_Condition{
    
    [[UIUtils singleton]configureLabel:_lbl_terms_title withSyle:@"bold" size:22.0f color:[UIColor bleuColor] andText:LocalizedString(@"terms_title", nil)];
    
    
    [[UIUtils singleton]configureLabel:_lbl_termas_detail withSyle:@"bold" size:18 color:[UIColor lightGrayColor] andText:LocalizedString(@"terms_detail", nil)];
    
    
    
    [_lbl_termas_detail sizeToFit];
    UIFontDescriptor *userHeadLineFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    CGFloat userHeadLineFontSize = [userHeadLineFont pointSize];
    
    NSDictionary *attributes = @{NSFontAttributeName:  [UIFont fontWithName:@"DINNextLTPro-MediumCond" size:userHeadLineFontSize]};
    
    _lbl_privacyPolicy.attributedText = [[NSAttributedString alloc]initWithString:LocalizedString(@"privacy_policy_title", nil) attributes:attributes];
    
    [_lbl_privacyPolicy setLinkForSubstring:LocalizedString(@"privacy_policy_title", nil) withLinkHandler:^(FRHyperLabel *label, NSString *substring){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.freeedrive.com"]];
    }];
    
    [[UIUtils singleton]configureButton:_btn_accept withSyle:@"bold" size:17.0f andTitle:LocalizedString(@"accept_terms_title", nil)];
    
}



@end
