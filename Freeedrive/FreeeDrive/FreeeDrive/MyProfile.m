//
//  SignupViewController.m
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "MyProfile.h"
#import "UDOperator.h"
#import "MBProgressHUD.h"
#import "UICKeychainStore.h"
#import "FieldCell.h"
#import "AppDelegate.h"
#import "QRCodeScanner.h"
#import "ConfirmPhoneNumber.h"
#import "UIButton+Extensions.h"
@import Firebase;
#include <sys/sysctl.h>

@interface MyProfile ()
{
    NSString *temp_language;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView, *languagesTableView; //*functionsTableView, *departmentsTableView, //*worksitesTableView;
@property (strong, nonatomic) NSMutableArray *languagesArray, *functionsArray; //*departmentsArray, *worksitesArray;
@property (strong, nonatomic) NSDictionary *function, *department, *worksite, *account;
@property (nonatomic) CGFloat lastCellHeight;
@property (weak, nonatomic) IBOutlet FieldCell *firstnameCell, *lastnameCell, /**addressCell ,*/ *emailCell, *phoneCell;
@property (strong, nonatomic) UITextField *currentField;

@end

@implementation MyProfile

#pragma mark -
#pragma mark Init / Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    temp_language=[[Localization singleton]languageString];
  /*  if([[[Localization singleton]languageString]isEqualToString:@"en"])
        temp_language = LocalizedString(@"english", nil);
    if([[[Localization singleton]languageString]isEqualToString:@"fr"])
        temp_language = LocalizedString(@"french", nil);
    if([[[Localization singleton]languageString]isEqualToString:@"nl"])
        temp_language = LocalizedString(@"dutch", nil);
    */
    [self.menuButton setHidden:YES];
    
     [_view_newPhoneNum setHidden:YES];
    self.lastCellHeight = 200.0f;
  //  [self fetchProfiledata];
    //configure UI
    //  [self.wheelButton setHidden:YES];
    [self.backButton addTarget:self
                        action:@selector(back:)
              forControlEvents:UIControlEventTouchUpInside];
    self.accountMode=true;
    
    
    self.account=[[NSMutableDictionary alloc] init];
    
    
    self.account =[[NSUserDefaults standardUserDefaults] valueForKey:@"account"];
    

    [_newph_hereButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [_newconnector_hereButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    _view_newPhoneNum.layer.borderColor = [[UIColor grayColor]CGColor];
    _view_newPhoneNum.layer.borderWidth=1.0;
    
    
    [self.txt_newPhoneNum setKeyboardType:UIKeyboardTypePhonePad];
    [self.txt_oldPhoneNum setKeyboardType:UIKeyboardTypePhonePad];
    
    


  
}
-(void)setupView{


    
    [[UIUtils singleton] configureLabel:self.newphNoLabel withSyle:@"normal" size:17 color:[UIColor grayColor] andText:LocalizedString(@"new_phone_number_update", nil)];
    [[UIUtils singleton] configureLabel:self.newconnectorLabel withSyle:@"normal" size:17 color:[UIColor grayColor] andText:LocalizedString(@"new_connector_update", nil)];
    
    
    [[UIUtils singleton]configureButton:self.newph_hereButton withSyle:@"bold" size:17.0f andTitle:LocalizedString(@"here", nil)];
    [[UIUtils singleton]configureButton:self.newconnector_hereButton withSyle:@"bold" size:17.0f andTitle:LocalizedString(@"here", nil)];
    
    
    [[UIUtils singleton]configureField:_txt_newPhoneNum withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"Enter New Phone Number", nil)];
    [[UIUtils singleton]configureField:_txt_oldPhoneNum withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"Enter Old Phone Number", nil)];
    
