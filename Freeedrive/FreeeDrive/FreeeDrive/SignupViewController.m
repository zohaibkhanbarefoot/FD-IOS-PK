//
//  SignupViewController.m
//  FreeeDriveStore
//
//  Created by KL on 3/7/16.
//  Copyright © 2016 Cole Street. All rights reserved.
//

#import "SignupViewController.h"
#import "UDOperator.h"
#import "MBProgressHUD.h"
#import "UICKeychainStore.h"
#import "FieldCell.h"
#import "AppDelegate.h"
#import "ConfirmPhoneNumber.h"
#import "CountryListViewController.h"
@import Firebase;
#include <sys/sysctl.h>
#import <QuartzCore/QuartzCore.h>
#import "NSMutableAttributedString+Color.h"

@interface SignupViewController ()
{

    NSString *temp_lang;

}
@property (strong, nonatomic) IBOutlet UITableView *tableView, *languagesTableView; //*functionsTableView, *departmentsTableView, //*worksitesTableView;
@property (strong, nonatomic) NSMutableArray *languagesArray, *functionsArray; //*departmentsArray, *worksitesArray;
@property (strong, nonatomic) NSDictionary *function, *department, *worksite, *account;
@property (nonatomic) CGFloat lastCellHeight;
@property (weak, nonatomic) IBOutlet FieldCell *firstnameCell, *lastnameCell, /**addressCell ,*/ *emailCell, *phoneCell;
@property (strong, nonatomic) UITextField *currentField;

@end

@implementation SignupViewController

#pragma mark -
#pragma mark Init / Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lastCellHeight = 200.0f;
    temp_lang=[[Localization singleton]languageString];

    //configure UI
  //  [self.wheelButton setHidden:YES];
    [self.backButton addTarget:self
                        action:@selector(back:)
              forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    [self.menuButton setHidden:YES];

    
    
    [self setupTerms_Condition];
    
    
    [_view_termsCondition setHidden:YES];
    
}


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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

-(void)back:(id )sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    frame.origin.y = 110 + sender.view.frame.size.height;
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
    self.lastCellHeight = 450.0f;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)keyboardWillHide
{
    self.lastCellHeight = 200.0f;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
    
    [self setAccount:[[NSUserDefaults standardUserDefaults]objectForKey:@"account"]];
    self.firstnameCell = nil;
    self.lastnameCell = nil;
    self.emailCell = nil;
    self.phoneCell = nil;
    [self.tableView reloadData];
}

