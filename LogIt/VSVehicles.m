//
//  VSVehicles.m
//  LogIt
//
//  Created by Dale Tupling on 5/8/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSVehicles.h"

@implementation VSVehicles

static VSVehicles* _storedVehicles = nil;

+(VSVehicles*)storedVehicles
{
    if(!_storedVehicles)
    {
        _storedVehicles = [[self alloc] init];
    }
    return _storedVehicles;
}

-(id)init
{
    if ((self = [super init]))
    {
        _vehiclesArray = [[NSMutableArray alloc] init];
    }
    return self;
    
}
@end
