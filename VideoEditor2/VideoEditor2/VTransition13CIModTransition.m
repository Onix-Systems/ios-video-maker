//
//  VTransition13CIModTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/28/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition13CIModTransition.h"

@implementation VTransition13CIModTransition

- (instancetype)init
{
    self = [super initWithFilterName:@"CIModTransition" withInputParameters:
            @{
              @"inputAngle" : @(3.1415 * 1/4),
              }];
    if (self) {
        
    }
    return self;
}


@end
