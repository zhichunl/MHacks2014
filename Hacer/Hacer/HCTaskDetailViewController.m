//
//  HCTaskDetailViewController.m
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCTaskDetailViewController.h"
#import "MBProgressHUD.h"

@interface HCTaskDetailViewController ()
@property (strong, nonatomic) UIButton *button;
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
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.button addTarget:self
               action:@selector(claimButtonPressed)forControlEvents:UIControlEventTouchUpInside];
    [self.button setTitle:@"Claim it!" forState:UIControlStateNormal];
    
    self.button.frame = CGRectMake(137.0, 459.0, 56.0, 30.0);
    
    [self.view addSubview:self.button];
    
    [super viewDidLoad];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    UIColor *layer = [UIColor colorWithRed:216/255.f green:216/255.f blue:216/255.f alpha:90/255.f];
    self.view.backgroundColor = background;
    self.NameAndValue.text = self.name;
    self.NameAndValue.textColor = [UIColor whiteColor];
    self.NameAndValue.font = [UIFont fontWithName:@"Chalkboard SE Regular" size:20.0f];
    self.NameAndValue.layer.cornerRadius = 5;
    self.NameAndValue.backgroundColor = layer;
    self.dueDate.text = self.date;
    self.dueDate.font = [UIFont fontWithName:@"Chalkboard SE Regular" size:20.0f];
    self.AssignedTo.text = self.person;
    self.AssignedTo.font = [UIFont fontWithName:@"Chalkboard SE Regular" size:20.0f];
    self.finished.font = [UIFont fontWithName:@"Chalkboard SE Regular" size:20.0f];
    self.finished.text = self.completed;
    if (!self.claimed){
        //self.button.alpha = 1.0;
        self.AssignedTo.text = @"Not assigned to anyone!";
    }
    else{
        //self.button.alpha = 0.0;
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)claimButtonPressed {
    self.curChore.personAssigned = PFUser.currentUser;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.curChore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
