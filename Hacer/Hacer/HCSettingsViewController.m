//
//  HCSettingsViewController.m
//  Hacer
//
//  Created by Sally McNichols on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCSettingsViewController.h"

@interface HCSettingsViewController() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation HCSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UITableView *)makeTableView
{
    CGFloat x = 0;
    CGFloat y = 50;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height - 50;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView.rowHeight = 45;
    tableView.sectionFooterHeight = 22;
    tableView.sectionHeaderHeight = 22;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    return tableView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [self makeTableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newFriendCell"];
    [self.view addSubview:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    /*
    Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = friend.name;
    cell.textLabel.font = [cell.textLabel.font fontWithSize:20];
    cell.imageView.image = [UIImage imageNamed:@"icon57x57"];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Games", friend.gameCount];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    */
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    //NSLog(@"tableview numrows");
   // NSLog(@"%ld",(long)[self.bldg.numFloors integerValue]);
    return 5;
    //return [self.bldg.numFloors integerValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    OFFLoorProfileViewController *form=[[OFFLoorProfileViewController alloc] initWithFloorNum:(indexPath.row+1) withBuilding:self.bldg];
    [self.navigationController pushViewController:form animated:YES];
    */
    NSLog(@"go to floor profile Pressed");
}


@end