    [[UIUtils singleton]configureButton:_updatePhButton withSyle:@"bold" size:14 andTitle:LocalizedString(@"Save", nil)];
    [[UIUtils singleton]configureButton:_cancelButton withSyle:@"bold" size:14 andTitle:LocalizedString(@"cancel", nil)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UI Actions

-(void)resignAll:(UIGestureRecognizer *)sender
{
    for(int i=0;i<11;i++)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:ip];
        for(UIView *v in cell.contentView.subviews)
        {
            if([v isKindOfClass:[UITextField class]])
            {
                UITextField *tf = (UITextField *)v;
                [tf resignFirstResponder];
            }
        }
    }
}

-(void)back:(id )sender
{
   
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        if ([controller isKindOfClass:[MainViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }


}

-(BOOL )textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range  replacementString:(NSString *)string
{
    int setrange = 100;
    return !([textField.text length]>setrange && [string length] > range.length);
}


-(void)showLanguageMenu:(UIGestureRecognizer *)sender
{
    if(self.languagesTableView)
        return;
    
    [self.currentField resignFirstResponder];
    self.languagesArray = [NSMutableArray new];
    [self.languagesArray addObject:LocalizedString(@"english", nil)];
    [self.languagesArray addObject:LocalizedString(@"french", nil)];
    [self.languagesArray addObject:LocalizedString(@"dutch", nil)];
    [self.languagesArray addObject:LocalizedString(@"spanish", nil)];
    self.languagesTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.languagesTableView setDelegate:self];
    [self.languagesTableView setDataSource:self];
    CGRect frame = self.languagesTableView.frame;
    frame.origin.x = sender.view.frame.origin.x;
    frame.origin.y = 80 + sender.view.frame.size.height;
    frame.size.width = sender.view.frame.size.width;
    self.languagesTableView.frame = frame;
    self.languagesTableView.layer.borderWidth = 1.0f;
    self.languagesTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.languagesTableView.separatorColor = [UIColor whiteColor];
    [self.tableView addSubview:self.languagesTableView];
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:
     ^{
         CGRect frame = self.languagesTableView.frame;
         frame.size.height = 165.0f;        //3 languages
         self.languagesTableView.frame = frame;
     }
                     completion:^(BOOL finished){
                     }];
    
    
    
   // self.account=[[NSUserDefaults standardUserDefaults] valueForKey:@"account"];

    self.accountMode=YES;

}

-(void)showFunctionsMenu:(UIGestureRecognizer *)sender
{
}

-(void)showDepartmentsMenu:(UIGestureRecognizer *)sender
{
}

