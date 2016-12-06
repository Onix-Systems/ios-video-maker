//
//  VTransition17CIModTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition17CIModTransition.h"

@implementation VTransition17CIModTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIModTransition" withInputParameters:
            @{
              @"inputAngle" : @(-1 * 3.1415 * 3/4),
              @"inputRadius" : @200.0,
              }];
    if (self) {
        
    }
    return self;
}

@end
