//
//  VSViewController.m
//  LogIt
//
//  Created by Dale Tupling on 5/5/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSViewController.h"

@interface VSViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
{

}

@end

@implementation VSViewController
-(void)viewDidAppear:(BOOL)animated
{

    //check for logged in user
    if ([PFUser currentUser]) {
        [self loadData];
        
    } else {
        //force login if not
        [self requireLogin];
    }
    
}




-(void)loadData
{
    
    //Remove all object before loading screen
    [_vehicleArr removeAllObjects];
    
    
    //Query Parse Database and place object in vehicleArr
    
    PFQuery *query = [PFQuery queryWithClassName:@"Vehicles"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            _vehicles = [VSVehicles storedVehicles];
            for(int i = 0; i < objects.count; i++) {
                _vehicleInfo = [[VSVehicleInfo alloc]init];
                _vehicleInfo.vMake = [objects[i] valueForKey:@"make"];
                _vehicleInfo.vModel = [objects[i] valueForKey:@"model"];
                _vehicleInfo.vYear = [objects[i] valueForKey:@"year"];
                
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
        
    }];
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
   
 //TODO
    
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
    if([error code] == 101){
   [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Invalid login credentials. Please check your username and password and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}



//Successful Login Method
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    NSLog(@"%@ Logged In",[[PFUser currentUser] username]);


    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES;
        
    }  else if(username.length < 1 && password.length < 1) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"You did not enter a user name or password!"delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
    }else if(username.length < 1) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Username" message:@"You did not enter a username!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
    } else if(password.length < 1) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Password" message:@"You did not enter a password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if(username.length < 1 && password.length < 1) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"You did not enter a user name or password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    [PFUser logOut];
    NSLog(@"User Logged Out!");
    
    //Remove all object before signing user out
    [_vehicleArr removeAllObjects];
    [self.tableView reloadData];
    
    //require use to login in
    [self requireLogin];
}

@end
