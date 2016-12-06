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

#import "VTransition08CIBarsSwipeTransition.h"
#import "VTransition09CIBarsSwipeTransition.h"
#import "VTransition10CIBarsSwipeTransition.h"
#import "VTransition11CIBarsSwipeTransition.h"
#import "VTransition12CIBarsSwipeTransition.h"

#import "VTransition13CIModTransition.h"
#import "VTransition14CIModTransition.h"
#import "VTransition15CIModTransition.h"
#import "VTransition16CIModTransition.h"
#import "VTransition17CIModTransition.h"

#import "VTransition18CISwipeTransition.h"
#import "VTransition19CISwipeTransition.h"
#import "VTransition20CISwipeTransition.h"
#import "VTransition21CISwipeTransition.h"
#import "VTransition22CISwipeTransition.h"

#import "VTransition23CIPageCurlWithShadowTransition.h"
#import "VTransition24CIPageCurlWithShadowTransition.h"
#import "VTransition25CIPageCurlWithShadowTransition.h"
#import "VTransition26CIPageCurlWithShadowTransition.h"
#import "VTransition27CIPageCurlWithShadowTransition.h"

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
        [VTransition07CIPageCurlWithShadowTransition class],
        
        [VTransition08CIBarsSwipeTransition class],
        [VTransition09CIBarsSwipeTransition class],
        [VTransition10CIBarsSwipeTransition class],
        [VTransition11CIBarsSwipeTransition class],
        [VTransition12CIBarsSwipeTransition class],
        
        [VTransition13CIModTransition class],
        [VTransition14CIModTransition class],
        [VTransition15CIModTransition class],
        [VTransition16CIModTransition class],
        [VTransition17CIModTransition class],
        
        [VTransition18CISwipeTransition class],
        [VTransition19CISwipeTransition class],
        [VTransition20CISwipeTransition class],
        [VTransition21CISwipeTransition class],
        [VTransition22CISwipeTransition class],
        
        [VTransition23CIPageCurlWithShadowTransition class],
        [VTransition24CIPageCurlWithShadowTransition class],
        [VTransition25CIPageCurlWithShadowTransition class],
        [VTransition26CIPageCurlWithShadowTransition class],
        [VTransition27CIPageCurlWithShadowTransition class]
    ];
    
//    transitionClasses = @[[VTransition27CIPageCurlWithShadowTransition class]];

    
    NSInteger classNumber = arc4random_uniform((int)transitionClasses.count);
    
    VTransition *transition = [transitionClasses[classNumber] new];
    
    return transition;
}

@end
