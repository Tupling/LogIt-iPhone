//
//  VSAppDelegate.m
//  LogIt
//
//  Created by Dale Tupling on 5/5/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSAppDelegate.h"
#import <Parse/Parse.h>
#import "VSViewController.h"
#import "VSVehicles.h"



@implementation VSAppDelegate
{
    NSData *storedObjectsToDelete;
    NSArray *unarchivedObjects;
    VSViewController *mainViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Required
    //Parse App ID and Key
    
    [Parse setApplicationId:@"dmSu69A9G1bgTrZYXMP3pAby8fiwYdefw8tXjumi"
                  clientKey:@"5Ug218rLZApSrZw7XsSi8NIaQhEuTh1gZU7VPMFg"];
    
    //Set Notification center and Monitor Network Status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitorNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    //set Network status reachabilityt to internetConnection
    self.networkStatus = [Reachability reachabilityForInternetConnection];
    
    
    //Set Userdefaults
    self.storedData = [NSUserDefaults standardUserDefaults];
    
    //Initiate userVehicles Array
    if(self.userVehicles != nil){
        NSData *storedVehicleData = [ApplicationDelegate.storedData objectForKey:@"userVehicles"];
        if (storedVehicleData != nil) {
            NSArray *storedVehicleArray = [NSKeyedUnarchiver unarchiveObjectWithData:storedVehicleData];
            if (storedVehicleData != nil) {
                self.userVehicles = [NSMutableArray arrayWithArray:storedVehicleArray];
            }
        }
        
    }else{
        self.userVehicles = [[NSMutableArray alloc] init];
    }
    
    
    //Set deleteobjects array to data stored in userdefault object deleteObject
    //This data is stored in VSViewController if user deletes an object or objects
    //and while offline. This data will be saved even if the user closes the application.
    storedObjectsToDelete = [ApplicationDelegate.storedData objectForKey:@"deleteObject"];
    if(storedObjectsToDelete != nil){
        unarchivedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:storedObjectsToDelete];
        if (unarchivedObjects != nil) {
            self.deleteObjects = [NSMutableArray arrayWithArray:unarchivedObjects];
        }
    }else{
        self.deleteObjects = [[NSMutableArray alloc] init];
    }
    
    //get UserVehicles from Defaults
    NSData *storedVehicleData = [self.storedData objectForKey:@"userVehicles"];
    if(storedVehicleData != nil){
        NSArray *unarchivedArray = [NSKeyedUnarchiver unarchiveObjectWithData:storedVehicleData];
        if(unarchivedArray != nil){
            self.userVehicles = [NSMutableArray arrayWithArray:unarchivedArray];
        }
    }
    
    return YES;
}

//method for monitoring network status
-(void)monitorNetworkStatus:(NSNotification *)notification {
    
    NetworkStatus netStatus = [self.networkStatus currentReachabilityStatus];
    
    //Check if network is reachable or not regardless of user on wifi or mobile data
    if (netStatus == NotReachable) {
        
        NSLog(@"NO NETWORK CONNECTION STATUS CODE = %ld", [self.networkStatus currentReachabilityStatus]);
        
    }else if (netStatus == ReachableViaWiFi || netStatus == ReachableViaWWAN){
        
        NSLog(@"NETWORK CONNECTION AVAILABLE STATUS CODE = %ld", [self.networkStatus currentReachabilityStatus]);
    }
    
    
    
}


//Check for network Connection
-(BOOL)isConnected
{
    Reachability *connected = [Reachability reachabilityWithHostName:@"www.daletupling.com"];
    
    NetworkStatus status = [connected currentReachabilityStatus];
    
    return status;
}
-(void)deleteSavedUserDefaults:(NSArray *)arhiveArray
{
    self.deleteObjects = [[NSMutableArray alloc] initWithArray:arhiveArray];
    if (self.deleteObjects != nil) {
        if (self.isConnected == YES) {
            
            for (int i = 0; i < self.deleteObjects.count; i++) {
                VSVehicleInfo *vehicleInfo = [self.deleteObjects objectAtIndex:i];
                NSString *objectIdString = vehicleInfo.vObjectId;
                
                PFQuery *deleteQuery = [PFQuery queryWithClassName:@"Vehicles"];
                PFObject *object = [deleteQuery getObjectWithId:objectIdString];
                
                [object deleteInBackground];
            }
            NSLog(@"All objects have been removed from the server");
            [self.deleteObjects removeAllObjects];
            NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:self.deleteObjects];
            [ApplicationDelegate.storedData setObject:vehicleData forKey:@"deleteObject"];
            [ApplicationDelegate.storedData synchronize];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (self.storedData != nil) {
        NSData *dataArray = [self.storedData objectForKey:@"userVehicles"];
        if(dataArray != nil){
            NSArray *defaultArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
            self.userVehicles = [NSMutableArray arrayWithArray:defaultArray];
            NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:self.userVehicles];
            [self.storedData setObject:vehicleData forKey:@"userVehicles"];
        }else {
            NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:self.userVehicles];
            [self.storedData setObject:vehicleData forKey:@"userVehicles"];
        }
        [self.storedData synchronize];
    }
}

@end
