//
//  HCTaskDetailViewController.h
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCTaskDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *NameAndCredit;
@property (weak, nonatomic) IBOutlet UILabel *dueDate;
@property (weak, nonatomic) IBOutlet UILabel *AssignedTo;
@property (weak, nonatomic) IBOutlet UILabel *finished;
@property (weak, nonatomic) IBOutlet UIButton *claimButton;
@end
