//
//  VTransition11CIBarsSwipeTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition11CIBarsSwipeTransition.h"

@implementation VTransition11CIBarsSwipeTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIBarsSwipeTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 5/4),
              @"inputWidth" : @15.0,
              }];
    if (self) {
        
    }
    return self;
}

@end