-(void)showWorksitesMenu:(UIGestureRecognizer *)sender
{
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setupView];
    
    if(self.accountMode) {
        [self getAccount];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)keyboardWillShow
{
    //self.lastCellHeight = 450.0f;
  //  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)keyboardWillHide
{
   // self.lastCellHeight = 200.0f;
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.currentField = textField;
    return YES;
}

#pragma mark -
#pragma mark API

-(void)getAccount
{
   
    self.firstnameCell = nil;
    self.lastnameCell = nil;
    self.emailCell = nil;
    self.phoneCell = nil;
    [self.tableView reloadData];
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

-(void)doUpdateAccount
{
    
    
    
    NSLog(@"myauth  =%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"auth"]);
    
    
    //validate firstname
    UITableViewCell *cell = self.firstnameCell;
    UITextField *firstnameField = (UITextField *) [cell.contentView viewWithTag:-1];
    if([firstnameField.text length] == 0 || [firstnameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
    //validate lastname
    cell = self.lastnameCell;
    UITextField *lastnameField = (UITextField *) [cell.contentView viewWithTag:-1];
    if([lastnameField.text length] == 0 || [lastnameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    //validate email
    cell = self.emailCell;
    UITextField *emailField = (UITextField *) [cell.contentView viewWithTag:-1];
    //validate phone
    cell = self.phoneCell;
    UITextField *phoneField = (UITextField *) [cell.contentView viewWithTag:-1];
    if([phoneField.text length] == 0 || [phoneField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 )
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    if([phoneField.text rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_phone", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
        
    }
    
    //validate function, department, worksite
    /* if(!self.function || !self.department || !self.worksite)
     {
     UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
     message:LocalizedString(@"all_fields_mandatory", nil)
     delegate:self
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil, nil];
     [av show];
     return;
     }*/
    
    //call API
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:firstnameField.text forKey:@"first_name"];
    [payload setObject:lastnameField.text forKey:@"last_name"];
    [payload setObject:emailField.text.lowercaseString forKey:@"email"];
    [payload setObject:phoneField.text forKey:@"phone_number"];
    [payload setObject:temp_language.uppercaseString  forKey:@"lang"];
    
     [payload setObject: [UIDevice currentDevice].systemVersion forKey:@"phone_os_version"];
    @try {
        if([[FIRInstanceID instanceID] token]) {
            [payload setObject:[[FIRInstanceID instanceID] token] forKey:@"gcm_token"];
        }
    } @catch (NSException *exception) {
        NSLog(@"firebase token error");
    } @finally {
        
    }
    [payload setObject:[self getModel] forKey:@"phone_model"];
    [payload setObject:[UIDevice currentDevice].name forKey:@"phone_name"];
    
    
    NSLog(@"payload = %@",payload);
    [[Localization singleton] setLanguage: [[Localization singleton]languageString]];
    [[UDOperator singleton]postAccount:payload
                   withCompletionBlock:^(id response)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         
         if(response){
             
             NSLog(@"update response = %@",response);
             
             if([response isKindOfClass:[NSDictionary class]]){
                 //ok
                 NSMutableDictionary *rez = [response mutableCopy];
                 NSArray * x = [response allKeys];
                 for (NSString *key in x)
                 {
                     //Remove all the "nul" value in order to save the account in the NSUserDefault
                     if([rez objectForKey:key] == (id)[NSNull null]){
                         [rez setValue:nil forKey:key];
                     }
                 }
                 //  NSLog(@" account updated : %@",response);
                 //let user in app
                // [rez setObject:[[NSUserDefaults standardUserDefaults]  objectForKey:@"token"] forKey:@"token"];
                 [rez setObject:[[Localization singleton]languageString] forKey:@"lang"];
                 
                 
                 
                 [[Localization singleton]setLanguage:temp_language];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"lang_changed_menu" object:nil];
                 [self setupView];
                 [_tableView reloadData];
                 
                 
                 
                 //NSLog(@" account update response %@",rez);
                 
                 [[NSUserDefaults standardUserDefaults]setObject:rez forKey:@"account"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"save_succeed", nil)
                                                            delegate:self
                                                   cancelButtonTitle:LocalizedString(@"ok", nil)
                                                   otherButtonTitles:nil, nil];
                 [av show];
                 
             }/*else{
                 //error
                 UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""  message:LocalizedString(@"error_networkCallFailure", nil)
                                                            delegate:self
                                                   cancelButtonTitle:LocalizedString(@"ok", nil)
                                                   otherButtonTitles:nil, nil];
                 [av show];
             }*/
             
         }/*else{
             //error
             UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""  message:LocalizedString(@"error_networkCallFailure", nil)
                                                        delegate:self
                                               cancelButtonTitle:LocalizedString(@"ok", nil)
                                               otherButtonTitles:nil, nil];
             [av show];
             
             
             
             
         }*/
     }];
}

#pragma mark -
#pragma mark UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == self.languagesTableView)
        return 4;
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(tableView == self.languagesTableView)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [[UIUtils singleton]configureLabel:cell.textLabel withSyle:@"normal" size:13.0f color:[UIColor whiteColor] andText:[self.languagesArray objectAtIndex:indexPath.row]];
        [cell.contentView setBackgroundColor:[UIColor bleuColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
    if(indexPath.row == 0)
    {
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"PersonalInformations"];
        
        UILabel *pi = (UILabel *) [cell.contentView viewWithTag:-1];
        [[UIUtils singleton]configureLabel:pi withSyle:@"textcenter" size:35 color:[UIColor bleuColor] andText:LocalizedString(@"my_profile", nil)];
        
        
    }
    else if(indexPath.row == 1)
    {
        
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"Top"];
        //hello labelfdids
        
        
        UIView *view_lang = (UILabel *) [cell.contentView viewWithTag:-3];
        view_lang.layer.borderWidth = 1.0f;
        view_lang.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        
        UILabel *hello = (UILabel *) [cell.contentView viewWithTag:-1];
         [[UIUtils singleton]configureLabel:hello withSyle:@"bold" size:41.0f color:[UIColor bleuColor] andText:LocalizedString(@"MY PROFILE", nil)];
        //language label
        UILabel *language = (UILabel *) [cell.contentView viewWithTag:-2];
        
        language.textAlignment=NSTextAlignmentLeft;
        
      //  language.layer.borderWidth = 1.0f;
       // language.layer.borderColor = [UIColor lightGrayColor].CGColor;
        NSString *lang = NULL;
  /*      if([[[Localization singleton]languageString]isEqualToString:@"en"])
            lang = LocalizedString(@"english", nil);
        if([[[Localization singleton]languageString]isEqualToString:@"fr"])
            lang = LocalizedString(@"french", nil);
        if([[[Localization singleton]languageString]isEqualToString:@"nl"])
            lang = LocalizedString(@"dutch", nil);
   */
        
        NSLog(@"mytemplanguage=%@",temp_language);
        
        lang=temp_language;
        [[UIUtils singleton]configureLabel:language withSyle:@"normal" size:13.0f color:[UIColor bleuColor] andText:lang];

        //language selector
        UIView *view = [cell.contentView viewWithTag:-3];
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(showLanguageMenu:)];
        [tgr setDelegate:self];
        [view addGestureRecognizer:tgr];
        
        if(self.accountMode)
        {
            NSString *lang = temp_language;//[[Localization singleton]languageString];
            if([lang isEqualToString:@"en"])
            {
                [[UIUtils singleton]configureLabel:language withSyle:@"normal" size:13.0f color:[UIColor bleuColor] andText:LocalizedString(@"english", nil)];
            }
            else if([lang isEqualToString:@"fr"])
            {
                [[UIUtils singleton]configureLabel:language withSyle:@"normal" size:13.0f color:[UIColor bleuColor] andText:LocalizedString(@"french", nil)];
            }
            else if([lang isEqualToString:@"es"])
            {
                [[UIUtils singleton]configureLabel:language withSyle:@"normal" size:13.0f color:[UIColor bleuColor] andText:LocalizedString(@"spanish", nil)];
            }
            else
            {
                [[UIUtils singleton]configureLabel:language withSyle:@"normal" size:13.0f color:[UIColor bleuColor] andText:LocalizedString(@"dutch", nil)];
            }
            //[[Localization singleton]setLanguage:lang];
        }
    }
    else if(indexPath.row == 2)
    {
        if(!self.firstnameCell)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"FieldCell" owner:nil options:nil]objectAtIndex:0];
            self.firstnameCell = (FieldCell *) cell;
            UITextField *tf = (UITextField *) [cell.contentView viewWithTag:-1];
            [tf setDelegate:self];
            tf.layer.borderWidth = 1.0f;
            tf.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"firstname", nil)];
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
             tf.returnKeyType = UIReturnKeyNext;
            if(self.accountMode)
            {
                NSString *firstname = [self.account objectForKey:@"first_name"];//[[FIRInstanceID instanceID] token];
                
                
                NSLog(@"test dic = %@",[self.account valueForKey:@"first_name"]);
                
                [tf setText:firstname];
            }
        }
        else
        {
            cell = self.firstnameCell;
        }
    }
    else if(indexPath.row == 3)
    {
        if(!self.lastnameCell)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"FieldCell" owner:nil options:nil]objectAtIndex:0];
            self.lastnameCell = (FieldCell *) cell;
            
            UITextField *tf = (UITextField *) [cell.contentView viewWithTag:-1];
            [tf setDelegate:self];
            tf.layer.borderWidth = 1.0f;
            tf.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"lastname", nil)];
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
             tf.returnKeyType = UIReturnKeyNext;
            if(self.accountMode)
            {
                NSString *lastname = [self.account objectForKey:@"last_name"];
                [tf setText:lastname];
            }
        }
        else
        {
            cell = self.lastnameCell;
        }
        
    }else if(indexPath.row == 4){
        if(!self.emailCell)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"FieldCell" owner:nil options:nil]objectAtIndex:0];
            self.emailCell = (FieldCell *) cell;
            
            UITextField *tf = (UITextField *) [cell.contentView viewWithTag:-1];
            [tf setDelegate:self];
            tf.layer.borderWidth = 1.0f;
            tf.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"email", nil)];
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
             tf.returnKeyType = UIReturnKeyNext;
            [tf setKeyboardType:UIKeyboardTypeEmailAddress];
            [tf setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            
            if(self.accountMode)
            {
                
                NSString *mail = [self.account objectForKey:@"email"];
                [tf setText:mail];
                
                [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:@""];
            }
        }
        else
        {
            cell = self.emailCell;
        }
    }
    else if(indexPath.row == 5)
    {
        if(!self.phoneCell)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"FieldCell" owner:nil options:nil]objectAtIndex:0];
            self.phoneCell = (FieldCell *) cell;
            
            UITextField *tf = (UITextField *) [cell.contentView viewWithTag:-1];
            [tf setDelegate:self];
            tf.layer.borderWidth = 1.0f;
            tf.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"phone", nil)];
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
             tf.returnKeyType = UIReturnKeyDone;
            [tf setKeyboardType:UIKeyboardTypePhonePad];
            if(self.accountMode)
            {
               // tf.textAlignment = NSTextAlignmentCenter;

                [tf setUserInteractionEnabled:NO];
              //  tf.layer.borderWidth = 0.0f;

                
                NSString *phone = [self.account objectForKey:@"phone_number"];
              
                [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor lightGrayColor] andHint:@""];

                
                [tf setText:phone];
                
                
                
            }
        }
        else
        {
            cell = self.phoneCell;
        }
    }
    /*else if(indexPath.row == 6)
     {
     cell = [tableView dequeueReusableCellWithIdentifier:@"ProfessionalInformations"];
     
     UILabel *pi = (UILabel *) [cell.contentView viewWithTag:-1];
     [[UIUtils singleton]configureLabel:pi withSyle:@"normal" size:21.0f color:[UIColor blueishColor] andText:LocalizedString(@"professional_informations", nil)];
     }
     else if(indexPath.row == 7)
     {
     cell = [tableView dequeueReusableCellWithIdentifier:@"Function"];
     
     UITextField *tf = (UITextField *) [cell.contentView viewWithTag:-1];
     [tf setDelegate:self];
     tf.layer.borderWidth = 1.0f;
     tf.layer.borderColor = [UIColor bleuColor].CGColor;
     [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"function", nil)];
     tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
     
     //function selector
     UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self
     action:@selector(showFunctionsMenu:)];
     [tgr setDelegate:self];
     [tf addGestureRecognizer:tgr];
     
     if(self.accountMode)
     {
     //{"first_name":"freed1","last_name":"freed1","uid":"81","phone_no":"147258","site":"","department":"IT Service","driver_function":"","lang":"en","mail":"freed1@yopmail.com"}
     NSDictionary *function = [self.account objectForKey:@"driver_function"];
     [tf setText:[function objectForKey:@"name"]];
     self.function = function;
     }
     }
     else if(indexPath.row == 8)
     {
     cell = [tableView dequeueReusableCellWithIdentifier:@"Department"];
     
     UITextField *tf = (UITextField *) [cell.contentView viewWithTag:-1];
     tf.layer.borderWidth = 1.0f;
     tf.layer.borderColor = [UIColor bleuColor].CGColor;
     [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"department", nil)];
     tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
     
     //department selector
     UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self
     action:@selector(showDepartmentsMenu:)];
     [tgr setDelegate:self];
     [tf addGestureRecognizer:tgr];
     
     if(self.accountMode)
     {
     //{"first_name":"freed1","last_name":"freed1","uid":"81","phone_no":"147258","site":"","department":"IT Service","driver_function":"","lang":"en","mail":"freed1@yopmail.com"}
     NSDictionary *department = [self.account objectForKey:@"department"];
     [tf setText:[department objectForKey:@"name"]];
     self.department = department;
     }
     }
     else if(indexPath.row == 9)
     {
     cell = [tableView dequeueReusableCellWithIdentifier:@"Work"];
     
     UITextField *tf = (UITextField *) [cell.contentView viewWithTag:-1];
     [tf setDelegate:self];
     tf.layer.borderWidth = 1.0f;
     tf.layer.borderColor = [UIColor bleuColor].CGColor;
     [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"work_site", nil)];
     tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
     
     //worksites selector
     UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self
     action:@selector(showWorksitesMenu:)];
     [tgr setDelegate:self];
     [tf addGestureRecognizer:tgr];
     
     if(self.accountMode)
     {
     //{"first_name":"freed1","last_name":"freed1","uid":"81","phone_no":"147258","site":"","department":"IT Service","driver_function":"","lang":"en","mail":"freed1@yopmail.com"}
     NSDictionary *site = [self.account objectForKey:@"site"];
     [tf setText:[site objectForKey:@"name"]];
     self.worksite = site;
     }
     }*/
    else if(indexPath.row == 6){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Validate"];
        
        UIButton *b = (UIButton *) [cell.contentView viewWithTag:-1];
        [[UIUtils singleton]configureButton:b withSyle:@"normal" size:21.0f andTitle:LocalizedString(@"update", nil)];
     
            [b addTarget:self
                  action:@selector(doUpdateAccount)
        forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if(tableView == self.languagesTableView)
    {
        return 55;
    }
    
    
    if(indexPath.row == 0)
        return 80.0f;
    else if(indexPath.row == 1)
        return 50;
    else if(indexPath.row == 2)
        return 50;
    else if(indexPath.row == 3)
        return 50;
    else if(indexPath.row == 4)
        return 50;
    else if(indexPath.row == 5)
        return 50;
    else if(indexPath.row == 6)
        return 150;
    
    return 0.0f;}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [_view_newPhoneNum setHidden:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == self.languagesTableView)
    {
        [self.currentField resignFirstResponder];
        
        if(indexPath.row == 0)
        {// [[Localization singleton]setLanguage:@"en"];
            
            temp_language=@"en";
            
        }
        else if(indexPath.row == 1)
        {
            
           // [[Localization singleton]setLanguage:@"fr"];
            temp_language=@"fr";
            
            }
        else if(indexPath.row == 2)
        {
            
            // [[Localization singleton]setLanguage:@"fr"];
            temp_language=@"nl";
            
        }
        else
        {
           // [[Localization singleton]setLanguage:@"nl"];
            temp_language=@"es";
        }
        
        
        
       // [[NSNotificationCenter defaultCenter] postNotificationName:@"lang_changed_menu" object:nil];
        
        

        
        
        //refresh UI
        if(self.firstnameCell)
        {
            UITextField *tf = [self.firstnameCell viewWithTag:-1];
            if(tf.text.length == 0)
            {
                self.firstnameCell = nil;
            }
        }
        if(self.lastnameCell)
        {
            UITextField *tf = [self.lastnameCell viewWithTag:-1];
            if(tf.text.length == 0)
            {
                self.lastnameCell = nil;
            }
        }
        if(self.emailCell)
        {
            UITextField *tf = [self.emailCell viewWithTag:-1];
            if(tf.text.length == 0)
            {
                self.emailCell = nil;
            }
        }
        /*if(self.addressCell)
         {
         UITextField *tf = [self.addressCell viewWithTag:-1];
         if(tf.text.length == 0)
         {
         self.addressCell = nil;
         }
         }*/
        if(self.phoneCell)
        {
            UITextField *tf = [self.phoneCell viewWithTag:-1];
            if(tf.text.length == 0)
            {
                self.phoneCell = nil;
            }
        }
        
        
        [self setupView];
        
        [self.tableView reloadData];
        
        [UIView animateWithDuration:0.25f
                              delay:0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:
         ^{
             CGRect frame = self.languagesTableView.frame;
             frame.size.height = 0.0f;
             self.languagesTableView.frame = frame;
         }
                         completion:^(BOOL finished){
                             [self.languagesTableView removeFromSuperview];
                             self.languagesTableView = nil;
                         }];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)fetchProfiledata{


    NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"phone_number"] forKey:@"phone_number"];
    @try {
        if([[FIRInstanceID instanceID] token]) {
            [payload setObject:[[FIRInstanceID instanceID] token] forKey:@"gcm_token"];
        }
    } @catch (NSException *exception) {
        NSLog(@"firebase token error");
    } @finally {
        
    }
    NSLog(@"mypayload=%@",payload);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UDOperator singleton]fetchProfile:payload withCompletionBlock:^(id response) {
      
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
       // NSLog(@"my response = %@",response);

        
        
        if(response && [response isKindOfClass:[NSDictionary class]]){
            //NSLog(@" login response %@",rez);
            //let user in app

            
            
            
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"account"];

            
            
            
            
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
        
            self.account=[response mutableCopy];
            NSLog(@"my account = %@",self.account);
            [self getAccount];
            [_tableView reloadData];

            
            
        }
        else{
        
        
        
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                        message:LocalizedString(@"no_internet", nil)
                                                       delegate:self
                                              cancelButtonTitle:LocalizedString(@"ok", nil)
                                              otherButtonTitles:nil, nil];
            
            
            [av show];
            
        }

        
        
    } ];

    
    

}

