//
//  Chore.h
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Household.h"

@interface Chore : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property (retain) NSDate *dueDate;
@property BOOL isClaimed;
@property (retain) NSString *name;
@property (retain) PFUser *personAssigned;
@property (retain) Household* HH;
@property BOOL finished;
@property NSInteger Credit;
@end

