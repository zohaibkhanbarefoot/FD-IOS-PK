//
//  MTBViewController.m
//  MTBBarcodeScannerExample
//
//  Created by Mike Buss on 2/8/14.
//
//

#import "QRCodeScanner.h"
#import "MTBBarcodeScanner.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "UDOperator.h"
#import "iBeaconManager.h"
#import "MainViewController.h"
#import "DatabaseManager.h"
@interface QRCodeScanner () <UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *toggleScanningButton;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *toggleTorchButton;

@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
@property (nonatomic, assign) BOOL captureIsFrozen;
@property (nonatomic, assign) BOOL didShowCaptureWarning;

@end

@implementation QRCodeScanner

#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped)];
    [self.previewView addGestureRecognizer:tapGesture];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.scanner stopScanning];
    [super viewWillDisappear:animated];
}

-(void)viewDidLoad{

    
    [super viewDidLoad];
    
    
    /*
     
     "scan_the"= "Veuillez scanner le";
     "qr_code_placed"="code QR";
     "on_the_back_of_your_beacon"="au dos de votre connecteur";
     "scan"="SCANNER";
     */
    
    
    NSString *str_scan= LocalizedString(@"scan_the", nil);
    NSString *str_qrcodeplaced=  LocalizedString(@"qr_code_placed", nil);
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",str_scan,str_qrcodeplaced]];
    NSRange boldedRange = NSMakeRange(str_scan.length+1, str_qrcodeplaced.length);
    UIFont *fontText = [UIFont fontWithName:@"DINNextLTPro-MediumCond" size:17];
    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
    [string setAttributes:dictBoldText range:boldedRange];
    
    
   self.firstTitleLabel.attributedText=string;
    
    
    [self.firstTitleLabel setTextColor:[UIColor bleuColor]];

   // [[UIUtils singleton] configureLabel:self.firstTitleLabel withSyle:@"bold" size:17 color:[UIColor bleuColor] andText:LocalizedString(@"", nil) ];
    [[UIUtils singleton] configureLabel:self.secTitleLabel withSyle:@"normal" size:20 color:[UIColor bleuColor] andText:LocalizedString(@"on_the_back_of_your_beacon", nil) ];
    [[UIUtils singleton]configureButton:self.nextButton withSyle:@"normal" size:24.0f andTitle:LocalizedString(@"scan", nil)];

 [self.menuButton setHidden:YES];
    [self.backButton addTarget:self
                        action:@selector(back:)
              forControlEvents:UIControlEventTouchUpInside];
}
-(void)back:(id)sender{

    [self.navigationController popViewControllerAnimated:YES];

}
#pragma mark - Scanner

- (MTBBarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_previewView];
    }
    return _scanner;
}
//09edc26d-80cc-493c-b8f5-9cd035c46c28
#pragma mark - Scanning

- (void)startScanning {
    self.uniqueCodes = [[NSMutableArray alloc] init];
    
    NSError *error = nil;
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if (code.stringValue && [self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
             //   [self.uniqueCodes addObject:code.stringValue];
             // NSLog(@"Found unique code: %@", code.stringValue);
                
                NSString *qrcodeVal=code.stringValue;
                qrcodeVal = [qrcodeVal stringByReplacingOccurrencesOfString:@"-"
                                                     withString:@""];
                
                
                
                NSLog(@"qrcodeval=%@",qrcodeVal);
                
                
               [self postQrCode:qrcodeVal];
            
            
            }
        }
    } error:&error];
    
    if (error) {
        NSLog(@"An error occurred: %@", error.localizedDescription);
    }
    
   // [self.toggleScanningButton setTitle:@"Stop Scanning" forState:UIControlStateNormal];
   // self.toggleScanningButton.backgroundColor = [UIColor redColor];
}

- (void)stopScanning {
    [self.scanner stopScanning];
    
    //[self.toggleScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
  //  self.toggleScanningButton.backgroundColor = self.view.tintColor;
    
    self.captureIsFrozen = NO;
}

#pragma mark - Actions

- (IBAction)toggleScanningTapped:(id)sender {
    if ([self.scanner isScanning] || self.captureIsFrozen) {
        [self stopScanning];
        self.toggleTorchButton.title = @"Enable Torch";
    } else {
        [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
            if (success) {
                [self startScanning];
            } else {
                [self displayPermissionMissingAlert];
            }
        }];
    }
