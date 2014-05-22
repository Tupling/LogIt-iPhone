//
//  VSAppDelegate.h
//  LogIt
//
//  Created by Dale Tupling on 5/5/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "VSVehicles.h"
#import "VSVehicleInfo.h"

#define ApplicationDelegate ((SSAppDelegate *)[UIApplication sharedApplication].delegate)

@interface VSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


-(BOOL)isConnected;

@end
