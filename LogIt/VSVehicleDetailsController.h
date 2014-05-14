//
//  VSVehicleDetailsController.h
//  LogIt
//
//  Created by Dale Tupling on 5/13/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSVehicleInfo.h"

@interface VSVehicleDetailsController : UIViewController
{
    IBOutlet UILabel *year;
    IBOutlet UILabel *make;
    IBOutlet UILabel *model;
}

@property (nonatomic, strong)VSVehicleInfo *details;

@end
