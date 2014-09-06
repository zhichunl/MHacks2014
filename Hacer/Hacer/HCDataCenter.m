//
//  HCDataCenter.m
//  Hacer
//
//  Created by Sally McNichols on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCDataCenter.h"

@implementation HCDataCenter

+ (instancetype)dataCenter {
    static HCDataCenter *dataCenter = nil;
    
    if (dataCenter == nil) {
        dataCenter = [[HCDataCenter alloc] init];
    }
    
    return dataCenter;
}



@end
