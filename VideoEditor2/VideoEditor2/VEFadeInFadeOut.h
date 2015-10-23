//
//  VEFadeInFadeOut.h
//  VideoEditor2
//
//  Created by Alexander on 10/17/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VEffect.h"

#define kVEFadeInFadeOutDefaultDuration 0.5

@interface VEFadeInFadeOut : VEffect

@property (nonatomic) double fadeInDuration;
@property (nonatomic) double fadeOutDuration;

@end
