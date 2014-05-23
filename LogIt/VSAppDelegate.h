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

#define ApplicationDelegate ((VSAppDelegate *)[UIApplication sharedApplication].delegate)

@interface VSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) Reachability *networkStatus;
@property (strong, nonatomic) NSMutableArray *deleteObjects;
@property(strong, nonatomic) NSMutableArray *saveObjects;
@property(strong, nonatomic) NSUserDefaults *storedData;
@property (strong, nonatomic)VSVehicleInfo *vehicleInfo;

-(BOOL)isConnected;

@end
