//
//  VTransition10CIBarsSwipeTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition10CIBarsSwipeTransition.h"
#import "TransitionFilter.h"

@implementation VTransition10CIBarsSwipeTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIBarsSwipeTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 1/2),
              @"inputWidth" : @70.0,
              }];
    if (self) {
        
    }
    return self;
}

@end
