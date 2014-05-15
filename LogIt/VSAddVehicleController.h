//
//  VSAddVehicleController.h
//  LogIt
//
//  Created by Dale Tupling on 5/8/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "VSVehicleInfo.h"


@interface VSAddVehicleController : UIViewController

{
    IBOutlet UITextField *make;
    IBOutlet UITextField *model;
    IBOutlet UITextField *year;
    IBOutlet UILabel *headingLabel;
}

@property (nonatomic, strong)VSVehicleInfo *details;
@property (nonatomic, retain) IBOutlet UITextField *make;
@property (nonatomic, retain) IBOutlet UITextField *model;
@property (nonatomic, strong) IBOutlet UITextField *year;

-(IBAction)saveVehicle:(id)sender;
@end
