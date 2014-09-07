//
//  HCNewChoreViewController.m
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCNewChoreViewController.h"
#import "HCDataCenter.h"
#import "Parse/Parse.h"

@interface HCNewChoreViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@end

@implementation HCNewChoreViewController

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
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
     UIColor *layer = [UIColor colorWithRed:216/255.f green:216/255.f blue:216/255.f alpha:90/255.f];
    self.view.backgroundColor = background;
    self.navigationItem.title = @"New Task";
    self.people = [NSArray array];
    [self findRoommates];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.datePicked setMinimumDate: [NSDate date]];
    self.noOtherPeople.textColor = [UIColor whiteColor];
     self.noOtherPeople.font = [UIFont fontWithName:@"Chalkboard SE Regular" size:20.0f];
    self.pickerView.tintColor = [UIColor whiteColor];
    self.datePicked.tintColor = [UIColor whiteColor];
    self.pickerView.backgroundColor= layer;
    self.datePicked.backgroundColor = layer;
    // Do any additional setup after loading the view from its nib.
}

-(void)findRoommates{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        self.people = [[HCDataCenter sharedCenter] getPeopleInHouse];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pickerView reloadAllComponents];
        });
    });
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([self.people count] == 1){
        self.noOtherPeople.alpha = 1.0;
        self.pickerView.alpha = 0.0;
        return 0;
    }
    return [self.people count] + 1;
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == [self.people count]){
        return @"Unclaimed";
    }
    PFUser *newUser = self.people[row];
    return newUser.username;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
