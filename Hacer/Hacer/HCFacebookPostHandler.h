//
//  HCFacebookPostHandler.h
//  Hacer
//
//  Created by Sally McNichols on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface HCFacebookPostHandler : NSObject
-(void)updateCurrentUserStatusWithString:(NSString*) message;
@end
