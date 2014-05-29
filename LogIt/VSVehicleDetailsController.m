//
//  VSVehicleDetailsController.m
//  LogIt
//
//  Created by Dale Tupling on 5/13/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSVehicleDetailsController.h"
#import "VSAddVehicleController.h"

@interface VSVehicleDetailsController ()

@end

@implementation VSVehicleDetailsController

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
    
    year.text = [NSString stringWithFormat:@"%@", self.details.vYear];
    make.text = self.details.vMake;
    model.text = self.details.vModel;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"editDetails"]) {

    
    VSAddVehicleController *editVehicle = segue.destinationViewController;
    editVehicle.details = _details;
        NSLog(@"%lu", (unsigned long)self.details.objectIndex);
    editVehicle.details.objectIndex = _details.objectIndex;

        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
