//
//  HCNewsFeedTableViewCell.h
//  Hacer
//
//  Created by Zhichun Li on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol NFTCellDelegate <NSObject>
-(void)cellClicked: (NSIndexPath *)path;
@end

@interface HCNewsFeedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *taskName;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) NSIndexPath *path;
@property (weak, nonatomic) id<NFTCellDelegate> delegate;
@end
