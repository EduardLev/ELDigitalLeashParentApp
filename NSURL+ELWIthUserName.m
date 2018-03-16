//
//  NSURL+ELWIthUserName.m
//  DigitalLeashParentApp
//
//  Created by Eduard Lev on 2/18/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

#import "NSURL+ELWIthUserName.h"

@implementation NSURL (ELWIthUserName)

-(NSURL*)withUserName:(NSString*)username {
    
    NSString *url_name = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json", username];
    NSURL *url = [NSURL URLWithString:url_name];
    return url;
    
}

@end
