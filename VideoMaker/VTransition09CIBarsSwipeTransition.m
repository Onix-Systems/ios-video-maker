//
//  VTransition09CIBarsSwipeTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition09CIBarsSwipeTransition.h"

@implementation VTransition09CIBarsSwipeTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIBarsSwipeTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 3/4),
              }];
    if (self) {
        
    }
    return self;
}

@end
