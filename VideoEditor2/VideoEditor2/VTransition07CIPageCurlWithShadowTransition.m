//
//  VTransition07CIPageCurlWithShadowTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/27/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition07CIPageCurlWithShadowTransition.h"
#import <UIKit/UIKit.h>

@implementation VTransition07CIPageCurlWithShadowTransition

- (instancetype)init
{
    CIImage* backsideImage = [CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]];
    
    self = [super initWithFilterName:@"CIPageCurlWithShadowTransition" withInputParameters:
            @{
              @"inputBacksideImage" : backsideImage,

              }];
    if (self) {
        
    }
    return self;
}

@end
