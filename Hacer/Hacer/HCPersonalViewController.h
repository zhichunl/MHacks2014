//
//  HCPersonalViewController.h
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCPersonalViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navigation;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *earnedCredit;
@property (weak, nonatomic) IBOutlet UILabel *accuCredit;
@property (weak, nonatomic) IBOutlet UILabel *weeklyQuota;
@property (weak, nonatomic) IBOutlet UITextView *chores;

@end
