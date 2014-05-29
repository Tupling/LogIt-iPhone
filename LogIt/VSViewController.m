//
//  VSViewController.m
//  LogIt
//
//  Created by Dale Tupling on 5/5/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSViewController.h"
#import "VSVehicleDetailsController.h"
#import "VSAddVehicleController.h"
#import "VSAppDelegate.h"
#import "Reachability.h"

@interface VSViewController () <UIAlertViewDelegate>
{
    UIActivityIndicatorView *loading;
    UIAlertView *loadingAlert;
    UIAlertView *logOutAlert;
    UIAlertView *deleteObject;
    PFQuery *query;
    BOOL objectUpdated;
    NSTimer *autoCall;
    int objectCount;
}

@end



@implementation VSViewController

-(void)viewWillAppear:(BOOL)animated
{
    [ApplicationDelegate.networkStatus startNotifier];
    
    NSLog(@"Network Connect = %d", ApplicationDelegate.isConnected);
    if (ApplicationDelegate.isConnected == NO) {
        
        NSData *storedVehicleData = [ApplicationDelegate.storedData objectForKey:@"userVehicles"];
        if (storedVehicleData != nil) {
            NSArray *storedVehicleArray = [NSKeyedUnarchiver unarchiveObjectWithData:storedVehicleData];
            if (storedVehicleData != nil) {
                ApplicationDelegate.userVehicles = [NSMutableArray arrayWithArray:storedVehicleArray];
            }
        }
        
        NSLog(@"ARRAY COUNT = %lu", (unsigned long)ApplicationDelegate.userVehicles.count);
        
        [self.tableView reloadData];
        autoCall = [NSTimer scheduledTimerWithTimeInterval:25.0f target:self selector:@selector(syncData:) userInfo:nil repeats:YES];
        
    }else{
        if ([PFUser currentUser]) {
            
            [self syncData:nil];
            
            
            
        }else{
            
            [self requireLogin];
        }
        
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    
}


#pragma mark -
#pragma SYNC DATA
-(void)syncData:(NSTimer *)timer{
    
    //Ensure Sync Method is only executed when active connection exist
    if (ApplicationDelegate.isConnected == YES) {
        
        
        //Sync offline edited objects
        [self syncOfflineEditedObject];
        
        
        query = [PFQuery queryWithClassName:@"Vehicles"];
        //Get ObjectCount from Server and compare to vehicleArr count
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            objectCount = number;
        }];
        
        //cancel query on thread before continuing to sync data
        [query cancel];
        
        //query.cachePolicy = kPFCachePolicyNetworkElseCache;
        if (!objectCount == (unsigned long)[ApplicationDelegate.userVehicles count]) {
            if(self.lastSync != nil){
                [query whereKey:@"updatedAt" greaterThan:self.lastSync];
            }
        }else{
            
            [ApplicationDelegate.userVehicles removeAllObjects];
        }
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                _vehicles = [VSVehicles storedVehicles];
                for(int i = 0; i < objects.count; i++) {
                    _vehicleInfo = [[VSVehicleInfo alloc]init];
                    _vehicleInfo.vMake = [objects[i] valueForKey:@"make"];
                    _vehicleInfo.vModel = [objects[i] valueForKey:@"model"];
                    _vehicleInfo.vYear = [objects[i] valueForKey:@"year"];
                    _vehicleInfo.vObjectId = [objects[i] valueForKey:@"objectId"];
                    
                    
                    if(ApplicationDelegate.userVehicles != nil){
                        ApplicationDelegate.userVehicles = _vehicles.vehiclesArray;
                    }
                    if (ApplicationDelegate.userVehicles != nil) {
                        
                        if ([[ApplicationDelegate.userVehicles valueForKeyPath:@"vObjectId"] containsObject:_vehicleInfo.vObjectId]) {
                            int indexOfObj = [[ApplicationDelegate.userVehicles valueForKeyPath:@"vObjectId"] containsObject:_vehicleInfo.vObjectId];
                            
                            [ApplicationDelegate.userVehicles removeObjectAtIndex:indexOfObj];
                            
                        }
                        [ApplicationDelegate.userVehicles addObject:_vehicleInfo];
                    }
                    
                    NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.userVehicles];
                    [ApplicationDelegate.storedData setObject:vehicleData forKey:@"userVehicles"];
                    
                    
                }
                [ApplicationDelegate.storedData synchronize];
                
                
            }else{
                
                //Load User Defaults
                [self.tableView reloadData];
                
            }
            NSLog(@"Stored Vehicles in UserVehicles Array: %lu", (unsigned long)[ApplicationDelegate.userVehicles count]);
            //Reload table data
            [self.tableView reloadData];
            
            self.lastSync = [NSDate date];
            [autoCall invalidate];
            autoCall = [NSTimer scheduledTimerWithTimeInterval:25.0f target:self selector:@selector(syncData:) userInfo:nil repeats:YES];
            NSLog(@"Last Synce Date: %@", self.lastSync);
            [query cancel];
        }];
    }
    
}



