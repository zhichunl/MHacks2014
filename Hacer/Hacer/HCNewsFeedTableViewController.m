//
//  HCNewsFeedTableViewController.m
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCNewsFeedTableViewController.h"
#import "HCDataCenter.h"
#import "HCNewsFeedTableViewCell.h"
#import "Chore.h"
#import "HCNewChoreViewController.h"
#import "FacebookSDK/FacebookSDK.h"

@interface HCNewsFeedTableViewController ()<HCNewsFeedDelegate>
@property NSMutableArray *sections;
@property NSMutableDictionary *dataDict;
@property HCNewChoreViewController *ncvc;
@end

@implementation HCNewsFeedTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)newsFeedDataFetched:(NSMutableDictionary *)data{
    self.dataDict = data;
    self.sections = [[self.dataDict allKeys] mutableCopy];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSMutableArray *tempArray = [NSMutableArray array];
    // fast enumeration of the array
    for (NSString *dateString in self.sections) {
        NSDate *date = [formatter dateFromString:dateString];
        [tempArray addObject:date];
    }
    [tempArray sortUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
        return [date1 compare:date2];
    }];
    NSMutableArray *temp2 = [NSMutableArray array];
    for (NSDate *dateString in tempArray) {
        NSString *date = [formatter stringFromDate:dateString];
        [temp2 addObject:date];
    }
    self.sections = [temp2 copy];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataDict = [NSMutableDictionary dictionary];
    self.sections = [NSMutableArray array];
    UINib *nib = [UINib nibWithNibName:@"HCNewsFeedTableViewCell" bundle:nil];
    // Register this NIB, which contains the cell
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"HCNewsFeedTableViewCell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.title = @"All Tasks";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(_addTask)];
    [[HCDataCenter sharedCenter] fetchAllTasksByDate:self];
}

-(void)_addTask{
    self.ncvc = [[HCNewChoreViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.ncvc];
    self.ncvc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancel)];
    self.ncvc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_saveTask)];
    [self.navigationController presentViewController:nc animated:YES completion:NULL];
}

-(void)_cancel{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

-(void)_saveTask{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [[HCDataCenter sharedCenter] saveTask:self.ncvc];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataDict[self.sections[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCNewsFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HCNewsFeedTableViewCell" forIndexPath:indexPath];
    NSArray *chores = self.dataDict[self.sections[indexPath.section]];
    Chore *curChore = chores[indexPath.row];
    // set taskTitle
    cell.taskName.text = curChore.name;
    NSInteger num = curChore.Credit;
    cell.valueLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFUser *user = (PFUser *)[curChore.personAssigned fetchIfNeeded];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.profilePic.profileID = user[@"facebookID"];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    });
    cell.checkButton.layer.cornerRadius = 5;
    cell.checkButton.layer.masksToBounds = YES;
    cell.profilePic.layer.cornerRadius = 5;
    cell.profilePic.layer.masksToBounds = YES;
    // Configure the cell...
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = [[NSString alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *today = [formatter stringFromDate:[NSDate date]];
    NSDate *startDate = [formatter dateFromString:today];
    NSDate *endDate = [formatter dateFromString:self.sections[section]];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
    if ([components day] == 0)
    {
        title = @"Today";
    }
    else if ([components day] < 0) {
        NSMutableString *difference = [NSMutableString stringWithString:@"Due "];
        [difference appendString:[NSMutableString stringWithFormat:@"%lu", (long)(ABS([components day]))]];
        if (ABS([components day]) == 1)
        {
            [difference appendString:@" Day Ago"];
        }
        else {
            [difference appendString:@" Days Ago"];
        }
        title = difference;
    }
    else {
        NSMutableString *difference = [NSMutableString stringWithString:@"Due In "];
        [difference appendString:[NSMutableString stringWithFormat:@"%lu", (long)[components day]]];
        if ([components day] == 1)
        {
            [difference appendString:@" Day"];
        }
        else {
            [difference appendString:@" Days"];
        }
        title = difference;
    }
    return title;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
