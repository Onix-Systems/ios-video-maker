//
//  VKenBurnsCollageBuilder.m
//  VideoEditor2
//
//  Created by Alexander on 10/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VKenBurnsCollageBuilder.h"

#import "VEKenBurns.h"

@implementation VKenBurnsCollageBuilder


-(VEffect*)makeCollageItemEffect:(VFrameProvider *)collageItem
{
    VEKenBurns* itemEffect = [VEKenBurns new];
    
    itemEffect.frameProvider = collageItem;
    
    return itemEffect;
}


-(BOOL)isCollageStatic
{
    return NO;
}

@end
