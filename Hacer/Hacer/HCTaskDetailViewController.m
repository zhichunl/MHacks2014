//
//  HCTaskDetailViewController.m
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCTaskDetailViewController.h"

@interface HCTaskDetailViewController ()

@end

@implementation HCTaskDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.NameAndCredit.text = self.name;
    self.dueDate.text = self.date;
    self.AssignedTo.text = self.person;
    self.finished.text = self.completed;
    if (!self.claimed){
        self.claimButton.alpha = 1.0;
        self.AssignedTo.text = @"Not assigned to anyone!";
    }
    else{
        self.claimButton.alpha = 0.0;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
