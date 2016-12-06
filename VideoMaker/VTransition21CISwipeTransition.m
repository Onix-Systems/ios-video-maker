//
//  VTransition21CISwipeTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition21CISwipeTransition.h"

@implementation VTransition21CISwipeTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CISwipeTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 3/4),
              }];
    if (self) {
        
    }
    return self;
}

@end
