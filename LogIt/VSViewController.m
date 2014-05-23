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
}

@end



@implementation VSViewController
-(void)viewDidLoad{
    [super viewDidLoad];

    
}
-(void)viewWillAppear:(BOOL)animated
{
    if ([ApplicationDelegate.networkStatus currentReachabilityStatus] == 1) {
        if ([PFUser currentUser]) {
            [NSTimer scheduledTimerWithTimeInterval:25.0f target:self selector:@selector(syncData:) userInfo:nil repeats:YES];
            [self syncData:nil];
            
        }else{
            
            [self loadData];
        }
        
    }else{
        [self requireLogin];
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [ApplicationDelegate.networkStatus stopNotifier];
}


#pragma mark -
#pragma SYNC DATA
-(void)syncData:(NSTimer *)timer{
    
    //Ensure Sync Method is only executed when active connection exist
    if ([ApplicationDelegate.networkStatus currentReachabilityStatus] == 1) {
        query = [PFQuery queryWithClassName:@"Vehicles"];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        if (![query countObjects] == (unsigned long)[_vehicleArr count]) {
            if(self.lastSync != nil){
                [query whereKey:@"updatedAt" greaterThan:self.lastSync];
            }
        }else{
            
            [self.vehicleArr removeAllObjects];
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
                    
                    
                    if(self.vehicles != nil){
                        self.vehicleArr = _vehicles.vehiclesArray;
                    }
                    if (self.vehicleArr != nil) {
                        
                        if ([[self.vehicleArr valueForKeyPath:@"vObjectId"] containsObject:_vehicleInfo.vObjectId]) {
                            int indexOfObj = [[self.vehicleArr valueForKeyPath:@"vObjectId"] containsObject:_vehicleInfo.vObjectId];
                            
                            [self.vehicleArr removeObjectAtIndex:indexOfObj];
                            
                        }
                        [self.vehicleArr addObject:_vehicleInfo];
                    }
                    
                }
                
            }else {
                
            }
            NSLog(@"%lu", (unsigned long)[_vehicleArr count]);
            //Reload table data
            [self.tableView reloadData];
            
            self.lastSync = [NSDate date];
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
                
                
                if(_vehicles != nil){
                    _vehicleArr = _vehicles.vehiclesArray;
                }
                if (_vehicleArr != nil) {
                    
                    [_vehicleArr addObject:_vehicleInfo];
                }
                
            }
            
        }else {
            
        }
        NSLog(@"%lu", (unsigned long)[_vehicleArr count]);
        //Reload table data
        [self.tableView reloadData];
        [self stopLoading];
        self.lastSync = [NSDate date];
        
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
    
    
    return [_vehicleArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //Make sure vehicleArr has objects
    if(_vehicleArr.count != 0){
        
        //Set Cell Labels by Tag ID
        UILabel *vehicleYear = (UILabel*)[cell viewWithTag:101];
        UILabel *vehicleMake = (UILabel*) [cell viewWithTag:102];
        UILabel *vehicleModel = (UILabel *) [cell viewWithTag:103];
        
        //Load Vehicle Info
        VSVehicleInfo *vehicleInfo = [_vehicleArr objectAtIndex:indexPath.row];
        
        NSString *vYearString = [NSString stringWithFormat:@"%@", vehicleInfo.vYear];
        
        vehicleYear.text = vYearString;
        vehicleMake.text = vehicleInfo.vMake;
        vehicleModel.text = vehicleInfo.vModel;
    }
    
    
    return cell;
}


//Future Development
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    _vehicleInfo = [_vehicleArr objectAtIndex:indexPath.row];
    
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
        
        _vehicleInfo = [_vehicleArr objectAtIndex:indexPath.row];
        
        
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
        detailsView.details = [_vehicleArr objectAtIndex:indexPath.row];
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
    if ([ApplicationDelegate.networkStatus currentReachabilityStatus] == 1) {
        
        if([error code] == 101){
            [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Invalid login credentials. Please check your username and password and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }else{
        [[[UIAlertView alloc] initWithTitle:@"No Connection" message:@"You do not have an active connection at this time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}



//Successful Login Method
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    NSLog(@"%@ Logged In",[[PFUser currentUser] username]);
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    
    
    
    if ([ApplicationDelegate.networkStatus currentReachabilityStatus] == 1) {
        
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
            [_vehicleArr removeAllObjects];
            [self.tableView reloadData];
            
            //require use to login in
            [self requireLogin];
        }
        
        //Delete object if user acknowledges action
    }else if (alertView == deleteObject){
        
        if (buttonIndex == 1) {
            
            PFObject *vehicle = [PFObject objectWithoutDataWithClassName:@"Vehicles" objectId:_vehicleInfo.vObjectId];
            NSUInteger rowIndex = deleteObject.tag;
            _vehicleInfo = [_vehicleArr objectAtIndex:rowIndex];
            
            if([ApplicationDelegate.networkStatus currentReachabilityStatus] == 0){
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
                
                [self.vehicleArr removeObjectAtIndex:rowIndex];
                [self.tableView reloadData];
                
                NSLog(@"delete objects array count: %lu", (unsigned long)ApplicationDelegate.deleteObjects.count);
                
            }else{
                [vehicle deleteInBackground];
                [self.vehicleArr removeObjectAtIndex:rowIndex];
                [self.tableView reloadData];
                
                
            }
            
            
        }
        
    }
    
}
-(void)pendingDeletion:(PFObject*)vehicle
{
    
    
}
@end
