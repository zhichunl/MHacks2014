//
//  HCTaskDetailViewController.h
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCTaskDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *NameAndValue;

@property (strong, nonatomic) NSString *name;
@property (weak, nonatomic) IBOutlet UILabel *dueDate;
@property (strong, nonatomic) NSString *date;
@property (weak, nonatomic) IBOutlet UILabel *AssignedTo;
@property (strong, nonatomic) NSString *person;
@property (weak, nonatomic) IBOutlet UILabel *finished;
@property (strong, nonatomic) NSString *completed;
-(void)claimButtonPressed;
@property BOOL claimed;
@end
