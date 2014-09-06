//
//  HCPersonalViewController.m
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCPersonalViewController.h"
#import "HCDataCenter.h"

@interface HCPersonalViewController ()<HCPersonalDelegate>

@end

@implementation HCPersonalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)personalDataFetched:(NSMutableDictionary *)data{
    self.userName.text = data[@"userName"];
    self.weeklyQuota.text = data[@"weeklyQuota"];
    self.earnedCredit.text = data[@"earnedCredit"];
    self.accuCredit.text = data[@"accuCredit"];
    self.chores.text = data[@"to_do"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Personal Record";
    [[HCDataCenter sharedCenter] getPersonalInfo:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
