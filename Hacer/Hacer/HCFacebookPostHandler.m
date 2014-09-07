//
//  HCFacebookPostHandler.m
//  Hacer
//
//  Created by Sally McNichols on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCFacebookPostHandler.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation HCFacebookPostHandler

-(void)updateCurrentUserStatusWithString:(NSString*) message {
    [FBRequestConnection startForPostStatusUpdate:message
                            completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                if (!error) {
                                    // Status update posted successfully to Facebook
                                    NSLog(@"result: %@", result);
                                } else {
                                    // An error occurred, we need to handle the error
                                    // See: https://developers.facebook.com/docs/ios/errors
                                    NSLog(@"%@", error.description);
                                }
                            }];
}

@end
