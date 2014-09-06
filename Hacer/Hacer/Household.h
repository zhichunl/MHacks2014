//
//  Household.h
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface Household : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property (retain) NSString *name;
@end
