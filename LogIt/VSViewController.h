//
//  VSViewController.h
//  LogIt
//
//  Created by Dale Tupling on 5/5/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "VSVehicleInfo.h"
#import "VSVehicles.h"
#import "Reachability.h"


@interface VSViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
{

}

-(IBAction)logOut:(id)sender;

@property (nonatomic, strong) VSVehicles* vehicles;
@property (nonatomic, strong) VSVehicleInfo *vehicleInfo;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *vehicleArr;
@property(nonatomic, strong)  NSDate *lastSync;
@property(strong, nonatomic) Reachability *networkStatus;

-(void)loading:(NSString*)msg;

@end
