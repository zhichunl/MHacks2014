//
//  HCDataCenter.h
//  Hacer
//
//  Created by Sally McNichols on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "HCNewChoreViewController.h"

@protocol HCNewsFeedDelegate;

@interface HCDataCenter : NSObject
+(instancetype)sharedCenter;
-(void)registerUser:(id<FBGraphUser>)user;
-(void)loginUser:(id<FBGraphUser>)user;
-(void)fetchAllTasksByDate:(id<HCNewsFeedDelegate>) delegate;
-(NSArray *)getPeopleInHouse;
-(void)saveTask: (HCNewChoreViewController *)ncvc;
@end

@protocol HCNewsFeedDelegate <NSObject>
-(void)newsFeedDataFetched: (NSMutableDictionary *)data;
@end
