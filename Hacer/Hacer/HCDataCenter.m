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
#import "Chore.h"
#import "Household.h"

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

-(void)fetchAllTasksByDate:(id<HCNewsFeedDelegate>)delegate{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFQuery *query = [Chore query];
        Household* curHousehold = (PFUser.currentUser)[@"household"];
        if (curHousehold){
            [query whereKey:@"HH" equalTo:curHousehold];
            NSArray *chores = [query findObjects];
            NSMutableDictionary *choresF = [NSMutableDictionary dictionary];
            for (Chore* c in chores) {
                Chore* cf = (Chore *)[c fetchIfNeeded];
                NSDate *dueDate = cf.dueDate;
                NSDateFormatter *dformat = [[NSDateFormatter alloc]init];
                [dformat setDateFormat:@"yyyy-MM-dd"];
                NSString *due = [dformat stringFromDate:dueDate];
                if ([choresF objectForKey:due] == nil){
                    choresF[due] = @[cf];
                }
                else{
                    NSMutableArray *array = [choresF[due] mutableCopy];
                    [array addObject:due];
                    choresF[due] = array;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate newsFeedDataFetched:choresF];
            });
        }
        else{
            [query whereKey:@"personAssigned" equalTo:PFUser.currentUser];
            NSArray *chores = [query findObjects];
            NSMutableDictionary *choresF = [NSMutableDictionary dictionary];
            for (Chore* c in chores) {
                Chore* cf = (Chore *)[c fetchIfNeeded];
                NSDate *dueDate = cf.dueDate;
                NSDateFormatter *dformat = [[NSDateFormatter alloc]init];
                [dformat setDateFormat:@"MM/dd/yyyy"];
                NSString *due = [dformat stringFromDate:dueDate];
                if ([choresF objectForKey:due] == nil){
                    choresF[due] = @[cf];
                }
                else{
                    NSMutableArray *array = [choresF[due] mutableCopy];
                    [array addObject:cf];
                    choresF[due] = array;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate newsFeedDataFetched:choresF];
            });
        }
            
        
    });
}

-(NSArray *)getPeopleInHouse{
    Household *curHouse = (PFUser.currentUser)[@"household"];
    if (curHouse){
        PFQuery *query = [PFUser query];
        [query whereKey:@"household" equalTo:curHouse];
        NSArray *people = [query findObjects];
        return people;
    }
    else{
        return @[PFUser.currentUser];
    }
}
-(void)getPersonalInfo:(id<HCPersonalDelegate>)delegate{
    PFObject *user = PFUser.currentUser;
    NSUInteger weeklyQuota = user[@"weeklyQuota"];
    NSUInteger accuCredit = user[@"accuQuota"];
    NSUInteger earnedQuota = 0;
    NSString *userName = user[@"username"];
    PFQuery *fquery = [Chore query];
    [fquery whereKey:@"personAssigned" equalTo:user];
    [fquery whereKey:@"finished" equalTo:[[NSNumber alloc] initWithBool: true]];
    NSArray *finished = [fquery findObjects];
    for (Chore* c in finished ){
        earnedQuota = earnedQuota + (NSUInteger)c[@"Credit"];
    }
    PFQuery *tquery = [PFQuery queryWithClassName:@"Chore"];
    [tquery whereKey:@"personAssigned" equalTo:user];
    [tquery whereKey:@"finished" equalTo:[[NSNumber alloc] initWithBool: false]];
    NSArray *incomplete = [tquery findObjects];
    NSString *to_do = @"";
    for (Chore *c in incomplete){
        to_do = [NSString stringWithFormat:@"%@ \n %@", to_do, c[@"name"]];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"userName"] = userName;
    userInfo[@"weeklyQuota"] = [NSString stringWithFormat:@"%ld", weeklyQuota];
    userInfo[@"accuCredit"] = [NSString stringWithFormat:@"%ld", accuCredit];
    userInfo[@"earnedCredit"] = [NSString stringWithFormat:@"%ld", earnedQuota];
    userInfo[@"to_do"] = to_do;
    [delegate personalDataFetched:userInfo];
}

-(void)saveTask:(HCNewChoreViewController *)ncvc{
    Chore* newChore = [Chore object];
    newChore.name = ncvc.nameField.text;
    newChore.finished = NO;
    newChore.dueDate = ncvc.datePicked.date;
    NSInteger count = [ncvc.pickerView selectedRowInComponent:0];
    if (ncvc.noOtherPeople.alpha == 1.0){
        newChore.personAssigned = PFUser.currentUser;
        newChore.isClaimed = YES;
    }
    else if (count == [ncvc.people count]){
        newChore.isClaimed = NO;
    }
    else{
        newChore.isClaimed = YES;
        newChore.personAssigned = ncvc.people[count];
    }
    newChore.Credit = [ncvc.valueField.text intValue];
    [newChore save];
}

@end
