//
//  HCSettingsViewController.m
//  Hacer
//
//  Created by Sally McNichols on 9/6/14.
//  Copyright (c) 2014 XSZ. All rights reserved.
//

#import "HCSettingsViewController.h"
#import "HCDataCenter.h"
#import "Parse/Parse.h"

@interface HCSettingsViewController() <HCSettingsDelegate, UITextViewDelegate, FBFriendPickerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) Household *household;
@property (strong, nonatomic) NSMutableArray *people;
@property (strong, nonatomic) HCDataCenter *dataCenter;
@end

@implementation HCSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)didFetchSettingsData:(Household*)household people:(NSMutableArray*)people {
    self.household = household;
    if(people != nil) {
        self.people = people;
    }
    else
    {
        self.people = [[NSMutableArray alloc] init];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Setting";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPerson)];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    UIColor *layer = [UIColor colorWithRed:216/255.f green:216/255.f blue:216/255.f alpha:90/255.f];
    self.view.backgroundColor = background;
    self.peopleList.textColor = [UIColor whiteColor];
    self.peopleList.font = [UIFont fontWithName:@"Chalkboard SE Regular" size:20.0f];
    self.peopleList.layer.cornerRadius = 5;
    self.peopleList.backgroundColor = layer;
    self.dataCenter = [HCDataCenter sharedCenter];
    [self.dataCenter setupSettings:self];
}
-(void)addPerson
{
    FBFriendPickerViewController *controller = [[FBFriendPickerViewController alloc] init];
    
    controller.delegate = self;
    controller.title = @"Pick Friends to add";
    [controller loadData];
    [controller presentModallyFromViewController:self animated:YES handler:nil];
}

/*
 * Event: Selection changed
 */
- (void)friendPickerViewControllerSelectionDidChange:
(FBFriendPickerViewController *)friendPicker
{
    if([self.people count] == 0) {
        for(int i = 0; i < [friendPicker.selection count]; i++) {
            id <FBGraphUser> user = [friendPicker.selection objectAtIndex:i];
            
            PFQuery *query = [PFUser query];
            [query whereKey:@"facebookID" equalTo:(NSString*)user.objectID];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    for (PFUser *object in objects) {
                        [self.people addObject:object];
                    }
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            
            self.peopleList.text = [NSString stringWithFormat:@"%@, \n, %@", self.peopleList.text,(NSString*)user.name];
            NSLog(@"Added person to empty array");
            return;
        }
    }
    NSLog(@"selection changed");
    for(int i = 0; i < [friendPicker.selection count]; i++) {
        for(int j = 0; j < [self.people count]; j++) {
            NSLog(@"in loop");
            id <FBGraphUser> fbUser = [friendPicker.selection objectAtIndex:i];
            PFUser *user = [self.people objectAtIndex:j];
            
            if (![user[@"facebookID"] isEqualToString:fbUser.objectID]) {
                PFQuery *query = [PFUser query];
                [query whereKey:@"facebookID" equalTo:(NSString*)fbUser.objectID];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        for (PFUser *object in objects) {
                            [self.people addObject:object];
                        }
                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];

                
                if([self.peopleList.text isEqualToString:@""]) {
                    self.peopleList.text = (NSString*)fbUser.name;
                }
                else {
                    self.peopleList.text = [NSString stringWithFormat:@"%@, \n %@", self.peopleList.text,(NSString*)fbUser.name];
                }
            }
        }
    }
}

/*
 * Event: Done button clicked
 */
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    FBFriendPickerViewController *friendPickerController =
    (FBFriendPickerViewController*)sender;
    NSLog(@"Done clicked");
    // Dismiss the friend picker
    [[friendPickerController presentingViewController] dismissModalViewControllerAnimated:YES];
    [self updateData];
}

/*
 * Event: Decide if a given user should be displayed
 */

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id <FBGraphUser>)user
{
    NSString* objId = user.objectID;
    
    for(int i = 0; i < [self.people count]; i++)
    {
        PFUser *person = [self.people objectAtIndex:i];
        if([objId isEqualToString:(NSString*)person[@"facebookID"]])
        {
            return NO;
        }
    }
            return YES;
}

-(void)updateData {
    NSLog(@"%ld", [self.people count]);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        NSString *name = PFUser.currentUser.username;
        [self.household save];
        for(PFUser* person in self.people) {
            person[@"household"] = self.household;
            person[@"weeklyQuota"] = [[NSNumber alloc] initWithInt:[self.creditQuota.text intValue]];
            [PFUser logInWithUsernameInBackground:person.username password:@"password"
                                            block:^(PFUser *user, NSError *error) {
                                                if (user) {
                                                    [person save];
                                                } else {
                                                    // The login failed. Check error to see why.
                                                }
                                            }];
        }
        [PFUser logInWithUsernameInBackground:name password:@"password"
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                (PFUser.currentUser)[@"household"] = self.household;
                                                (PFUser.currentUser)[@"weeklyQuota"] = [[NSNumber alloc] initWithInt:[self.creditQuota.text intValue]];
                                                [PFUser.currentUser save];
                                            } else {
                                                // The login failed. Check error to see why.
                                            }
                                        }];
    });

}

@end
