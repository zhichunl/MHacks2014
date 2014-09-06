//
//  Chore.m
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "Chore.h"
#import <Parse/PFObject+Subclass.h>

@implementation Chore
+ (void)load {
    [self registerSubclass];
}
+ (NSString *)parseClassName {
    return @"Chore";
}
@dynamic dueDate;
@dynamic isClaimed;
@dynamic name;
@dynamic personAssigned;
@dynamic HH;
@dynamic finished;
@dynamic Credit;
@end
