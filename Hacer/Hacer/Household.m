//
//  Household.m
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "Household.h"
#import <Parse/PFObject+Subclass.h>

@implementation Household
+ (void)load {
    [self registerSubclass];
}
+ (NSString *)parseClassName{
    return @"Household";
}
@dynamic name;
@end
