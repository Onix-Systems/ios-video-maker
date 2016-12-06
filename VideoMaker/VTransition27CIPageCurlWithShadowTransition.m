//
//  VTransition27CIPageCurlWithShadowTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition27CIPageCurlWithShadowTransition.h"

@implementation VTransition27CIPageCurlWithShadowTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIPageCurlWithShadowTransition" withInputParameters:
            @{
              @"inputAngle" : @(-1 * 3.1415 * 1/4),
              }];
    if (self) {
        
    }
    return self;
}

@end