#pragma mark -
#pragma mark LOAD DATA
-(void)loadData
{
    [self loading:@"Loading Vehicles"];
    
    if (ApplicationDelegate.isConnected == YES) {
        //Sync offline edited objects
        [self syncOfflineEditedObject];
    }
    
    //Query Parse Database and place object in vehicleArr
    query = [PFQuery queryWithClassName:@"Vehicles"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            _vehicles = [VSVehicles storedVehicles];
            for(int i = 0; i < objects.count; i++) {
                _vehicleInfo = [[VSVehicleInfo alloc]init];
                _vehicleInfo.vMake = [objects[i] valueForKey:@"make"];
                _vehicleInfo.vModel = [objects[i] valueForKey:@"model"];
                _vehicleInfo.vYear = [objects[i] valueForKey:@"year"];
                _vehicleInfo.vObjectId = [objects[i] valueForKey:@"objectId"];
                
                
                if(ApplicationDelegate.userVehicles != nil){
                    ApplicationDelegate.userVehicles = _vehicles.vehiclesArray;
                }
                if (ApplicationDelegate.userVehicles != nil) {
                    
                    [ApplicationDelegate.userVehicles addObject:_vehicleInfo];
                }
                
            }
            
        }else {
            
        }
        NSLog(@"%lu", (unsigned long)[ApplicationDelegate.userVehicles count]);
        //Reload table data
        [self.tableView reloadData];
        [self stopLoading];
        self.lastSync = [NSDate date];
        [autoCall invalidate];
        autoCall = [NSTimer scheduledTimerWithTimeInterval:25.0f target:self selector:@selector(syncData:) userInfo:nil repeats:YES];
        NSLog(@"Last Synce Date: %@", self.lastSync);
        [query cancel];
    }];
}

//Loading Alert
-(void)loading:(NSString*)msg
{
    loadingAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@", msg] delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [loadingAlert show];
}

//Dismiss loading alert
-(void)stopLoading
{
    [loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return [ApplicationDelegate.userVehicles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //Make sure vehicleArr has objects
    if(ApplicationDelegate.userVehicles.count != 0){
        
        //Set Cell Labels by Tag ID
        UILabel *vehicleYear = (UILabel*)[cell viewWithTag:101];
        UILabel *vehicleMake = (UILabel*) [cell viewWithTag:102];
        UILabel *vehicleModel = (UILabel *) [cell viewWithTag:103];
        
        //Load Vehicle Info
        VSVehicleInfo *vehicleInfo = [ApplicationDelegate.userVehicles objectAtIndex:indexPath.row];
        
        NSString *vYearString = [NSString stringWithFormat:@"%@", vehicleInfo.vYear];
        
        vehicleYear.text = vYearString;
        vehicleMake.text = vehicleInfo.vMake;
        vehicleModel.text = vehicleInfo.vModel;
    }
    
    
    return cell;
}


//Future Development
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    _vehicleInfo = [ApplicationDelegate.userVehicles objectAtIndex:indexPath.row];
    
    NSLog(@"%@", _vehicleInfo.vYear);
    [self performSegueWithIdentifier:@"details" sender:nil];
    
    //Deselect Item
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        _vehicleInfo = [ApplicationDelegate.userVehicles objectAtIndex:indexPath.row];
        
        
        deleteObject = [[UIAlertView alloc] initWithTitle:@"Delete Vehicle" message:@"Are you sure you want to delete this vehicle?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        
        //Set alert tag do index path. Allows me to pass the table index of item being deleted.
        deleteObject.tag = indexPath.row;
        
        [deleteObject show];
        
        
        
    }
}



//Navigate views
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"details"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        VSVehicleDetailsController *detailsView = segue.destinationViewController;
        detailsView.details = [ApplicationDelegate.userVehicles objectAtIndex:indexPath.row];
        detailsView.details.objectIndex = indexPath.row;
        NSLog(@"SELECTED OBJECT INDEX %ld", (long)indexPath.row);
    }
}


