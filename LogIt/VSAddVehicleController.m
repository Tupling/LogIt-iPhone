//
//  VSAddVehicleController.m
//  LogIt
//
//  Created by Dale Tupling on 5/8/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSAddVehicleController.h"

@interface VSAddVehicleController () <UIAlertViewDelegate>

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
    //check if details is nil. Update object or save new object
    if(self.details != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"Vehicles"];
        
        [query getObjectInBackgroundWithId:_details.vObjectId block:^(PFObject *vehicle, NSError *error) {
           

            vehicle[@"make"] = self.make.text;
            vehicle[@"model"] = self.model.text;
            
            NSString *yearString = self.year.text;
            
            //Convert year string to NSNumber for parse
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterNoStyle];
            
            NSNumber *vehicleYear = [nf numberFromString:yearString];
            
            vehicle[@"year"] = vehicleYear;
            
            [vehicle saveInBackground];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Vehicle Updated" message:@"You vehicle information has been updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert show];
            

        }];
    
    
    } else {
        
        
        //Year input validation done with Number Keyboard & it must consist of 4 digits//
        NSString *makeString = self.make.text;
        NSString *modelString = self.model.text;
        NSString *yearString = self.year.text;
        if(yearString.length < 4 && makeString.length == 0 && modelString.length == 0){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Some fields were left blank, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }else if(yearString.length < 4){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Year" message:@"You have entered an invalid vehicle year, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }else if(makeString.length == 0){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Vehicle Make" message:@"You have not entered a vehicle make, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }else if(modelString.length == 0){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Vehicle Model" message:@"You have not entered a vehicle model, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }else{
            
            PFObject *vehicle = [PFObject objectWithClassName:@"Vehicles"];
            vehicle[@"make"] = self.make.text;
            vehicle[@"model"] = self.model.text;
            
            
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterNoStyle];
            
            NSNumber *vehicleYear = [nf numberFromString:yearString];
            
            vehicle[@"year"] = vehicleYear;
            
            
            
            
            vehicle.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            [vehicle saveInBackground];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Vehicle Saved" message:@"You vehicle information has been saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert show];
        }
    }
    //NSLog(@"Make: %@ ", make.text);
    
    
    
}

//Dismiss view after user has dismissed Saved/Updated Alert
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
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
