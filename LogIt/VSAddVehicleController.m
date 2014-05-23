//
//  VSAddVehicleController.m
//  LogIt
//
//  Created by Dale Tupling on 5/8/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSAddVehicleController.h"
#import "VSAppDelegate.h"


@interface VSAddVehicleController () <UIAlertViewDelegate, UITextFieldDelegate>
{
    Reachability *connection;
    UIAlertView *noConnection;
    UIAlertView *savedAlert;
    UIAlertView *updatedAlert;
    NSCharacterSet *blockedCharacters;

}

@end

@implementation VSAddVehicleController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    //Change TextView values depending on details
    if(self.details != nil){
        self.title = @"Edit Vehicle";
        _make.text = self.details.vMake;
        _year.text = [NSString stringWithFormat:@"%@", self.details.vYear];
        _model.text = self.details.vModel;
        headingLabel.text = @"Edit vehicle details";
        NSLog(@"Vehicle ID: %@", self.details.vObjectId);
    }
    NSLog(@"%@", _details.vMake);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveVehicle:(id)sender
{
    //Declaration for AppDelegate Method isConnected
    VSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //Check Network Status
    BOOL connected = [appDelegate isConnected];
    
    
    if(connected == YES){
        
        if(self.details != nil) {
            PFQuery *query = [PFQuery queryWithClassName:@"Vehicles"];
            
            [query getObjectInBackgroundWithId:_details.vObjectId block:^(PFObject *vehicle, NSError *error) {
 
                
                vehicle[@"make"] = self.make.text;
                vehicle[@"model"] = self.model.text;
                
                NSString *yearString = self.year.text;
                NSString *modelString = self.model.text;
                NSString *makeString = self.make.text;
                
                //Number Conversion
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterNoStyle];
                
                NSNumber *vehicleYear = [nf numberFromString:yearString];
                
                //Validate Model and Make string
                BOOL makeValid = [self validateVehicleMake:makeString];
                BOOL modelValid = [self validateVehicleModel:modelString];
                
                
                if(yearString.length < 4 && makeString.length == 0 && modelString.length == 0){
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Some fields were left blank, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    
                }else if(yearString.length < 4){
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Year" message:@"You have entered an invalid vehicle year, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    
                }else if(makeString.length == 0 || makeValid == NO || makeString.length > 15){
                    
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Make" message:@"You have entered an invalid vehicle make, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    
                }else if(modelString.length == 0 || modelValid == NO){
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Model" message:@"You have entered an invalid vehicle model, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    
                }else if(vehicleYear.intValue < 1981 || vehicleYear.intValue > 2015){
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Year" message:@"You have entered an invalid vehicle Year, vehicle can not be older than 1981 or newer than 2015, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    
                    
                }else{
                    
                    vehicle[@"year"] = vehicleYear;
                    
                    
                    [vehicle saveInBackground];
                    
                    updatedAlert = [[UIAlertView alloc] initWithTitle:@"Vehicle Updated" message:@"You vehicle information has been updated!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [updatedAlert show];
                    
                }
            }];
            
            
        } else {
            
            
            //Year input validation done with Number Keyboard & it must consist of 4 digits//
            NSString *makeString = self.make.text;
            NSString *modelString = self.model.text;
            NSString *yearString = self.year.text;

            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterNoStyle];
            
            NSNumber *vehicleYear = [nf numberFromString:yearString];
            
            
            //Booleans for Valid Vehicle Make and Model
            BOOL makeValid = [self validateVehicleMake:makeString];
            BOOL modelValid = [self validateVehicleModel:modelString];
            //BOOL yearValid = [self validateYear:yearString];
            
            
            if(yearString.length < 4 && makeString.length == 0 && modelString.length == 0){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Some fields were left blank, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                
            }else if(yearString.length < 4){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Year" message:@"You have entered an invalid vehicle year, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                
            }else if(makeString.length == 0 || makeValid == NO || makeString.length > 15){
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Make" message:@"You have entered an invalid vehicle make, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                
                
            }else if(modelString.length == 0 || modelValid == NO){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Model" message:@"You have entered an invalid vehicle model, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                
        
            }else if(vehicleYear.intValue < 1981 || vehicleYear.intValue > 2015){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Year" message:@"You have entered an invalid vehicle Year, vehicle can not be older than 1981 or newer than 2015, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                
                
                
            }else{
                
                PFObject *vehicle = [PFObject objectWithClassName:@"Vehicles"];
                vehicle[@"make"] = self.make.text;
                vehicle[@"model"] = self.model.text;
                

                
                vehicle[@"year"] = vehicleYear;
                
                
                vehicle.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                
                [vehicle saveInBackground];
                if (vehicle.save) {
                    
                    savedAlert = [[UIAlertView alloc] initWithTitle:@"Vehicle Saved" message:@"You vehicle information has been saved!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [savedAlert show];
                }else{
                    savedAlert = [[UIAlertView alloc] initWithTitle:@"Save Error" message:@"There was an error trying to save your vehicle information!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [savedAlert show];
                }
                

            }
        }
        //NSLog(@"Make: %@ ", make.text);
        
        
        
    }else {
        
        noConnection = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"You do not have an active connection. Please connect to a network and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [noConnection show];
        
    }
    
    
    //check if details is nil. Update object or save new object
    
    
}

//Method to Validate Make String
-(BOOL)validateVehicleMake:(NSString*)string
{
    NSString *validCharacters = @"^[a-zA-Z ]*$";
    NSPredicate *validate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validCharacters];
    
    return [validate evaluateWithObject:string];
}
//Validate Vehicle Model
-(BOOL)validateVehicleModel:(NSString*)string
{
    NSString *validCharacters = @"^[a-zA-Z0-9 ]*$";
    NSPredicate *validate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validCharacters];
    
    return [validate evaluateWithObject:string];
}


//Dismiss view after user has dismissed Saved/Updated Alert
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (savedAlert || updatedAlert) {
        
        if (buttonIndex == 0) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
