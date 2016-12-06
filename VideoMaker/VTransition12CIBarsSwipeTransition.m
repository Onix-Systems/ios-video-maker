//
//  VTransition12CIBarsSwipeTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition12CIBarsSwipeTransition.h"

@implementation VTransition12CIBarsSwipeTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIBarsSwipeTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 3/4),
              @"inputWidth" : @70.0,
              }];
    if (self) {
        
    }
    return self;
}

@end
