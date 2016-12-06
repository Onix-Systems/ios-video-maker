//
//  VTransition25CIPageCurlWithShadowTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition25CIPageCurlWithShadowTransition.h"

@implementation VTransition25CIPageCurlWithShadowTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIPageCurlWithShadowTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 1/4),
              }];
    if (self) {
        
    }
    return self;
}

@end
