//
//  VTransition20CISwipeTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition20CISwipeTransition.h"

@implementation VTransition20CISwipeTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CISwipeTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 1/4),
              }];
    if (self) {
        
    }
    return self;
}

@end
