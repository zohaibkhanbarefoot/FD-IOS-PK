//
//  Notification.m
//  EddystoneScannerSample
//
//  Created by user on 4/01/2017.
//
//

#import "Notification.h"
#import "cell_notification.h"
#import "UDOperator.h"
#import "MBProgressHUD.h"
#import "UIUtils.h"
#import "NSMutableAttributedString+Color.h"
#import "MainViewController.h"
@interface Notification ()
{
    NSString *Str;
    int labelwidth;
    int isopenatindex;
    NSMutableArray *array_data;

}
@end

@implementation Notification

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tbl_view.rowHeight = UITableViewAutomaticDimension;
    
     [[UIUtils singleton] configureLabel:_lbl_headerTitle withSyle:@"textcenter" size:23 color:[UIColor bleuColor] andText:LocalizedString(@"notifications", nil)];
    array_data=[[NSMutableArray alloc] init];
    Str=@"This is a simple iOS application that scans for Eddystone beacons and prints any sightings via NSLog to the debug console    There are both Objective-C and Swift versions of the sample. To switch between them, use the  dropdown in the upper left of Xcode. This has been tested and developed on Xcode 6.x and is intended to target apps running on iOS 8.x and greater.";


    [self.menuButton setHidden:YES];
    
    [self.backButton addTarget:self action:@selector(btn_back_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    _lbl_noNotifcations.text=LocalizedString(@"no_notifications_found", nil);
    [self getNotifications];
    
    
    
    self.refreshConrol = [[UIRefreshControl alloc] init];
    self.refreshConrol.backgroundColor = [UIColor purpleColor];
    self.refreshConrol.tintColor = [UIColor whiteColor];
    [self.refreshConrol addTarget:self
                           action:@selector(refreshNotifications:)
                  forControlEvents:UIControlEventValueChanged];
      [self.tbl_view addSubview:self.refreshConrol];
    
   }

-(void)refreshNotifications:(id)sender{

    [self.refreshConrol endRefreshing];
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
    return array_data.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbl_view.frame.size.width, 15)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    int textHeight;
    int defaultHeight=90;
    textHeight=[self heightOfCellWithIngredientLine:[[array_data objectAtIndex:indexPath.row] valueForKey:@"message"] withSuperviewWidth:self.view.frame.size.width-20];
  
    if(textHeight <15){
    
        textHeight=0;
        defaultHeight=70;
    }
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
    NSString *myidentifier=@"cell_notification";
       cell_notification *cell =[tableView dequeueReusableCellWithIdentifier:myidentifier];
    cell.btn_dropdown.tag =indexPath.row;
    [cell.btn_dropdown addTarget:self action:@selector(btn_dropdown_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *titleSring=[NSString stringWithFormat:@"%@ | Tile of the notification",[[array_data objectAtIndex:indexPath.row] valueForKey:@"scheduled_at"]];
    
    cell.lbl_title.attributedText=[self setColors_String:titleSring];

    
      [[UIUtils singleton] configureLabel:cell.lbl_message withSyle:@"normal" size:23 color:[UIColor grayColor] andText:[[array_data objectAtIndex:indexPath.row] valueForKey:@"message"]];
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

    [payload setObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] objectForKey:@"phone_number"] forKey:@"phone_number"];
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
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"invalid_phone", nil) delegate:self cancelButtonTitle:LocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
             //   [av show];
                
                
            }
            
            
            
            
  else{
                //error
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                            message:LocalizedString(@"error", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil, nil];
                [av show];
            }
            
        }
        
        
        
        
        //19DF2A75-D869-4F00-9370-3B375567F150
        //
        
        
        
        
        
        if(array_data.count<1){
    
            [_tbl_view setHidden:YES];
            [_lbl_noNotifcations setHidden:NO];
            
        }
        else
        {
            [_tbl_view setHidden:NO];
            [_lbl_noNotifcations setHidden:YES];
            
        }

        
    }];
    
    


}



- (NSAttributedString *) setColors_String:(NSString *)str
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str];
    [string setColorForText:str withColor:[UIColor bleuColor]];
    [string setColorForText:@"Tile of the notification" withColor:[UIColor grayColor]];
   
    
    return string;
}
@end
