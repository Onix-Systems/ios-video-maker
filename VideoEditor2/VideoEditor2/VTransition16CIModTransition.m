//
//  VTransition16CIModTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition16CIModTransition.h"

@implementation VTransition16CIModTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIModTransition" withInputParameters:
            @{
              @"inputAngle" : @(-1 * 3.1415 * 1/2),
              @"inputRadius" : @50.0,
              }];
    if (self) {
        
    }
    return self;
}

@end
