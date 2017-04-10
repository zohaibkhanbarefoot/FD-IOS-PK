//
//  Contactus.m
//  EddystoneScannerSample
//
//  Created by user on 5/01/2017.
//
//

#import "Contactus.h"
#import "UIUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "Localization.h"
#import "UDOperator.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"
@interface Contactus ()

@end

@implementation Contactus

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIUtils singleton] configureLabel:self.lbl_title withSyle:@"textcenter" size:21 color:[UIColor bleuColor] andText:LocalizedString(@"rate", nil) ];
    [self.menuButton setHidden:YES];
    
    [[UIUtils singleton] configureButton:self.btn_send withSyle:@"normal" size:21 andTitle:LocalizedString(@"send", nil)];
    
    _txtView_message.text=@"Message";
    

_txtView_message.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    [[self.txtView_message layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.txtView_message layer] setBorderWidth:1];
    [[self.txtView_message layer] setCornerRadius:1];
    
    [self.backButton addTarget:self action:@selector(btn_back_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
  
    
}
-(void)dismissKeyboard
{
    [_txtView_message resignFirstResponder];
}

-(void)btn_back_clicked{

   
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        if ([controller isKindOfClass:[MainViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }

    
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(IBAction)btn_send_clicked:(id)sender{
    if([self.txtView_message.text length] == 0 || [self.txtView_message.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0||[self.txtView_message.text isEqualToString:@"Message"])
        {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                        message:LocalizedString(@"rate_invalid", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil, nil];
            [av show];
            return;
        }
        NSMutableDictionary *payload = [NSMutableDictionary new];
   // NSString *auth = [[NSUserDefaults standardUserDefaults]  valueForKey:@"auth"];

       // [payload setObject:auth forKey:@"Authorization"];
    [payload setObject:self.txtView_message.text forKey:@"message"];
    //[payload setObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"phone_number"] forKey:@"phone_number"];

    
    NSLog(@"payload= %@",payload);
    

    
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[UDOperator singleton]postRateUs:payload withCompletionBlock:^(id response){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if(response && [response isKindOfClass:[NSNumber class]]){
                long status = [response longValue ];
                if(status == 200){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:LocalizedString(@"feedback_ok", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(NSLocalizedString(@"ok", nil), nil)
                                                          otherButtonTitles:nil];
                    [alert show];
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    NSString *error = [response objectForKey:@"error"];
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                                message:error
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(NSLocalizedString(@"ok", nil), nil)
                                                      otherButtonTitles:nil, nil];
                    [av show];
                }
            }
        }];
    
    
   
}
-(IBAction)btn_cross_clicked:(id)sender{


}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
      return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"calling begin");
    if ([textView.text isEqualToString:@"Message"]) {
        textView.text = @"";
        UIColor *color=[UIColor colorWithRed:((float) 70 / 255.0f)
                                       green:((float) 26 / 255.0f)
                                        blue:((float) 93 / 255.0f)
                                       alpha:1.0f];
       // textView.textColor = color;//optional
    }
      [textView becomeFirstResponder];
 
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
   
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Message";
       // textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}
@end