/*
 MainViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
[[SlideNavigationController sharedInstance] pushViewController:loginController animated:YES];
 */



}

- (IBAction)switchCameraTapped:(id)sender {
    [self.scanner flipCamera];
}
- (IBAction)toggleTorchTapped:(id)sender {
    if (self.scanner.torchMode == MTBTorchModeOff || self.scanner.torchMode == MTBTorchModeAuto) {
        self.scanner.torchMode = MTBTorchModeOn;
        self.toggleTorchButton.title = @"Disable Torch";
    } else {
        self.scanner.torchMode = MTBTorchModeOff;
        self.toggleTorchButton.title = @"Enable Torch";
    }
}

- (void)backTapped {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Helper Methods

- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = LocalizedString(@"permission_denied_camera", nil) ;
    } else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = LocalizedString(@"permission_denied_camera", nil) ;
    } else {
        message = LocalizedString(@"error", nil);
    }
    
    [[[UIAlertView alloc] initWithTitle:LocalizedString(@"error", nil)
                                message:message
                               delegate:nil
                      cancelButtonTitle:LocalizedString(@"ok", nil)
                      otherButtonTitles:nil] show];
}

#pragma mark - Gesture Handlers

- (void)previewTapped {
    if (![self.scanner isScanning] && !self.captureIsFrozen) {
        return;
    }
    
    if (!self.didShowCaptureWarning) {
        [[[UIAlertView alloc] initWithTitle:LocalizedString(@"error", nil)
                                    message:LocalizedString(@"error", nil)
                                   delegate:nil
                          cancelButtonTitle:LocalizedString(@"ok", nil)
                          otherButtonTitles:nil] show];
        
        
        //if number not 409 (to sms) // to verify number
        //uuid exst not 405 (to qrcode)
        //else goto menu
        self.didShowCaptureWarning = YES;
    }
    
    if (self.captureIsFrozen) {
        [self.scanner unfreezeCapture];
    } else {
        [self.scanner freezeCapture];
    }
    
    self.captureIsFrozen = !self.captureIsFrozen;
}

#pragma mark - Setters

- (void)setUniqueCodes:(NSMutableArray *)uniqueCodes {
    _uniqueCodes = uniqueCodes;
 
}


-(void)postQrCode:(NSString *)uuid{
    
    
    
    
    
 
    
    
    
    [_scanner stopScanning];

    
    if(uuid.length!=32){
    
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_uuid", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];

        return ;
    }
    
  
    NSMutableDictionary *payload = [NSMutableDictionary new];

    
  
    [payload setObject:self.phone_number forKey:@"phone_number"];
    
   // [payload setObject:@"923335469641" forKey:@"phone_number"];
    [payload setObject:uuid forKey:@"uuid"];
    
    
    
    if(self.phone_number.length<1)
    {
    
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_phone", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;

    
    }
    
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    [[UDOperator singleton]postQrcode:payload withCompletionBlock:^(id response) {
        
        
        NSLog(@"myresponseqrcode=%@",response);
        
  
        
        if(response && [response isKindOfClass:[NSNumber class]]){
            long status = [response longValue ];
            
            
            if(status==200){
                
                
                
                [self fetchProfiledata:self.phone_number];
                //qrcode recieve
                

            
            
            }
         
            
            
            else{
            /*
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                            message:LocalizedString(@"error_networkCallFailure", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
            
                
             //   [av show];
            */
            
            
               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            }
            
        }
    }];
    
    



}



-(void)fetchProfiledata:(NSString *)phone_number{
    
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
  [payload setObject:phone_number forKey:@"phone_number"];
   
//[payload setObject:@"923335469641" forKey:@"phone_number"];

    
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
            [[iBeaconManager sharedInstance] stopLocation];
            [[iBeaconManager sharedInstance] startLocation];
            [[DatabaseManager sharedInstance] insertALLRides:[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"scores"]];
            MainViewController *main = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            [[SlideNavigationController sharedInstance] pushViewController:main animated:YES];
            
            
            
            
        }
        else{
      /*      UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                        message:LocalizedString(@"error_networkCallFailure", nil)
                                                       delegate:self
                                              cancelButtonTitle:LocalizedString(@"ok", nil)
                                              otherButtonTitles:nil, nil];
            
            
       //     [av show];*/
            }
        
           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
      
        
        
        
    } ];
    
    
    
    
}
@end
