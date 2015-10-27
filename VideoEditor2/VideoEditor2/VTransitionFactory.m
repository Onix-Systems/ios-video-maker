//
//  VTransitionFactory.m
//  VideoEditor2
//
//  Created by Alexander on 10/26/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransitionFactory.h"

#import "VTransition01Fading.h"

@implementation VTransitionFactory

+(VTransition*)makeRandomTransition
{
    NSArray* transitionClasses = @[
        [VTransition01Fading class]
    ];
    
    NSInteger classNumber = arc4random_uniform((int)transitionClasses.count);
    
    VTransition *transition = [transitionClasses[classNumber] new];
    
    return transition;
}

@end
