//
//  CountryListViewController.m
//  Country List
//
//  Created by Pradyumna Doddala on 18/12/13.
//  Copyright (c) 2013 Pradyumna Doddala. All rights reserved.
//

#import "CountryListViewController.h"
#import "CountryListDataSource.h"
#import "CountryCell.h"
#import "UIUtils.h"
#import "Localization.h"
@interface CountryListViewController ()
{

    CountryListDataSource *dataSource;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataRows;
@end

@implementation CountryListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil delegate:(id)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        _delegate = delegate;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     dataSource = [[CountryListDataSource alloc] init];
    _dataRows = [[dataSource countries] mutableCopy];
    [_tableView reloadData];
    [_txt_search addTarget:self
                    action:@selector(txt_changed:)
          forControlEvents:UIControlEventEditingChanged];
    _txt_search.layer.borderWidth = 1.0f;
    _txt_search.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [[UIUtils singleton]configureField:_txt_search withSyle:@"normal" size:15 color:[UIColor bleuColor] andHint:@"Search Country"];
    
    
    
    
    
    self.navigationController.navigationBarHidden=YES;
    
    
    
    
     _txt_search.returnKeyType = UIReturnKeyContinue;
    
    
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    

    
    
    return YES;
}
-(void)txt_changed:(id)sender{
    [_dataRows removeAllObjects];
    NSMutableArray *temp = [NSMutableArray array];
    temp=(NSMutableArray *)[dataSource countries];
    for(NSDictionary *desireCountry in temp)
    {
        //[[_dataRows objectAtIndex:indexPath.row] valueForKey:kCountryName];
        NSString *wineName = [desireCountry objectForKey:kCountryName];
        NSRange range = [wineName rangeOfString:_txt_search.text options:NSCaseInsensitiveSearch];
        if(range.location != NSNotFound)
            [_dataRows addObject:desireCountry];
    }
    if(_txt_search.text.length<1){
     _dataRows = [[dataSource countries] mutableCopy];
    }
    else{
    [_dataRows addObjectsFromArray:temp];
    }
    [_tableView reloadData];
    NSLog(@"I am changing");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    CountryCell *cell = (CountryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[CountryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    if ([[_dataRows objectAtIndex:indexPath.row] valueForKey:kCountryCallingCode]  != [NSNull null])
    {
        cell.textLabel.text = [[_dataRows objectAtIndex:indexPath.row] valueForKey:kCountryName];
    cell.detailTextLabel.text = [[_dataRows objectAtIndex:indexPath.row] valueForKey:kCountryCallingCode];
    }
    return cell;
}

#pragma mark - UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -
#pragma mark Actions

- (IBAction)done:(id)sender
{
    if ([_delegate respondsToSelector:@selector(didSelectCountry:)]) {
        [self.delegate didSelectCountry:[_dataRows objectAtIndex:[_tableView indexPathForSelectedRow].row]];
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        NSLog(@"CountryListView Delegate : didSelectCountry not implemented");
    }
}

@end
