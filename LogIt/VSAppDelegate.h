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
//Stored Deleted Object Array
@property (strong, nonatomic) NSMutableArray *deleteObjects;
//Stored Save Objects Array
@property(strong, nonatomic) NSMutableArray *saveObjects;
//Update Objects Stored
@property(strong, nonatomic)NSMutableArray *updateObjects;

@property(strong, nonatomic) NSUserDefaults *storedData;
//User Stored Objects Saved
@property(strong, nonatomic) NSMutableArray *userVehicles;

@property (strong, nonatomic)VSVehicleInfo *vehicleInfo;

-(BOOL)isConnected;

@end
