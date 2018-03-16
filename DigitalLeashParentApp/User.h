//
//  User.h
//  DigitalLeashParentApp
//
//  Created by Eduard Lev on 2/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic) NSString *username;
@property (nonatomic) double radius;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

-(instancetype)initWithUser:(NSString*)user Radius:(NSNumber*)radius Latitude:(NSNumber*)latitude Longitude:(NSNumber*)longitude
NS_DESIGNATED_INITIALIZER;

@end
