//
//  VSAddVehicleController.m
//  LogIt
//
//  Created by Dale Tupling on 5/8/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSAddVehicleController.h"

@interface VSAddVehicleController ()

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveVehicle:(id)sender
{
    PFObject *vehicle = [PFObject objectWithClassName:@"Vehicles"];
    vehicle[@"make"] = make.text;
    vehicle[@"model"] = model.text;

    NSString *yearString = year.text;
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterNoStyle];
    
    NSNumber *vehicleYear = [nf numberFromString:yearString];
    
    vehicle[@"year"] = vehicleYear;
    vehicle.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    
    [vehicle saveInBackground];
    
    NSLog(@"Make: %@ ", make.text);
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
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
