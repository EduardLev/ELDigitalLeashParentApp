//
//  User.m
//  DigitalLeashParentApp
//
//  Created by Eduard Lev on 2/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

#import "User.h"

@implementation User

-(NSString*)description {
    return [NSString stringWithFormat:@"<%@, Radius: %0.2f, Longitude: %0.2f, Latitude %0.2f>",self.username,self.radius,self.latitude,self.longitude];
}

-(instancetype)init {
    NSNumber *radius = [[NSNumber alloc] initWithDouble:0.0];
    NSNumber *latitude = [[NSNumber alloc] initWithDouble:0.0];
    NSNumber *longitude = [[NSNumber alloc] initWithDouble:0.0];
    return [self initWithUser:@"" Radius:radius Latitude:latitude Longitude:longitude];
}

// DESIGNATED INITIALIZER
-(instancetype)initWithUser:(NSString*)user Radius:(NSNumber*)radius Latitude:(NSNumber*)latitude Longitude:(NSNumber*)longitude {
    if (self = [super init]) {
        self.username = user;
        
        self.radius = [radius doubleValue];
        self.latitude = [latitude doubleValue];
        self.longitude = [longitude doubleValue];
    }
    return self;
}

@end