-(IBAction)newph_hereButton_clicked:(id)sender{
    
    
    [_view_newPhoneNum setHidden:NO];
    
    
    _txt_oldPhoneNum.text=[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"phone_number"];
    
    
    _txt_oldPhoneNum.userInteractionEnabled=false;
    
    [_txt_newPhoneNum becomeFirstResponder];
    
    
    
    
   // _txt_oldPhoneNum.text=[[NSUserDefaults standardUserDefaults] valueForKey:@"phone_number"];
    
}
-(IBAction)newconnector_hereButton_clicked:(id)sender{
    
    QRCodeScanner *qrcode = [self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeScanner"];
    
    qrcode.phone_number=[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"phone_number"];
    
    [[SlideNavigationController sharedInstance] pushViewController:qrcode animated:YES];
    
    
}

-(IBAction)btn_updatePhNum:(id)sender{

    if(_txt_oldPhoneNum.text.length<1||_txt_newPhoneNum.text.length<1)
    {
     
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
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
    [payload setObject:_txt_oldPhoneNum.text forKey:@"phone_number_old"];
    [payload setObject:_txt_newPhoneNum.text forKey:@"phone_number"];
    [payload setObject: [[Localization singleton]languageString].uppercaseString  forKey:@"lang"];
    [[UDOperator singleton]updatePhoneNumber:payload withCompletionBlock:^(id response) {
    NSLog(@"myresponseqrcode=%@",response);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        
        
    if(response && [response isKindOfClass:[NSNumber class]]){
            long status = [response longValue ];
            NSLog(@"mystatus = %li",status);
    if(status==200){
        ConfirmPhoneNumber *confirmController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmPhoneNumber"];
        confirmController.isupdate=YES;
        confirmController.phone_number=_txt_newPhoneNum.text;
        [[SlideNavigationController sharedInstance] pushViewController:confirmController animated:YES];
        
    
    }else if(status == 404){
        //show sorry screen
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:LocalizedString(@"error", nil) message:LocalizedString(@"server_error", nil) delegate:self cancelButtonTitle:LocalizedString(@"ok", nil)  otherButtonTitles: nil];
        [alert show];
        
        
    }else if(status == 401){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"error", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        
    }
    else if(status == 500){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
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
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"error", nil) delegate:self cancelButtonTitle:LocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
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

@end
