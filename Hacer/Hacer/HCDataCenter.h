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
#import "Household.h"

@protocol HCNewsFeedDelegate;
@protocol HCPersonalDelegate;
@protocol HCSaveDelegate;

@protocol HCSettingsDelegate <NSObject>
-(void)didFetchSettingsData:(Household*)household people:(NSMutableArray*)people;
@end

@interface HCDataCenter : NSObject
+(instancetype)sharedCenter;
-(void)registerUser:(id<FBGraphUser>)user;
-(void)loginUser:(id<FBGraphUser>)user;
-(void)fetchAllTasksByDate:(id<HCNewsFeedDelegate>) delegate;
-(void)getPersonalInfo:(id<HCPersonalDelegate>)delegate;
-(NSArray *)getPeopleInHouse;
-(void)saveTask: (HCNewChoreViewController *)ncvc del:(id<HCSaveDelegate>)delegate;
-(void)setupSettings:(id<HCSettingsDelegate>)delegate;
@end

@protocol HCNewsFeedDelegate <NSObject>
-(void)newsFeedDataFetched: (NSMutableDictionary *)data;
@end

@protocol HCPersonalDelegate <NSObject>
-(void)personalDataFetched:(NSMutableDictionary *)data;
@end

@protocol HCSaveDelegate <NSObject>
-(void)saved;
@end
