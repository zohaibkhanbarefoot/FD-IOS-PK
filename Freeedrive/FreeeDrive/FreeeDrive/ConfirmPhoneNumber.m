//
//  ConfirmPhoneNumber.m
//  EddystoneScannerSample
//
//  Created by user on 30/12/2016.
//
//

#import "ConfirmPhoneNumber.h"
#import "QRCodeScanner.h"
#import "SlideNavigationController.h"
#import "UDOperator.h"
#import "MBProgressHUD.h"
#import "UICKeychainStore.h"
#import "MainViewController.h"
#import "iBeaconManager.h"
#import "DatabaseManager.h"
@import FirebaseInstanceID;
@interface ConfirmPhoneNumber ()


@end

@implementation ConfirmPhoneNumber

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self.menuButton setHidden:YES];
    self.confirmTextField.layer.borderWidth = 1.0f;
    self.confirmTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [[UIUtils singleton]configureField:self.confirmTextField withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"****", nil)];
    self.confirmTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
    
    
    NSString *str_completetitle=LocalizedString(@"complete_the", nil);
    NSString *str_digitcode=LocalizedString(@"4_digit_code", nil);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@" ,str_completetitle,str_digitcode]];
    NSRange boldedRange = NSMakeRange(str_completetitle.length+1, str_digitcode.length);
    UIFont *fontText = [UIFont fontWithName:@"DINNextLTPro-MediumCond" size:21];
    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
    [string setAttributes:dictBoldText range:boldedRange];

    
    self.firstTitleLabel.attributedText=string;
    

    [self.firstTitleLabel setTextColor:[UIColor bleuColor]];

   // [[UIUtils singleton] configureLabel:self.firstTitleLabel withSyle:@"bold" size:21 color:[UIColor bleuColor] andText:LocalizedString(string, nil) ];
     [[UIUtils singleton] configureLabel:self.secTitleLabel withSyle:@"normal" size:21 color:[UIColor bleuColor] andText:LocalizedString(@"you_received_by_sms", nil) ];
     [[UIUtils singleton] configureLabel:self.confirmMessLabel withSyle:@"normal_center" size:17 color:[UIColor grayColor] andText:LocalizedString(@"havnt_recieved_the_sms", nil) ];
    
       [[UIUtils singleton] configureButton:self.nextButton withSyle:@"normal" size:24 andTitle:LocalizedString(@"next", nil)];
        [[UIUtils singleton] configureButton:self.sendAgainButton withSyle:@"normal" size:17 andTitle:LocalizedString(@"send_again", nil)];
    [self.confirmTextField setKeyboardType:UIKeyboardTypePhonePad];
    
    
    [self.backButton setHidden:NO];
    

    
    [self.menuButton setHidden:YES];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventAllTouchEvents];

    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    
    
    
}
-(void)dismissKeyboard
{
    [_confirmTextField resignFirstResponder];
}
-(void)back{

    [self.navigationController popViewControllerAnimated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)nextButtonClicked:(id)sender{

    
    
    if(self.confirmTextField.text.length<4){
    
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"code_length_invalid", nil) delegate:self cancelButtonTitle:LocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
        [av show];

    
    
    }
    
    
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
     [payload setObject:self.phone_number forKey:@"phone_number"];
    // [payload setObject:@"923335469641" forKey:@"phone_number"];
    
    
    
    [payload setObject:self.confirmTextField.text forKey:@"sms_code"];
    
     NSLog(@"mypayload=%@",payload);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UDOperator singleton]postSmsVerification:payload withCompletionBlock:^(id response) {
        
        
        NSLog(@"myresponse_confirm=%@",response);
        
        
       // [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
       if(response && [response isKindOfClass:[NSNumber class]]){
            long status = [response longValue ];
           
              if( status == 200 ){
               
            //auth token recienve
                  
                  
                  
                  
                  
                
                  [self fetchProfiledata:self.phone_number];
                  
                  
                  
                  
               
               
           }
           

           
           else if( status == 404||status == 405  ){
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"code_expired", nil) delegate:self cancelButtonTitle:LocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
                [av show];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
               
               
               
                
                
            }
           
           
        
         else   if( status == 403 ){
        
             
        QRCodeScanner *qrcode = [self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeScanner"];
        qrcode.phone_number=self.phone_number;
        [[SlideNavigationController sharedInstance] pushViewController:qrcode animated:YES];
              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
             
            
             
             

        }
        else   if( status == 500 ){
            // UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"Code Expired", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
            //   [av show];
            
            
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"server_error", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
            [av show];
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            
            
        }

        else   if( status == 409 ){
            // UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"Code Expired", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
            //   [av show];
            
            
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"invalid_code", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
            [av show];
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            
            
        }
        else{
        
        
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        
        }

        
           
          
     
        }
    }];
    
    
    
    
    

}
-(IBAction)sendAgainButtonClicked:(id)sender{


    NSMutableDictionary *payload = [NSMutableDictionary new];
    
    
    if(_isupdate){
        [payload setObject:self.phone_number forKey:@"phone_number"];
        
    }
    else
        [payload setObject:self.phone_number forKey:@"phone_number"];
    
    
   
    
    NSLog(@"mypayload=%@",payload);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UDOperator singleton]postResendCode:payload withCompletionBlock:^(id response) {
        
        
        NSLog(@"myresponse_confirm=%@",response);
        
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if(response && [response isKindOfClass:[NSNumber class]]){
            long status = [response longValue ];
         
            }
        
        
        
        
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"resend_smscode", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
        [av show];
        
        
        
        
            
            
            
        
            
            
            
            
        
    }];

}
-(BOOL )textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



-(void)fetchProfiledata:(NSString *)phone_number{
    
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:phone_number forKey:@"phone_number"];
       NSLog(@"mypayload=%@",payload);
    
    [[UDOperator singleton]fetchProfile:payload withCompletionBlock:^(id response) {
        
        
        // NSLog(@"my response = %@",response);
        
        
        
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
        
        
        else{
        
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                        message:LocalizedString(@"no_internet", nil)
                                                       delegate:self
                                              cancelButtonTitle:LocalizedString(@"ok", nil)
                                              otherButtonTitles:nil, nil];
            
            
            [av show];
        }
        
        
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        
        
    } ];
    
    
    
    
}


@end
