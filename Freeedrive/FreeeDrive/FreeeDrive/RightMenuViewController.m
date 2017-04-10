//
//  RightMenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/26/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "RightMenuViewController.h"
#import "cell_menu.h"
#import "UIUtils.h"
#import "Localization.h"
#import "Contactus.h"
#import "CreditsViewController.h"
#import "Notification.h"
#import "MyProfile.h"
#import "FAQs.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "SynchronizationManager.h"
#import "Reachability.h"
@implementation RightMenuViewController
#pragma mark - UIViewController Methods -
-(void)viewWillAppear:(BOOL)animated{


    [_tableView reloadData];
}
- (IBAction)sliderValueChanged:(id)sender
{
    // Set the label text to the value of the slider as it changes

     // Set the label text to the value of the slider as it changes
//        NSLog(@"")[NSString stringWithFormat:@"%f", self.slider.value];
  
    NSIndexPath *pathrow = [NSIndexPath indexPathForRow:5 inSection:0];
    cell_menu *cell = (cell_menu *)[_tableView cellForRowAtIndexPath:pathrow];

    
    
    int speed=cell.slider_speed.value*200;
  
    cell.lbl_item.text=[NSString stringWithFormat:@"ManualSpeed=%i", speed];
        appDelegate.manual_speed=speed;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//self.tableView.separatorColor = [UIColor lightGrayColor];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    appDelegate.manual_speed=0;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(langChanged) name:@"lang_changed_menu" object:nil];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // or you have the previous 'None' style...

    [_tableView reloadData];
    NSIndexPath *pathrow = [NSIndexPath indexPathForRow:5 inSection:0];
    cell_menu *cell = (cell_menu *)[_tableView cellForRowAtIndexPath:pathrow];
    cell.slider_speed.value=0;
    
    [_tableView reloadData];
   

    
}
-(void)langChanged{

    [_tableView reloadData];

}
#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 15)];
	view.backgroundColor = [UIColor clearColor];
	return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

 
    
    
    if(indexPath.row==4){
       return 200;
        }
    else if(indexPath.row==5)
        return 170;
    else
        return 50;
    


}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 15;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString *myidentifier=@"cell_menu";
    
  
    
    if(indexPath.row==4){
        
        myidentifier=@"cell_menu1";
    }
    if(indexPath.row==5){
    
    myidentifier=@"cell_menu4";
    }
    
	cell_menu *cell =[tableView dequeueReusableCellWithIdentifier:myidentifier];
	   NSString *cellName;
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    
	switch (indexPath.row)
	{
            
            
         
		case 0:
            cellName = LocalizedString(@"faq", nil);
            [cell.switch_findmycar setHidden:YES];
			break;
			
		case 1:
            cellName = LocalizedString(@"my_notifications", nil);
            [cell.switch_findmycar setHidden:YES];
			break;
			
		case 2:
            cellName =LocalizedString(@"my_profile", nil);
            [cell.switch_findmycar setHidden:YES];
			break;
			
		/*case 3:
			cellName= LocalizedString(@"find_my_car", nil);
            [cell.switch_findmycar setHidden:NO];
            cell.switch_findmycar.onTintColor=[UIColor whiteColor];
			break;*/
			
		case 3:
			cellName = LocalizedString(@"contact_us", nil);
            [cell.switch_findmycar setHidden:YES];
			break;
			
		/*case 5:
            
            cellName = LocalizedString(@"sync", nil);
            [cell.switch_findmycar setHidden:YES];
            
						break;*/
       /* case 4:
           // [self infoView];
            cellName = LocalizedString(@"credits", nil);
            [cell.switch_findmycar setHidden:YES];

          
            break;*/
        case 4:
            
            [[UIUtils singleton] configureLabel:cell.lbl_title withSyle:@"textcenter" size:30 color:[UIColor bleuColor] andText:LocalizedString(@"information", nil)];
            [[UIUtils singleton] configureLabel:cell.lbl_message1 withSyle:@"normal" size:14 color:[UIColor whiteColor] andText:LocalizedString(@"keep_phone_in_pocket", nil)];
            [[UIUtils singleton] configureLabel:cell.lbl_message2 withSyle:@"normal" size:14 color:[UIColor whiteColor] andText:LocalizedString(@"put_phone_in_holder", nil)];
            [[UIUtils singleton] configureLabel:cell.lbl_message3 withSyle:@"normal" size:14 color:[UIColor whiteColor] andText:LocalizedString(@"hand_held_use", nil)];
            [[UIUtils singleton] configureLabel:cell.lbl_message4 withSyle:@"normal" size:14 color:[UIColor whiteColor] andText:LocalizedString(@"not_handsfree_calling", nil)];
            
            

            
          
            break;
             case 5:
            
            cellName=[NSString stringWithFormat:@"ManualSpeed=%f", appDelegate.manual_speed];
            [cell.slider_speed addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            break;
          //  [cell.contentView addSubview:[self infoView]];
            
	}
    
    
    
     [[UIUtils singleton] configureLabel:cell.lbl_item withSyle:@"normal" size:21 color:[UIColor whiteColor] andText:cellName];
	
	cell.backgroundColor = [UIColor clearColor];
	
	return cell;
}



