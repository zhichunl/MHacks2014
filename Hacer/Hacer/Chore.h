//
//  Chore.h
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface Chore : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property (retain) NSDate *dueDate;
@property BOOL isClaimed;
@property (retain) NSString *name;
@property (retain) PFUser *personAssigned;
@end

