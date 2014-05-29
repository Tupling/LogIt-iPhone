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
    UIAlertView *noConnection;
    UIAlertView *savedAlert;
    UIAlertView *updatedAlert;
    NSCharacterSet *blockedCharacters;
    NSUInteger arrayIndex;
    
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
        arrayIndex = self.details.objectIndex;
        
        NSLog(@"VEHICLE OBJECT INDEX = %lu", (unsigned long)arrayIndex);
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
    
    
    if(ApplicationDelegate.isConnected == YES){
        
        
#pragma mark
#pragma UPDATE VEHICLE INFO
        
        //Updating Data
        //
        
        if(self.details != nil) {
            PFQuery *query = [PFQuery queryWithClassName:@"Vehicles"];
            
            [query getObjectInBackgroundWithId:_details.vObjectId block:^(PFObject *vehicle, NSError *error) {
                
                
                
                NSString *yearString = self.year.text;
                NSString *modelString = self.model.text;
                NSString *makeString = self.make.text;
                
                //Number Conversion
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterNoStyle];
                
                NSNumber *vehicleYear = [nf numberFromString:yearString];
                
                BOOL stringsValid = [self validateStringMake:makeString modelString:modelString yearString:yearString];
                
                //check for valid strings
                if(stringsValid){
                    
                    vehicle[@"year"] = vehicleYear;
                    vehicle[@"make"] = self.make.text;
                    vehicle[@"model"] = self.model.text;
                    
                    [vehicle saveInBackground];
                    
                    updatedAlert = [[UIAlertView alloc] initWithTitle:@"Vehicle Updated" message:@"You vehicle information has been updated!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [updatedAlert show];
                    
                }
            }];
            
#pragma mark
#pragma ADD NEW VEHICLE
            
            //Adding new Vehicle
            //
        } else {
            
            
            //Year input validation done with Number Keyboard & it must consist of 4 digits//
            NSString *makeString = self.make.text;
            NSString *modelString = self.model.text;
            NSString *yearString = self.year.text;
            
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterNoStyle];
            
            NSNumber *vehicleYear = [nf numberFromString:yearString];
            
            BOOL stringsValid = [self validateStringMake:makeString modelString:modelString yearString:yearString];
            
            //check for valid strings
            if(stringsValid){
                
                
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
#pragma mark
#pragma  SAVE OFFLINE
    }else {
        if(_details != nil){
            NSString *yearString = self.year.text;
            NSString *modelString = self.model.text;
            NSString *makeString = self.make.text;
            NSString *vehicleId = _details.vObjectId;
            
            //Number Conversion
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterNoStyle];
            
            NSNumber *vehicleYear = [nf numberFromString:yearString];
            
            BOOL stringsValid = [self validateStringMake:makeString modelString:modelString yearString:yearString];
            
            //check for valid strings
            if(stringsValid){
                
                _details = [[VSVehicleInfo alloc]init];
                _details.vMake = makeString;
                _details.vModel = modelString;
                _details.vYear = vehicleYear;
                _details.vObjectId = vehicleId;
                
                
                if (ApplicationDelegate.updateObjects == nil) {
                    ApplicationDelegate.updateObjects = [[NSMutableArray alloc]init];
                }
                
                if (ApplicationDelegate.storedData != nil) {
                    NSData *dataArray = [ApplicationDelegate.storedData objectForKey:@"updatedObjects"];
                    if(dataArray != nil){
                        NSArray *defaultArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
                        ApplicationDelegate.updateObjects = [NSMutableArray arrayWithArray:defaultArray];

                        [ApplicationDelegate.updateObjects addObject:_details];
                        NSLog(@"UPDATE OBJECT COUNT: %lu", (unsigned long)ApplicationDelegate.updateObjects.count);
                        NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.updateObjects];
                        [ApplicationDelegate.storedData setObject:vehicleData forKey:@"updatedObjects"];
                    }else {
                        [ApplicationDelegate.updateObjects addObject:_details];
                        NSLog(@"UPDATE OBJECT COUNT: %lu", (unsigned long)ApplicationDelegate.updateObjects.count);
                        NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.updateObjects];
                        [ApplicationDelegate.storedData setObject:vehicleData forKey:@"updatedObjects"];
                    }
                    [ApplicationDelegate.storedData synchronize];
                }
                
                if([[ApplicationDelegate.userVehicles valueForKeyPath:@"vObjectId"]  containsObject:vehicleId]){
                    NSLog(@"INDEX OF OBJECT REPLACING: %lu", (unsigned long)arrayIndex);
                    [ApplicationDelegate.userVehicles replaceObjectAtIndex:arrayIndex withObject:_details];
                }else{
                    [ApplicationDelegate.userVehicles addObject:_details];
                }
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.userVehicles];
                [ApplicationDelegate.storedData setObject:data forKey:@"userVehicles"];
                [ApplicationDelegate.storedData synchronize];
                
                
                savedAlert = [[UIAlertView alloc] initWithTitle:@"Vehicle Saved" message:@"You vehicle information has been saved!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [savedAlert show];
                
            }
            
        }
        else{
            //Year input validation done with Number Keyboard & it must consist of 4 digits//
            NSString *makeString = self.make.text;
            NSString *modelString = self.model.text;
            NSString *yearString = self.year.text;
            
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterNoStyle];
            
            NSNumber *vehicleYear = [nf numberFromString:yearString];
            
            BOOL stringsValid = [self validateStringMake:makeString modelString:modelString yearString:yearString];
            
            //check for valid strings
            if(stringsValid){
                
                _details = [[VSVehicleInfo alloc]init];
                _details.vMake = makeString;
                _details.vModel = modelString;
                _details.vYear = vehicleYear;
                
                if (ApplicationDelegate.saveObjects == nil) {
                    ApplicationDelegate.saveObjects = [[NSMutableArray alloc]init];
                }
                
                if (ApplicationDelegate.storedData != nil) {
                    NSData *dataArray = [ApplicationDelegate.storedData objectForKey:@"savedOfflineObjects"];
                    if(dataArray != nil){
                        NSArray *defaultArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
                        ApplicationDelegate.saveObjects = [NSMutableArray arrayWithArray:defaultArray];
                        [ApplicationDelegate.saveObjects addObject:_details];
                        NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.saveObjects];
                        [ApplicationDelegate.storedData setObject:vehicleData forKey:@"savedOfflineObjects"];
                    }else {
                        [ApplicationDelegate.saveObjects addObject:_details];
                        NSData *vehicleData = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.saveObjects];
                        [ApplicationDelegate.storedData setObject:vehicleData forKey:@"savedOfflineObjects"];
                    }
                    [ApplicationDelegate.storedData synchronize];
                }
                
                [ApplicationDelegate.userVehicles addObject:_details];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:ApplicationDelegate.userVehicles];
                [ApplicationDelegate.storedData setObject:data forKey:@"userVehicles"];
                [ApplicationDelegate.storedData synchronize];
                
                NSLog(@"delete objects array count: %lu", (unsigned long)ApplicationDelegate.saveObjects.count);
                
                
                savedAlert = [[UIAlertView alloc] initWithTitle:@"Vehicle Saved" message:@"You vehicle information has been saved!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [savedAlert show];
            }
        }
    }
    
}
#pragma mark
#pragma VALIDATION METHODS

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

#pragma mark
#pragma VALIDATE STRINGS

-(BOOL)validateStringMake:(NSString*)vMake modelString:(NSString*)vModel yearString:(NSString*)vYear
{
    
    //Booleans for Valid Vehicle Make and Model
    BOOL makeValid = [self validateVehicleMake:vMake];
    BOOL modelValid = [self validateVehicleModel:vModel];
    
    if(vYear.length < 4 && vMake.length == 0 && vModel.length == 0){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Some fields were left blank, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
        
    }else if(vYear.length < 4){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Year" message:@"You have entered an invalid vehicle year, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
        
    }else if(vMake.length == 0 || makeValid == NO || vMake.length > 15){
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Make" message:@"You have entered an invalid vehicle make, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
        
    }else if(vModel.length == 0 || modelValid == NO){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Model" message:@"You have entered an invalid vehicle model, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
        
    }else if(vYear.intValue < 1981 || vYear.intValue > 2015){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Vehicle Year" message:@"You have entered an invalid vehicle Year, vehicle can not be older than 1981 or newer than 2015, please check your entry and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
        
        
    }else{
        return YES;
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
