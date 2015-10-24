//
//  VOrigamiCollageBuilder.m
//  VideoEditor2
//
//  Created by Alexander on 10/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VOrigamiCollageBuilder.h"

#import "VBookPageOrigamiTransition.h"

@implementation VOrigamiCollageBuilder

-(VTransition*) makeTransitionBetweenFrame:(VCollageFrame *)frame1 andFrame:(VCollageFrame *)frame2
{
    VBookPageOrigamiTransition* transition = [VBookPageOrigamiTransition new];
    transition.content1 = frame1;
    transition.content2 = frame2;
    
    return transition;
}

@end