-(void)doRegister
{
    
    
    
    
    
    
   UITableViewCell *cell = self.phoneCell;
    cell = self.phoneCell;
    UITextField *phoneField = (UITextField *) [cell.contentView viewWithTag:-1];
    if([phoneField.text hasPrefix:@"+"]||[phoneField.text hasPrefix:@"0"]) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_phone", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];

        return;
    
    }
   

    if(phoneField.text.length<=5||phoneField.text.length>=16) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_phone_length", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        
        return;
        
    }
    

    
    
    //validate firstname
    cell = self.firstnameCell;
    UITextField *firstnameField = (UITextField *) [cell.contentView viewWithTag:-1];
    if([firstnameField.text length] == 0 || [firstnameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
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
    if([emailField.text length] == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    else if(![[UDOperator singleton] validateEmail:[emailField text].lowercaseString] || [emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_email", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
    //validate phone
    cell = self.phoneCell;
    phoneField = (UITextField *) [cell.contentView viewWithTag:-1];
    UIButton *btn= (UIButton *) [cell.contentView viewWithTag:-2];

    if([phoneField.text length] == 0 || [phoneField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
     [_view_termsCondition setHidden:NO];
    
    
   
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

#pragma mark -
#pragma mark UITableView methods
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    if(tableView != self.languagesTableView){
      //put your values, this is part of my code
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30.0f)];
    [view setBackgroundColor:[UIColor clearColor]];
    
       return view;
    }
    else
        return  nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
      if(tableView != self.languagesTableView)
    return 30;
          else
              return  0;
}
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
        [[UIUtils singleton]configureLabel:pi withSyle:@"textcenter" size:40 color:[UIColor bleuColor] andText:LocalizedString(@"hello", nil)];

        
         }
    else if(indexPath.row == 1)
    {
        
    
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"Top"];
        
         UIView *view_lang = (UILabel *) [cell.contentView viewWithTag:-3];
        view_lang.layer.borderWidth = 1.0f;
        view_lang.layer.borderColor = [UIColor lightGrayColor].CGColor;
        UILabel *language = (UILabel *) [cell.contentView viewWithTag:-2];
        
        
        
        //language.layer.borderWidth = 1.0f;
        language.textAlignment=NSTextAlignmentLeft;
       // language.layer.borderColor = [UIColor lightGrayColor].CGColor;
        NSString *lang = NULL;
        lang=temp_lang;
        if([temp_lang isEqualToString:@"en"])
            lang = LocalizedString(@"english", nil);
        if([temp_lang isEqualToString:@"fr"])
            lang = LocalizedString(@"french", nil);
        if([temp_lang isEqualToString:@"nl"])
            lang = LocalizedString(@"dutch", nil);
        if([temp_lang isEqualToString:@"es"])
            lang = LocalizedString(@"spanish", nil);
        
        [[UIUtils singleton]configureLabel:language withSyle:@"normal" size:13.0f color:[UIColor bleuColor] andText:lang];
        
        //language selector
        UIView *view = [cell.contentView viewWithTag:-3];
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(showLanguageMenu:)];
        [tgr setDelegate:self];
        [view addGestureRecognizer:tgr];
      
    }
    else if(indexPath.row == 2)
    {
        if(!self.firstnameCell)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"FieldCell" owner:nil options:nil]objectAtIndex:0];
            self.firstnameCell = (FieldCell *) cell;
            UITextField *tf = (UITextField *) [cell.contentView viewWithTag:-1];
            [tf setDelegate:self];
             tf.returnKeyType = UIReturnKeyNext;
            tf.layer.borderWidth = 1.0f;
            tf.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"firstname", nil)];
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
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
             tf.returnKeyType = UIReturnKeyNext;
            tf.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"lastname", nil)];
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
            
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
             tf.returnKeyType = UIReturnKeyNext;
            tf.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"email", nil)];
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
            [tf setKeyboardType:UIKeyboardTypeEmailAddress];
            [tf setAutocapitalizationType:UITextAutocapitalizationTypeNone];
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
            cell = [[[NSBundle mainBundle]loadNibNamed:@"FieldCell2" owner:nil options:nil]objectAtIndex:0];
            self.phoneCell = (FieldCell *) cell;
            
            UITextField *tf = (UITextField *) [cell.contentView viewWithTag:-1];
            [tf setDelegate:self];
            tf.layer.borderWidth = 1.0f;
            tf.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [[UIUtils singleton]configureField:tf withSyle:@"normal" size:17.0f color:[UIColor bleuColor] andHint:LocalizedString(@"phone", nil)];
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(10.0f, 1.0f, 0.0f);
            [tf setKeyboardType:UIKeyboardTypePhonePad];
            tf.returnKeyType = UIReturnKeyDone;
            
            
            UIButton *btn = (UIButton *) [cell.contentView viewWithTag:-2];
            btn.layer.borderWidth = 1.0f;
            btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
            btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [[UIUtils singleton]configureButton:btn withSyle:@"normal" size:17.0f andTitle:LocalizedString(@"+32", nil)];
            [btn addTarget:self action:@selector(btn_selectContryCode:) forControlEvents:UIControlEventTouchUpInside];
            

            
           
        }
        else
        {
            cell = self.phoneCell;
        }
    }
       else if(indexPath.row == 6){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Validate"];
        
        UIButton *b = (UIButton *) [cell.contentView viewWithTag:-1];
        [[UIUtils singleton]configureButton:b withSyle:@"normal" size:24 andTitle:LocalizedString(@"next", nil)];
        [b addTarget:self
                  action:@selector(doRegister)
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
        return 55.0f;
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
  
    return 0.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == self.languagesTableView)
    {
        
        [self.currentField resignFirstResponder];
        if(indexPath.row == 0)
        {
            
            temp_lang=@"en";
            //[[Localization singleton]setLanguage:@"en"];
        }
        else if(indexPath.row == 1)
        {
       // [[Localization singleton]setLanguage:@"fr"];
       temp_lang=@"fr";
        }else if(indexPath.row == 2)
        {
        temp_lang=@"nl";
      //  [[Localization singleton]setLanguage:@"nl"];
        }
        else        {
        temp_lang=@"es";
            //  [[Localization singleton]setLanguage:@"nl"];
        }
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
        if(self.phoneCell)
        {
            UITextField *tf = [self.phoneCell viewWithTag:-1];
            if(tf.text.length == 0)
            {
                self.phoneCell = nil;
            }
        }
        
        
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


-(IBAction)btn_selectContryCode:(id)sender{
    
    
    
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:NULL];
}

- (void)didSelectCountry:(NSDictionary *)country
{
    NSLog(@"%@", country);
    UITableViewCell *cell;
    cell = self.phoneCell;
    UIButton *btn = (UIButton *) [cell.contentView viewWithTag:-2];
    
    
    [btn setTitle:[country valueForKey:@"dial_code"] forState:UIControlStateNormal];
    
}


-(IBAction)btn_accept_clicked:(id)sender{

    [_view_termsCondition setHidden:YES];
    
    
    
    
    UITableViewCell *cell = self.phoneCell;
    cell = self.phoneCell;
    UITextField *phoneField = (UITextField *) [cell.contentView viewWithTag:-1];
    if([phoneField.text hasPrefix:@"+"]||[phoneField.text hasPrefix:@"0"]) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_phone", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        
        return;
        
    }
    
    
    if(phoneField.text.length<=5||phoneField.text.length>=16) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_phone_length", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        
        return;
        
    }
    
    
    
    
    //validate firstname
    cell = self.firstnameCell;
    UITextField *firstnameField = (UITextField *) [cell.contentView viewWithTag:-1];
    if([firstnameField.text length] == 0 || [firstnameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
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
    if([emailField.text length] == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    else if(![[UDOperator singleton] validateEmail:[emailField text].lowercaseString] || [emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"invalid_email", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
    //validate phone
    cell = self.phoneCell;
    phoneField = (UITextField *) [cell.contentView viewWithTag:-1];
    UIButton *btn= (UIButton *) [cell.contentView viewWithTag:-2];
    
    if([phoneField.text length] == 0 || [phoneField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:LocalizedString(@"all_fields_mandatory", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"ok", nil)
                                          otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    

    
    
    
    
    //call API
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:firstnameField.text forKey:@"first_name"];
    [payload setObject:lastnameField.text forKey:@"last_name"];
    [payload setObject:emailField.text.lowercaseString forKey:@"email"];
    
    NSString *phonenum=[NSString stringWithFormat:@"%@%@",btn.titleLabel.text,phoneField.text];
    [payload setObject:phonenum forKey:@"phone_number"];
    // phonenum=@"923335469641";
    [payload setObject:phonenum forKey:@"phone_number"];
    
    //  [payload setObject:phoneField.text forKey:@"phone_number"];
    //  [payload setObject:[[[Localization singleton]languageString] lowercaseString] forKey:@"lang"];
    
    [payload setObject:temp_lang forKey:@"lang"];
    
    
    [[Localization singleton]setLanguage:temp_lang];
    
    
    [payload setObject:[self getModel] forKey:@"phone_model"];
    [payload setObject: [UIDevice currentDevice].systemVersion forKey:@"phone_os_version"];
    
    
    
    [payload setObject:[UIDevice currentDevice].name forKey:@"phone_name"];
    
    @try {
        if([[FIRInstanceID instanceID] token]) {
            [payload setObject:[[FIRInstanceID instanceID] token] forKey:@"gcm_token"];
        }
    } @catch (NSException *exception) {
        NSLog(@"firebase token error");
    } @finally {
        
    }
    
    //use Keychain to persist the device ID
    NSString *deviceId = @"";
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.FreeeDriveStore"];
    /* if(keychain && keychain[@"device_id"])
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
     }*/
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
    deviceId = CFBridgingRelease(CFUUIDCreateString(nil, uuid));
    keychain[@"device_id"] = deviceId;
    NSLog(@"spawned device_id: %@", deviceId);
    
    
    [payload setObject:deviceId forKey:@"device_id"];
    
    
    
    
    [[UDOperator singleton]postRegister:payload
                    withCompletionBlock:^(NSNumber* response){
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        
                        if(response){
                            
                            
                            NSLog(@"response = %@",response);
                            
                            if(response.longValue == 200){
                                
                                
                                
                                
                                
                                
                                ConfirmPhoneNumber *confirmController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmPhoneNumber"];
                                
                                
                                
                                UIButton *btn= (UIButton *) [cell.contentView viewWithTag:-2];
                                
                                NSString *phonenum=[NSString stringWithFormat:@"%@%@",btn.titleLabel.text,phoneField.text];
                                
                                
                                
                                
                                
                                confirmController.phone_number=phonenum;
                                [[SlideNavigationController sharedInstance] pushViewController:confirmController animated:YES];
                                
                                
                            }else if(response.longLongValue == 404){
                                //show sorry screen
                                
                                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:LocalizedString(@"error", nil) message:LocalizedString(@"server_error_register", nil) delegate:self cancelButtonTitle:LocalizedString(@"ok", nil) otherButtonTitles: nil];
                                [alert show];
                                
                                
                            }else if(response.longLongValue == 422){
                                
                                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                                            message:LocalizedString(@"email_taken", nil)
                                                                           delegate:self
                                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                                  otherButtonTitles:nil, nil];
                                [av show];
                                
                            }
                            else if(response.longLongValue == 500){
                                
                                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                                            message:LocalizedString(@"number_already_exist", nil)
                                                                           delegate:self
                                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                                  otherButtonTitles:nil, nil];
                                [av show];
                                
                            }
                            else if(response.longLongValue == 401){
                                
                                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                                            message:LocalizedString(@"not_registered", nil)
                                                                           delegate:self
                                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                                  otherButtonTitles:nil, nil];
                                [av show];
                                
                            }
                            else if(response.longLongValue == 403){
                                
                                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                                            message:LocalizedString(@"device_already_registered", nil)
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
    
    
    
    
 
    
    
    /*
    "terms_title"="Terms & Conditions";
    "terms_detail"="";
    "privacy_policy_title"="";
    "accept_terms_title"="";*/
    
    
    
    



}


@end
