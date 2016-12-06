//
//  VTransition24CIPageCurlWithShadowTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition24CIPageCurlWithShadowTransition.h"

@implementation VTransition24CIPageCurlWithShadowTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIPageCurlWithShadowTransition" withInputParameters:
            @{
              @"inputAngle" : @(-1 * 3.1415 * 1/2),
              }];
    if (self) {
        
    }
    return self;
}

@end
