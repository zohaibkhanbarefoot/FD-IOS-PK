//
//  Notification.m
//  EddystoneScannerSample
//
//  Created by user on 4/01/2017.
//
//

#import "FAQs.h"
#import "cell_notification.h"
#import "UDOperator.h"
#import "MBProgressHUD.h"
#import "UIUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "cell_datausage.h"
#import "NSMutableAttributedString+Color.h"
#import "MainViewController.h"
@interface FAQs ()
{
    NSString *Str;
    int labelwidth;
    int isopenatindex;
    NSMutableArray *array_data;
    
}
@end

@implementation FAQs

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[UIUtils singleton] configureLabel:_lbl_headerTitle withSyle:@"textcenter" size:23 color:[UIColor bleuColor] andText:@"FAQ"];
    
    [self.menuButton setHidden:YES];
    
    [self.backButton addTarget:self action:@selector(btn_back_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [[UIUtils singleton] configureLabel:self.lbl_website
                               withSyle:@"bold"
                                   size:19.0f
                                  color:[UIColor bleuColor]
                                andText:@"www.freeedrive.com"];
    [[UIUtils singleton] configureLabel:self.lbl_versionInfo
                               withSyle:@"bold"
                                   size:19.0f
                                  color:[UIColor bleuColor]
                                andText:[NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    
       NSString *string = @"www.freeedrive.com";
    
    
    UIFontDescriptor *userHeadLineFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    CGFloat userHeadLineFontSize = [userHeadLineFont pointSize];
   
    NSDictionary *attributes = @{NSFontAttributeName:  [UIFont fontWithName:@"DINNextLTPro-MediumCond" size:userHeadLineFontSize]};
    
    
    
    
   
    _lbl_website.attributedText = [[NSAttributedString alloc]initWithString:string attributes:attributes];
    
    [_lbl_website setLinkForSubstring:@"www.freeedrive.com" withLinkHandler:^(FRHyperLabel *label, NSString *substring){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.freeedrive.com"]];
    }];



}
-(IBAction)btn_linkclicked:(id)sender{
 
    
    NSString *URL = @"http://www.freeedrive.com";
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
    }

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

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbl_view.frame.size.width, 15)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int textHeight;
    int textHeight_title;
    NSString *q_name=[NSString stringWithFormat:@"faq_q%i",indexPath.row+1];
    NSString *a_name=[NSString stringWithFormat:@"faq_a%i",indexPath.row+1];
   // textHeight_title=[self heightOfCellWithIngredientLine:NSLocalizedString(q_name, nil)  withSuperviewWidth:self.view.frame.size.width-20];
    
    

     
     /*
     
     DINNextLTPro-LightCondensed" size:size]];
     
     else  if([style isEqualToString:@"textcenter"])
     {
     [label setFont:[UIFont fontWithName:@"DINNextLTPro-MediumCond"
     */
    
    if(indexPath.row==13){
    
        return 75;
    }
    
textHeight_title=  [self heightOfCellWithIngredientLine:NSLocalizedString(q_name, nil)  withSuperviewWidth:self.view.frame.size.width-60];
    
    
 textHeight= [self heightOfCellWithIngredientLine:NSLocalizedString(a_name, nil)  withSuperviewWidth:self.view.frame.size.width-60];
    if(isopenatindex==indexPath.row){
        
        NSLog(@"mytext=%i",textHeight);
         NSLog(@"mytext2=%i",textHeight_title);
        
        
    }

    
    int defaultHeight=70;
    
    if(textHeight_title >15&&textHeight>95){
        defaultHeight=90;
    }
    
   
    if(textHeight <15){
        textHeight=0;
       defaultHeight=60+textHeight_title;
    }
    else if(indexPath.row==0){
    
        textHeight=textHeight;
    }
    else if(textHeight>110)
    {
        
        
        textHeight=textHeight+55;
    }
    else if(textHeight>95)
    {  textHeight=textHeight+25;
        
    }

    else if(textHeight>85)
    {  textHeight=textHeight;
        
    }
   
    
    else if(textHeight>80)
        textHeight=textHeight+55;

    
   else if(textHeight>75)
        textHeight=textHeight+35;
    

   else if(textHeight>65)
        textHeight=textHeight;
    
   
    
   if(isopenatindex==indexPath.row){
     
      
        
        return  defaultHeight+textHeight;
    }
    else
        return defaultHeight;
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row==13){
    
    
        cell_datausage *cell = NULL;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell_datausage"];
        if(!cell)
            cell = [[[NSBundle mainBundle]loadNibNamed:@"cell_datausage" owner:nil options:nil]objectAtIndex:0];
        NSString *q_name=[NSString stringWithFormat:@"faq_q%i",indexPath.row+1];

        [[UIUtils singleton] configureLabel:cell.lbl_title withSyle:@"bold" size:18 color:[UIColor bleuColor] andText:LocalizedString(q_name, nil)];
        return cell;

    }
    else{
    NSString *myidentifier=@"cell_notification";
    cell_notification *cell =[tableView dequeueReusableCellWithIdentifier:myidentifier];
    cell.btn_dropdown.tag =indexPath.row;
    [cell.btn_dropdown addTarget:self action:@selector(btn_dropdown_clicked:) forControlEvents:UIControlEventTouchUpInside];
    NSString *q_name=[NSString stringWithFormat:@"faq_q%i",indexPath.row+1];
    NSString *a_name=[NSString stringWithFormat:@"faq_a%i",indexPath.row+1];
    
    
    NSLog(@"anme=%@",LocalizedString(a_name, nil));
    
    [[UIUtils singleton] configureLabel:cell.lbl_title withSyle:@"bold" size:18 color:[UIColor bleuColor] andText:LocalizedString(q_name, nil)];
    cell.backgroundColor = [UIColor clearColor];    [[UIUtils singleton] configureLabel:cell.lbl_message withSyle:@"normal" size:19 color:[UIColor grayColor] andText:LocalizedString(a_name, nil)];
    cell.backgroundColor = [UIColor clearColor];
    
    
    labelwidth=cell.lbl_message.frame.size.width;
    
    
    
    if(isopenatindex==indexPath.row){
        
        [cell.btn_dropdown setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    
        
    }
    else{
        
                [cell.btn_dropdown setBackgroundImage:[UIImage imageNamed:@"arrowdown.png"] forState:UIControlStateNormal];
    }
    
    
    
    
    
    return cell;
    }
}
-(void)btn_dropdown_clicked:(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    
    if(isopenatindex==btn.tag){
        
        isopenatindex=-1;
        
        
    }
    else{
        
        
        
        isopenatindex=(int)btn.tag;
    }
    
    
    
    
    [self.tbl_view reloadData];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    
    if(isopenatindex==indexPath.row){
        
        isopenatindex=-1;
        
        
    }
    else{
        
        
        
        isopenatindex=(int)indexPath.row;
    }
    
    

    
    [_tbl_view reloadData];
    
}


- (CGFloat)heightOfCellWithIngredientLine:(NSString *)ingredientLine
                       withSuperviewWidth:(CGFloat)superviewWidth
{
    CGFloat labelWidth                  = superviewWidth - 30.0f;
    //    use the known label width with a maximum height of 100 points
    CGSize labelContraints              = CGSizeMake(labelWidth, 100.0f);
    
    NSStringDrawingContext *context     = [[NSStringDrawingContext alloc] init];
    
    CGRect labelRect                    = [ingredientLine boundingRectWithSize:labelContraints
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:nil
                                                                       context:context];
    
    //    return the calculated required height of the cell considering the label
    
    NSLog(@"mysize= %f",labelRect.size.height);
    
    
    return labelRect.size.height;
}
-(IBAction)btn_cross_clicked:(id)sender{
    
    
    
    
}

-(void)getNotifications{
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    
    
    NSLog(@"mypayload=%@",payload);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UDOperator singleton]getNotifications:payload withCompletionBlock:^(id response) {
        
        
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        
        if(response && [response isKindOfClass:[NSArray class]]){
            
            
            
            
            array_data=[response mutableCopy];
            [_tbl_view reloadData];
            
            NSLog(@"array_data= %@",array_data);
            
            
            
        }else if(response && [response isKindOfClass:[NSNumber class]]){
            long status = [response longValue ];
            if(status == 401 || status == 404 ){
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"invalid_phone", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
                [av show];
                
                
            }
            
            
            
            
            else{
                //error
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                            message:LocalizedString(@"error", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
            }
            
        }
    }];
    
    
    
    
}


+ (float)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
  //  CGSize size = CGSizeZero;
   /* if (text) {
        //iOS 7
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }*/
    
   // NSString *yourText = [[resultArray objectAtIndex:indexPath.row] valueForKey:@"review_text"];
    CGSize lblwidth = CGSizeMake(widthValue, CGFLOAT_MAX);
    CGSize requiredSize = [text sizeWithFont:[UIFont fontWithName:@"CALIBRI" size:17] constrainedToSize:lblwidth lineBreakMode:NSLineBreakByWordWrapping];
    int calculatedHeight = requiredSize.height+50;
    return (float)calculatedHeight;
    
   // return size.height;
}
- (NSAttributedString *) setColors_String:(NSString *)str
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str];
    [string setColorForText:str withColor:[UIColor bleuColor]];
    [string setColorForText:@"Tile of the notification" withColor:[UIColor grayColor]];
    
    
    return string;
}
@end
