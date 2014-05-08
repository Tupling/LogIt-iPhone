//
//  VSAddVehicleController.h
//  LogIt
//
//  Created by Dale Tupling on 5/8/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface VSAddVehicleController : UIViewController

{
    IBOutlet UITextField *make;
    IBOutlet UITextField *model;
    IBOutlet UITextField *year;
}


-(IBAction)saveVehicle:(id)sender;
@end