-(UIView *)infoView{


    UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(40, 0, self.view.frame.size.width-80, 240)];
    infoView.tag = 1000;
    infoView.layer.cornerRadius = 8;
    infoView.layer.borderWidth = 1;
    infoView.layer.borderColor = [[UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1.0] CGColor];
    infoView.clipsToBounds = YES;
    infoView.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, infoView.frame.size.width, 20)];
    title.text = @"INFORMATION";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1.0];
    [title setAdjustsFontSizeToFitWidth:YES];
    
    UIImageView* moved = [[UIImageView alloc]initWithFrame:CGRectMake(15, title.frame.size.height+35, 60, 60)];
    [moved setImage:[UIImage imageNamed:@"moved"]];
    
    UIImageView* screen = [[UIImageView alloc]initWithFrame:CGRectMake(15, 160, 60, 60)];
    [screen setImage:[UIImage imageNamed:@"screen"]];
    
    UILabel *movedLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 40, infoView.frame.size.width-100, 90)];
  //  movedLabel.text = LocalizedString(@"earn_point", nil);
    movedLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1.0];
    movedLabel.textAlignment = NSTextAlignmentLeft;
    movedLabel.font = [movedLabel.font fontWithSize:12];
    movedLabel.numberOfLines = 0;
    [movedLabel setMinimumScaleFactor:8.0/[UIFont labelFontSize]];
    [movedLabel setAdjustsFontSizeToFitWidth:YES];
    
    UILabel *screenLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 135, infoView.frame.size.width-100, 90)];
 //   screenLabel.text =LocalizedString(@"loose_point", nil);
    screenLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1.0];
    screenLabel.textAlignment = NSTextAlignmentLeft;
    screenLabel.numberOfLines = 0;
    screenLabel.font = [screenLabel.font fontWithSize:12];
    [screenLabel setMinimumScaleFactor:8.0/[UIFont labelFontSize]];
    [screenLabel setAdjustsFontSizeToFitWidth:YES];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(40, moved.frame.size.height+title.frame.size.height+50, infoView.frame.size.width-80, 1)];
    
    line.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1.0];
    
    [infoView addSubview:title];
    [infoView addSubview:moved];
    [infoView addSubview:line];
    [infoView addSubview:screen];
    [infoView addSubview:movedLabel];
    [infoView addSubview:screenLabel];
    
    UIView *transparentView = [UIView new];
    transparentView.backgroundColor = [UIColor clearColor];
    transparentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //[self.view addGestureRecognizer:self.hideInfoGest];
    //[self.view addSubview:infoView];

    
    
    return  infoView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	id <SlideNavigationContorllerAnimator> revealAnimator;
	CGFloat animationDuration = 0;
	
	switch (indexPath.row)
	{
		case 0:
        {
            revealAnimator = nil;
			animationDuration = .19;
            FAQs *faqs = [self.storyboard instantiateViewControllerWithIdentifier:@"FAQs"];
            [[SlideNavigationController sharedInstance] pushViewController:faqs animated:YES];
        }
			break;
            
            
			
		case 1:
        {
            revealAnimator = [[SlideNavigationContorllerAnimatorSlide alloc] init];
			animationDuration = .19;
            Notification *notificationContoller = [self.storyboard instantiateViewControllerWithIdentifier:@"Notification"];
            [[SlideNavigationController sharedInstance] pushViewController:notificationContoller animated:YES];
        }
            break;
		case 2:
        {
            revealAnimator = [[SlideNavigationContorllerAnimatorFade alloc] init];
			animationDuration = .18;
            MyProfile *myprofile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfile"];
            [[SlideNavigationController sharedInstance] pushViewController:myprofile animated:YES];
        }
			break;
			
	/*	case 3:
            revealAnimator = [[SlideNavigationContorllerAnimatorSlideAndFade alloc] initWithMaximumFadeAlpha:.8 fadeColor:[UIColor blackColor] andSlideMovement:100];
			animationDuration = .19;
            break;*/
			
		case 3:
        {
            revealAnimator = [[SlideNavigationContorllerAnimatorScale alloc] init];
			animationDuration = .22;
            Contactus *contactusController = [self.storyboard instantiateViewControllerWithIdentifier:@"Contactus"];
            [[SlideNavigationController sharedInstance] pushViewController:contactusController animated:YES];
        }
			break;
			
		/*case 5:
        {
            
            
            [[DatabaseManager sharedInstance] updateUncorrectLocation];
            
            [SynchronizationManager sharedInstance].issyncnow=true;
            
            [[SynchronizationManager sharedInstance]startSynchroIfNeeded];
            

            
      
          
            

            
                   }
                  break;*/
            
       /* case 5:
        {

            
            revealAnimator = [[SlideNavigationContorllerAnimatorScaleAndFade alloc] initWithMaximumFadeAlpha:.6 fadeColor:[UIColor blackColor] andMinimumScale:.8];
            animationDuration = .22;
            CreditsViewController *credits = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditsViewController"];
            [[SlideNavigationController sharedInstance] pushViewController:credits animated:YES];
            
            

            
        }
            
            break;*/
			
		default:
			return;
	}
	
	[[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
		[SlideNavigationController sharedInstance].menuRevealAnimationDuration = animationDuration;
		[SlideNavigationController sharedInstance].menuRevealAnimator = revealAnimator;
	}];
    
    
  
    
    
}

@end
