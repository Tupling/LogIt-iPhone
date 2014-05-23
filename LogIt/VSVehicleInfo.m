//
//  VSVehicleInfo.m
//  LogIt
//
//  Created by Dale Tupling on 5/8/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSVehicleInfo.h"

@implementation VSVehicleInfo


-(id) initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.vMake = [decoder decodeObjectForKey:@"make"];
        self.vModel = [decoder decodeObjectForKey:@"model"];
        self.vYear = [decoder decodeObjectForKey:@"year"];
        self.vObjectId = [decoder decodeObjectForKey:@"objectId"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_vMake forKey:@"make"];
    [encoder encodeObject:_vModel forKey:@"model"];
    [encoder encodeObject:_vYear forKey:@"year"];
    [encoder encodeObject:_vObjectId forKey:@"objectId"];
}

@end
