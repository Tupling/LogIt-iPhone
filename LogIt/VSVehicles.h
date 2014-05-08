//
//  VSVehicles.h
//  LogIt
//
//  Created by Dale Tupling on 5/8/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSVehicles : NSObject


+(VSVehicles*)storedVehicles;

@property (nonatomic, strong)NSMutableArray *vehiclesArray;

@end