-(void)requireLogin
{
    //Setup login view
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    logInViewController.fields = PFLogInFieldsLogInButton | PFLogInFieldsUsernameAndPassword | PFLogInFieldsSignUpButton;
    [logInViewController setDelegate:self];
    
    //Setup sign up view
    PFSignUpViewController *signUpView = [[PFSignUpViewController alloc] init];
    [signUpView setDelegate:self];
    
    [logInViewController setSignUpController:signUpView];
    
    [self presentViewController:logInViewController animated:YES completion:nil];
}


#pragma mark PFLoginViewController Methods

//Login Failed Method
-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    if (ApplicationDelegate.isConnected == YES) {
        
        if([error code] == 101){
            [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Invalid login credentials. Please check your username and password and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }else if([error code] == 1109){
            
        }
    }else{
        [[[UIAlertView alloc] initWithTitle:@"No Connection" message:@"You do not have an active connection at this time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}



//Successful Login Method
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    NSLog(@"%@ Logged In",[[PFUser currentUser] username]);
    
    [self loadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    
    
    if (ApplicationDelegate.isConnected == YES) {
        
        // Check if both fields are completed
        if (username && password && username.length && password.length) {
            return YES;
            
        } else if(username.length < 1 && password.length < 1) {
            [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"You did not enter a user name or password!"delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
        }else if(username.length < 1) {
            [[[UIAlertView alloc] initWithTitle:@"Missing Username" message:@"You did not enter a username!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
        } else if(password.length < 1) {
            [[[UIAlertView alloc] initWithTitle:@"Missing Password" message:@"You did not enter a password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else if(username.length < 1 && password.length < 1) {
            [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"You did not enter a user name or password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        return NO;
        
    }else{
        
        UIAlertView *noConnection = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"You do not have an active network connect. Please connect to a network and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [noConnection show];
        
    }
    return NO;
    
}


#pragma mark PFSignUpViewCOntroller methods

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [[[UIAlertView alloc] initWithTitle:@"User Created" message:@"Your user account has been created!"delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)logOut:(id)sender
{
    
    
    logOutAlert = [[UIAlertView alloc] initWithTitle:@"Logout User" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    
    [logOutAlert show];
    
    
}

//Alert user of actions
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView == logOutAlert){
        if(buttonIndex == 1){
            
            [PFUser logOut];
            NSLog(@"User Logged Out!");
            
            //Remove all object before signing user out
            [ApplicationDelegate.userVehicles removeAllObjects];
            [self.tableView reloadData];
            
            //require use to login in
            [self requireLogin];
        }
        
        //Delete object if user acknowledges action
    }else if (alertView == deleteObject){
        
        if (buttonIndex == 1) {
            
            PFObject *vehicle = [PFObject objectWithoutDataWithClassName:@"Vehicles" objectId:_vehicleInfo.vObjectId];
            NSUInteger rowIndex = deleteObject.tag;
            _vehicleInfo = [ApplicationDelegate.userVehicles objectAtIndex:rowIndex];
            
            if(ApplicationDelegate.isConnected == NO){
                if (ApplicationDelegate.deleteObjects == nil) {
                    ApplicationDelegate.deleteObjects = [[NSMutableArray alloc]init];
                }
                if (ApplicationDelegate.storedData != nil) {
                    NSData *dataArray = [ApplicationDelegate.storedData objectForKey:@"deleteObject"];
                    if(dataArray != nil){
                        NSArray *defaultArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
                        ApplicationDelegate.deleteObjects = [NSMutableArray arrayWithArray:defaultArray];
                        [ApplicationDelegate.deleteObjects addObject:_vehicleInfo];
                        NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.deleteObjects];
                        [ApplicationDelegate.storedData setObject:vehicleData forKey:@"deleteObject"];
                    }else {
                        [ApplicationDelegate.deleteObjects addObject:_vehicleInfo];
                        NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.deleteObjects];
                        [ApplicationDelegate.storedData setObject:vehicleData forKey:@"deleteObject"];
                    }
                    [ApplicationDelegate.storedData synchronize];
                }
                
                [ApplicationDelegate.userVehicles removeObjectAtIndex:rowIndex];
                [self.tableView reloadData];
                
                NSLog(@"delete objects array count: %lu", (unsigned long)ApplicationDelegate.deleteObjects.count);
                
            }else{
                [vehicle deleteInBackground];
                [ApplicationDelegate.userVehicles removeObjectAtIndex:rowIndex];
                [self.tableView reloadData];
                
                
            }
            
            
        }
        
    }
    
}

-(void)syncOfflineEditedObject
{
    if (ApplicationDelegate.deleteObjects.count > 0) {
        
        NSData *storedObjectsToDelete = [ApplicationDelegate.storedData objectForKey:@"deleteObject"];
        if(storedObjectsToDelete != nil){
            NSArray *unarchivedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:storedObjectsToDelete];
            if (unarchivedObjects != nil) {
                if(ApplicationDelegate.deleteObjects.count > 0){
                    for (int i = 0; i < ApplicationDelegate.deleteObjects.count; i++) {
                        VSVehicleInfo *vehicleInfo = [ApplicationDelegate.deleteObjects objectAtIndex:i];
                        NSString *objectIdString = vehicleInfo.vObjectId;
                        
                        PFQuery *deleteQuery = [PFQuery queryWithClassName:@"Vehicles"];
                        PFObject *object = [deleteQuery getObjectWithId:objectIdString];
                        
                        [object deleteInBackground];
                    }
                    NSLog(@"All objects have been removed from the server");
                    [ApplicationDelegate.deleteObjects removeAllObjects];
                    NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.deleteObjects];
                    [ApplicationDelegate.storedData setObject:vehicleData forKey:@"deleteObject"];
                    [ApplicationDelegate.storedData synchronize];
                }
            }
            
        }
    }
    if(ApplicationDelegate.saveObjects.count > 0){
        NSData *savedModifiedObjects = [ApplicationDelegate.storedData objectForKey:@"savedOfflineObjects"];
        if (savedModifiedObjects != nil) {
            NSArray *unarchiveSavedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:savedModifiedObjects];
            if(unarchiveSavedObjects != nil){
                if (ApplicationDelegate.saveObjects.count > 0) {
                    for (int i = 0; i < ApplicationDelegate.saveObjects.count; i++) {
                        VSVehicleInfo *vehicleInfor = [ApplicationDelegate.saveObjects objectAtIndex:i];
                        NSString *vehicleMake = vehicleInfor.vMake;
                        NSString *vehicleModel = vehicleInfor.vModel;
                        NSNumber *vehicleYear = vehicleInfor.vYear;
                        
                        PFObject *vehicle = [PFObject objectWithClassName:@"Vehicles"];
                        vehicle[@"make"] = vehicleMake;
                        vehicle[@"model"] = vehicleModel;
                        
                        
                        vehicle[@"year"] = vehicleYear;
                        
                        
                        vehicle.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                        
                        [vehicle saveInBackground];
                    }
                    NSLog(@"All offline saved objects have been saved to db");
                    [ApplicationDelegate.saveObjects removeAllObjects];
                    NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.saveObjects];
                    [ApplicationDelegate.storedData setObject:vehicleData forKey:@"savedOfflineObjects"];
                    [ApplicationDelegate.storedData synchronize];
                    
                }
                
            }
        }
        
    }
    if (ApplicationDelegate.updateObjects.count > 0) {
        NSData *updatedObjects = [ApplicationDelegate.storedData objectForKey:@"updatedObjects"];
        if (updatedObjects != nil) {
            NSArray *unarchiveData =[NSKeyedUnarchiver unarchiveObjectWithData:updatedObjects];
            if (unarchiveData != nil) {
                if (ApplicationDelegate.updateObjects.count > 0) {
                    for (int i = 0; i < ApplicationDelegate.updateObjects.count; i++) {
                        VSVehicleInfo *vehicleData = [ApplicationDelegate.updateObjects objectAtIndex:i];
                        NSString *vehicleObjectId = vehicleData.vObjectId;
                        NSLog(@"Vehicle ID: %@", vehicleData.vObjectId);
                        
                        PFQuery *newQuery = [PFQuery queryWithClassName:@"Vehicles"];
                        
                        [newQuery getObjectInBackgroundWithId:vehicleObjectId block:^(PFObject *vehicle, NSError *error) {
                        
                            NSString *vehicleMake = vehicleData.vMake;
                        NSString *vehicleModel = vehicleData.vModel;
                        NSNumber *vehicleYear = vehicleData.vYear;
   
                            vehicle[@"year"] = vehicleYear;
                            vehicle[@"make"] = vehicleMake;
                            vehicle[@"model"] = vehicleModel;
                            
                            [vehicle saveInBackground];
  
                        }];
                        NSLog(@"All offline updated objects have been saved to db");
                        [ApplicationDelegate.updateObjects removeAllObjects];
                        NSData *vehicleArhivedData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.updateObjects];
                        [ApplicationDelegate.storedData setObject:vehicleArhivedData forKey:@"updatedObjects"];
                        [ApplicationDelegate.storedData synchronize];

                    }
                }
            }
        }
    }
}

@end
