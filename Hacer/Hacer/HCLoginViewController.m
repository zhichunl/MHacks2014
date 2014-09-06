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

@interface HCLoginViewController ()<FBLoginViewDelegate>
@property (atomic, assign) BOOL registered;
@property (strong, nonatomic) UIAlertView *message;
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
    NSLog(@"loginViewFetchedUserInfo");
    if (!self.registered){
        PFQuery *forUser = [PFUser query];
        [forUser whereKey:@"profileID" equalTo:user.objectID];
        [forUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if ([objects count] == 0){
                //[[FBUDataCenter sharedCenter] registerUser:user];
            }
            else {
                //[[FBUDataCenter sharedCenter] loginUser:user];
            }
        }];
        self.registered = YES;
    }
    //UIBarButtonItem* next = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(_loadAlertView)];
    //self.navigationItem.rightBarButtonItem = next;
}

//the action after user login.
-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
   
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
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"LoginWITHwhiteBar.png"]];
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

