//
//  VTransition22CISwipeTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition22CISwipeTransition.h"

@implementation VTransition22CISwipeTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CISwipeTransition" withInputParameters:
            @{
              @"inputAngle" : @(-1 * 3.1415 * 1/4),
              }];
    if (self) {
        
    }
    return self;
}

@end
