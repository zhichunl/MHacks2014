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
#import "MBProgressHUD.h"
#import "HCTaskDetailViewController.h"

@interface HCNewsFeedTableViewController ()<HCNewsFeedDelegate, NFTCellDelegate, HCSaveDelegate>
@property NSMutableArray *sections;
@property NSMutableDictionary *dataDict;
@property HCNewChoreViewController *ncvc;
@property UIRefreshControl* refreshControl;
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
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.view.backgroundColor = background;
    self.dataDict = [NSMutableDictionary dictionary];
    self.sections = [NSMutableArray array];
    UINib *nib = [UINib nibWithNibName:@"HCNewsFeedTableViewCell" bundle:nil];
    // Register this NIB, which contains the cell
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"HCNewsFeedTableViewCell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.title = @"All Chores";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(_addTask)];
    [[HCDataCenter sharedCenter] fetchAllTasksByDate:self];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refreshControl addTarget:self action:@selector(updateTable) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
}

-(void)updateTable{
    [[HCDataCenter sharedCenter] fetchAllTasksByDate:self];
    [self.refreshControl endRefreshing];
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
    if ([self.ncvc.nameField.text length] <= 0){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please enter a name!" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [message show];
        return;
    }
    else if ([self.ncvc.valueField.text length] <= 0){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please enter a credit value!" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [message show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.ncvc.view animated:YES];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [[HCDataCenter sharedCenter] saveTask:self.ncvc del:self];
    });
}

-(void)saved{
    [MBProgressHUD hideAllHUDsForView:self.ncvc.view animated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    [[HCDataCenter sharedCenter] fetchAllTasksByDate:self];
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
    cell.checkButton.enabled = YES;
    cell.valueLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFUser *user = (PFUser *)[curChore.personAssigned fetchIfNeeded];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.profilePic.profileID = user[@"facebookID"];
        });
    });
    if (curChore.finished){
        [cell.checkButton setBackgroundImage:[UIImage imageNamed:@"heart-full.png"] forState:UIControlStateNormal];
    }
    else{
        [cell.checkButton setBackgroundImage:[UIImage imageNamed:@"heart-empty.png"] forState:UIControlStateNormal];
    }
    cell.layer.cornerRadius = 10;
    cell.delegate = self;
    cell.path = indexPath;
    cell.checkButton.layer.cornerRadius = 5;
    cell.checkButton.layer.masksToBounds = YES;
    cell.profilePic.layer.cornerRadius = 15;
    cell.profilePic.layer.masksToBounds = YES;
    UIColor *layer = [UIColor colorWithRed:216/255.f green:216/255.f blue:216/255.f alpha:90/255.f];
    cell.backgroundColor = layer;
    cell.taskName.font = [UIFont fontWithName:@"Chalkboard SE Bold" size:17.0f];
    cell.taskName.textColor = [UIColor whiteColor];
    cell.valueLabel.font = [UIFont fontWithName:@"Chalkboard SE Bold" size:17.0f];
    cell.valueLabel.textColor = [UIColor whiteColor];
    return cell;
}

-(void)cellClicked:(NSIndexPath *)path{
    NSArray *chores = self.dataDict[self.sections[path.section]];
    Chore *curChore = chores[path.row];
    if (curChore.finished == YES){
        return;
    }
    HCNewsFeedTableViewCell *cell = (HCNewsFeedTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
    if (![cell.profilePic.profileID isEqualToString:(PFUser.currentUser)[@"facebookID"]]){
        return;
    }
    curChore.finished = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [curChore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    }];
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HCTaskDetailViewController* tdvc = [[HCTaskDetailViewController alloc] init];
    NSArray *chores = self.dataDict[self.sections[indexPath.section]];
    Chore *curChore = chores[indexPath.row];
    tdvc.navigationItem.title = curChore.name;
    tdvc.curChore = curChore;
    tdvc.name = [NSString stringWithFormat:@"%@ with a value of %ld credit(s).", curChore.name, curChore.Credit];
    tdvc.date = [NSString stringWithFormat:@"Due on %@.", self.sections[indexPath.section]];
    if (curChore.finished){
        tdvc.completed = @"The task has been completed.";
    }
    else{
        tdvc.completed = @"The task hasn't been completed.";
    }
    tdvc.claimed = curChore.isClaimed;
    if (curChore.personAssigned){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            PFUser *user = (PFUser *)[curChore.personAssigned fetchIfNeeded];
            dispatch_async(dispatch_get_main_queue(), ^{
                tdvc.person = [NSString stringWithFormat:@"Assigned to %@", user.username];
                tdvc.AssignedTo.text = [NSString stringWithFormat:@"Assigned to %@", user.username];
                [tdvc.view setNeedsDisplay];
            });
        });
    }
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:tdvc];
    tdvc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationController presentViewController:nc animated:YES completion:NULL];
}

-(void)done{
    [[HCDataCenter sharedCenter] fetchAllTasksByDate:self];
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSArray *chores = self.dataDict[self.sections[indexPath.section]];
        Chore *curChore = chores[indexPath.row];
        [curChore deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded){
                [[HCDataCenter sharedCenter] fetchAllTasksByDate:self];
            }
        }];
    }
}

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
