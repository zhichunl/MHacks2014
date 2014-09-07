//
//  HCHouseholdTableViewController.m
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCHouseholdTableViewController.h"
#import "HCDataCenter.h"
#import "HCNewsFeedTableViewCell.h"
#import "Chore.h"
#import "MBProgressHUD.h"

@interface HCHouseholdTableViewController ()<HCHouseholdDelegate>
@property (strong, nonatomic) NSMutableArray *people;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NSDictionary *valDict;
@property UIRefreshControl* refreshControl;
@end

@implementation HCHouseholdTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dataFetched:(NSDictionary *)dict valueDict:(NSDictionary *)valDict{
    self.people = [[dict allKeys] mutableCopy];
    self.dict = dict;
    self.valDict = valDict;
    [self.people sortUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
        return [valDict[s1] compare: valDict[s2]];
    }];
    self.people = [[[self.people reverseObjectEnumerator] allObjects] mutableCopy];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Rankings";
    self.people = [NSMutableArray array];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(queue, ^{
        [[HCDataCenter sharedCenter] fetchAllTasksbyPeople:self];
    });
    UINib *nib = [UINib nibWithNibName:@"HCNewsFeedTableViewCell" bundle:nil];
    // Register this NIB, which contains the cell
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"HCNewsFeedTableViewCell"];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refreshControl addTarget:self action:@selector(updateTable) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;

}

-(void)updateTable{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [[HCDataCenter sharedCenter] fetchAllTasksbyPeople:self];
    });
    [self.refreshControl endRefreshing];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [[HCDataCenter sharedCenter] fetchAllTasksbyPeople:self];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.people count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *curA = self.dict[self.people[section]];
    return [curA count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCNewsFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HCNewsFeedTableViewCell" forIndexPath:indexPath];
    NSArray *chores = self.dict[self.people[indexPath.section]];
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
        });
    });
    if (curChore.finished){
        [cell.checkButton setBackgroundImage:[UIImage imageNamed:@"heart-full.png"] forState:UIControlStateNormal];
    }
    else{
        [cell.checkButton setBackgroundImage:[UIImage imageNamed:@"heart-empty.png"] forState:UIControlStateNormal];
    }
    cell.layer.cornerRadius = 10;
    cell.path = indexPath;
    cell.checkButton.layer.cornerRadius = 5;
    cell.checkButton.enabled = NO;
    cell.checkButton.layer.masksToBounds = YES;
    cell.profilePic.layer.cornerRadius = 15;
    cell.profilePic.layer.masksToBounds = YES;
    UIColor *layer = [UIColor colorWithRed:216/255.f green:216/255.f blue:216/255.f alpha:90/255.f];
    cell.backgroundColor = layer;
    cell.taskName.font = [UIFont fontWithName:@"Chalkboard SE Bold" size:17.0f];
    cell.taskName.textColor = [UIColor whiteColor];
    cell.valueLabel.font = [UIFont fontWithName:@"Chalkboard SE Bold" size:17.0f];
    cell.valueLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *name = self.people[section];
    NSNumber *totValue = self.valDict[name];
    return [NSString stringWithFormat:@"%@ has %@ credit(s).", name, totValue];
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
