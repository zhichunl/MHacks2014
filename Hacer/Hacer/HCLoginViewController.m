//
//  HCLoginViewController.m
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCLoginViewController.h"
#import "Parse/Parse.h"
#import <FacebookSDK/FacebookSDK.h>
#import "HCDataCenter.h"
#import "HCSettingsViewController.h"
#import "HCPersonalViewController.h"
#import "HCNewsFeedTableViewController.h"
#import "HCHouseholdTableViewController.h"


@interface HCLoginViewController ()<FBLoginViewDelegate>
@property (atomic, assign) BOOL registered;
@end

@implementation HCLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//fetching user info to upload to parse
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    if (!self.registered){
        PFQuery *forUser = [PFUser query];
        [forUser whereKey:@"facebookID" equalTo:user.objectID];
        [forUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if ([objects count] == 0){
                [[HCDataCenter sharedCenter] registerUser:user];
            }
            else {
                [[HCDataCenter sharedCenter] loginUser:user];
            }
        }];
        self.registered = YES;
    }
}

//the action after user login.
-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    HCSettingsViewController *svc = [[HCSettingsViewController alloc] init];
    svc.tabBarItem.title = @"Settings";
    HCPersonalViewController *pvc = [[HCPersonalViewController alloc] init];
    pvc.tabBarItem.title = @"Personal";
    UINavigationController *pnc = [[UINavigationController alloc] initWithRootViewController:pvc];
    pnc.tabBarItem.title = @"Personal";
    HCNewsFeedTableViewController *ftvc = [[HCNewsFeedTableViewController alloc] init];
    UINavigationController *fnc = [[UINavigationController alloc] initWithRootViewController:ftvc];
    fnc.tabBarItem.title = @"News Feed";
    HCHouseholdTableViewController *htvc = [[HCHouseholdTableViewController alloc] init];
    UINavigationController *hnc = [[UINavigationController alloc] initWithRootViewController:htvc];
    hnc.tabBarItem.title = @"Household";
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.viewControllers = @[fnc, hnc, pnc, svc];
    [self.navigationController presentViewController:tbc animated:YES completion:NULL];
    UIImage *setting = [UIImage imageNamed:@"settings-3.png"];
    UIImage *setting_pressed = [UIImage imageNamed:@"settings-3_pressed.png"];
    UIImage *personal = [UIImage imageNamed:@"users.png"];
    UIImage *personal_pressed = [UIImage imageNamed:@"users_pressed.png"];
    UIImage *news = [UIImage imageNamed:@"home.png"];
    UIImage *news_pressed = [UIImage imageNamed:@"home_pressed.png"];
    UIImage *house = [UIImage imageNamed:@"time.png"];
    UIImage *house_pressed = [UIImage imageNamed:@"time_pressed.png"];
    svc.tabBarItem.image = setting;
    svc.tabBarItem.selectedImage = setting_pressed;
    pvc.tabBarItem.image = personal;
    pvc.tabBarItem.selectedImage = personal_pressed;
    ftvc.tabBarItem.image = news;
    ftvc.tabBarItem.selectedImage = news_pressed;
    htvc.tabBarItem.image = house;
    htvc.tabBarItem.selectedImage = house_pressed;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"ViewDidLoad Start");
    FBLoginView *loginView = [[FBLoginView alloc]initWithReadPermissions:
                              @[@"public_profile", @"email", @"user_friends"]];
    loginView.delegate = self;
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 3*self.view.bounds.size.height/5);
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.view.backgroundColor = background;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self.view addSubview:loginView];
    self.registered = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

