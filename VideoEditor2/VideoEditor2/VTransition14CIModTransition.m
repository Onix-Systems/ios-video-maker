//
//  VTransition14CIModTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition14CIModTransition.h"

@implementation VTransition14CIModTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIModTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 5/4),
              }];
    if (self) {
        
    }
    return self;
}

@end
