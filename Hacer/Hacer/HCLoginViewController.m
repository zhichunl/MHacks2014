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
    PFQuery *forUser = [PFUser query];
    [forUser whereKey:@"facebookID" equalTo:user.objectID];
    __weak HCLoginViewController *weaksel = self;
    [forUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if ([objects count] == 0){
            [[HCDataCenter sharedCenter] registerUser:user];
        }
        else {
            [[HCDataCenter sharedCenter] loginUser:user];
        }
        [weaksel loadOtherView];
    }];
}

-(void)loadOtherView{
    HCSettingsViewController *svc = [[HCSettingsViewController alloc] init];
    UINavigationController *snc = [[UINavigationController alloc] initWithRootViewController:svc];
    svc.tabBarItem.title = @"Settings";
    HCPersonalViewController *pvc = [[HCPersonalViewController alloc] init];
    UINavigationController *pnc = [[UINavigationController alloc] initWithRootViewController:pvc];
    pvc.tabBarItem.title = @"Personal";
    HCNewsFeedTableViewController *ftvc = [[HCNewsFeedTableViewController alloc] init];
    UINavigationController *fnc = [[UINavigationController alloc] initWithRootViewController:ftvc];
    ftvc.tabBarItem.title = @"News Feed";
    HCHouseholdTableViewController *htvc = [[HCHouseholdTableViewController alloc] init];
    UINavigationController *hnc = [[UINavigationController alloc] initWithRootViewController:htvc];
    htvc.tabBarItem.title = @"Weekly Summary";
    UIImage *setting = [UIImage imageNamed:@"settings-3.png"];
    UIImage *setting_pressed = [UIImage imageNamed:@"settings-3_pressed.png"];
    UIImage *personal = [UIImage imageNamed:@"users.png"];
    UIImage *personal_pressed = [UIImage imageNamed:@"users_pressed.png"];
    UIImage *news = [UIImage imageNamed:@"home.png"];
    UIImage *news_pressed = [UIImage imageNamed:@"home_pressed.png"];
    UIImage *house = [UIImage imageNamed:@"timeline.png"];
    UIImage *house_pressed = [UIImage imageNamed:@"timeline_pressed.png"];
    svc.tabBarItem.image = setting;
    svc.tabBarItem.selectedImage = setting_pressed;
    pvc.tabBarItem.image = personal;
    pvc.tabBarItem.selectedImage = personal_pressed;
    ftvc.tabBarItem.image = news;
    ftvc.tabBarItem.selectedImage = news_pressed;
    htvc.tabBarItem.image = house;
    htvc.tabBarItem.selectedImage = house_pressed;
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.viewControllers = @[fnc, hnc, pnc, snc];
    [self presentViewController:tbc animated:YES completion:NULL];
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
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"logopg.png"]];
    self.view.backgroundColor = background;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    imageView.frame = CGRectMake(7*self.view.bounds.size.width/20, 8*self.view.bounds.size.width/20, 3*self.view.bounds.size.width/10, 3*self.view.bounds.size.width/10);
    [self.view addSubview:imageView];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self.view addSubview:loginView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

