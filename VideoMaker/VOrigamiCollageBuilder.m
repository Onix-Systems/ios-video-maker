//
//  VOrigamiCollageBuilder.m
//  VideoEditor2
//
//  Created by Alexander on 10/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VOrigamiCollageBuilder.h"

#import "VBookPageOrigamiTransition.h"
#import "VFoldingOrigamiTransition.h"
#import "VAccordionOrigamiTransition.h"
#import "VTwistingOrigamiTransition.h"

@implementation VOrigamiCollageBuilder

-(VTransition*) makeTransitionBetweenFrame:(VCollageFrame *)frame1 andFrame:(VCollageFrame *)frame2
{
    NSArray* transitionClasses = @[[VBookPageOrigamiTransition class], [VFoldingOrigamiTransition class], [VAccordionOrigamiTransition class], [VTwistingOrigamiTransition class]];
    
    NSInteger classNumber = arc4random_uniform((int)transitionClasses.count);
    
    VTransition* transition = [transitionClasses[classNumber] new];
    transition.content1 = frame1;
    transition.content2 = frame2;
    
    return transition;
}


-(BOOL)isCollageStatic
{
    return YES;
}
@end
