//
//  VTransition15CIModTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition15CIModTransition.h"

@implementation VTransition15CIModTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIModTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 1/2),
              @"inputRadius" : @70.0,
              @"inputCenter" : [CIVector vectorWithX:300 Y: 0]
              }];
    if (self) {
        
    }
    return self;
}

@end
