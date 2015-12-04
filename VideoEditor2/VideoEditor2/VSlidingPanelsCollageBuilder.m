//
//  VSlidingPanelsCollageBuilder.m
//  VideoEditor2
//
//  Created by Alexander on 10/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VSlidingPanelsCollageBuilder.h"
#import "CollageSlidingLayout.h"
#import "VTransition01Fading.h"

@implementation VSlidingPanelsCollageBuilder

-(CollageLayout*)makeLayoutWithFrames:(NSArray *)layoutFrames
{
    CollageSlidingLayout* layout = [CollageSlidingLayout new];
    layout.frames = layoutFrames;
    
    return layout;
}

-(VTransition*)makeTransitionBetweenFrame:(VCollageFrame *)frame1 andFrame:(VCollageFrame *)frame2
{
    return nil;
}


-(BOOL)isCollageStatic
{
    return NO;
}

@end
