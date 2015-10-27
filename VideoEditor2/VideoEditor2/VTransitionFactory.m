//
//  VTransitionFactory.m
//  VideoEditor2
//
//  Created by Alexander on 10/26/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransitionFactory.h"

#import "VTransition01Fading.h"

#import "VTransition02CIAccordionFoldTransition.h"
#import "VTransition03CIBarsSwipeTransition.h"
#import "VTransition04CIDissolveTransition.h"
#import "VTransition05CIModTransition.h"
#import "VTransition06CISwipeTransition.h"
#import "VTransition07CIPageCurlWithShadowTransition.h"


@implementation VTransitionFactory

+(VTransition*)makeRandomTransition
{
    NSArray* transitionClasses = @[
        [VTransition01Fading class],
        [VTransition02CIAccordionFoldTransition class],
        [VTransition03CIBarsSwipeTransition class],
        [VTransition04CIDissolveTransition class],
        [VTransition05CIModTransition class],
        [VTransition06CISwipeTransition class],
        [VTransition07CIPageCurlWithShadowTransition class]
    ];

    
    NSInteger classNumber = arc4random_uniform((int)transitionClasses.count);
    
    VTransition *transition = [transitionClasses[classNumber] new];
    
    return transition;
}

@end
