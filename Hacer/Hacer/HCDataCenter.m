//
//  HCDataCenter.m
//  Hacer
//
//  Created by Sally McNichols on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCDataCenter.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Parse/Parse.h"

@implementation HCDataCenter

+ (instancetype)sharedCenter {
    static HCDataCenter *sharedCenter = nil;
    
    if (sharedCenter == nil) {
        sharedCenter = [[HCDataCenter alloc] init];
    }
    
    return sharedCenter;
}

-(void)registerUser:(id<FBGraphUser>)user{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFUser *newUser = [PFUser user];
        newUser[@"username"] = user.name;
        newUser.password = @"password";
        newUser[@"facebookID"] = user.objectID;
        [newUser signUp];
        [newUser save];
    });
}

-(void)loginUser:(id<FBGraphUser>)user{
    [PFUser logInWithUsernameInBackground:user.name password:@"password"
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            // Do stuff after successful login.
                                        } else {
                                            // The login failed. Check error to see why.
                                        }
                                    }];
}

@end
