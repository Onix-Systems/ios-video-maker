//
//  VTransition26CIPageCurlWithShadowTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition26CIPageCurlWithShadowTransition.h"

@implementation VTransition26CIPageCurlWithShadowTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIPageCurlWithShadowTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 3/4),
              }];
    if (self) {
        
    }
    return self;
}

@end
