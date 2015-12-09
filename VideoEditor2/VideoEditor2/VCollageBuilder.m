//
//  VCollageBuilder.m
//  VideoEditor2
//
//  Created by Alexander on 10/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VCollageBuilder.h"

#import "VEAspectFill.h"
#import "VTransition01Dissolve.h"

@implementation VCollageBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.previewMode = NO;
    }
    return self;
}

-(VProvidersCollection*)makeCollageWithItems:(NSArray<VFrameProvider *> *)items layoutFrames:(NSArray *)layoutFrames finalSize:(CGSize)finalSize
{
    VProvidersCollection* collage = [VProvidersCollection new];
    collage.finalSize = finalSize;
    
    NSInteger countOfItemsInFrame = layoutFrames.count;
    NSInteger numberOfFrames = (items.count / countOfItemsInFrame) + ((items.count % countOfItemsInFrame > 0) ? 1 : 0);
    VCollageFrame* previousFrame = nil;
    
    NSInteger numberOfFixedFramesAtFinish = (numberOfFrames * countOfItemsInFrame) - items.count;
    
    for (NSInteger i = 0; i < numberOfFrames; i++) {
        VCollageFrame* frame = [VCollageFrame new];
        frame.finalSize = finalSize;
        frame.isStatic = [self isCollageStatic];
        
        NSMutableArray* frameItems = [NSMutableArray new];
        
        CollageLayout* layout = [self makeLayoutWithFrames:layoutFrames];
        frame.collageLayout = layout;
        NSArray* itemsStillFrames = [layout getStillFramesForFinalSize:finalSize];
        
        NSIndexSet* addedItemsIndexes = [NSMutableIndexSet new];
        NSIndexSet* removableItemsIndexes = [NSMutableIndexSet new];
        
        for (NSInteger j = 0; j < countOfItemsInFrame; j++) {
            NSInteger itemNo = (i * countOfItemsInFrame + j);
            
            if ((numberOfFrames > 1) && (i == (numberOfFrames -1)) && (numberOfFixedFramesAtFinish > 0)) {
                addedItemsIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countOfItemsInFrame - numberOfFixedFramesAtFinish)];
                removableItemsIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countOfItemsInFrame)];
                
            } else if ((numberOfFrames > 1) && (i == (numberOfFrames -2)) && (numberOfFixedFramesAtFinish > 0)) {
                addedItemsIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countOfItemsInFrame)];
                removableItemsIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countOfItemsInFrame - numberOfFixedFramesAtFinish)];

            } else {
                addedItemsIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countOfItemsInFrame)];
                removableItemsIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countOfItemsInFrame)];
            }
            
            if (itemNo >= countOfItemsInFrame) {
                while (itemNo >= items.count) {
                    itemNo -= countOfItemsInFrame;
                }

            } else {
                itemNo = itemNo % items.count;
            }
            
            VEffect* collageItem = [self makeCollageItemEffect:items[itemNo]];
            
            CGRect itemStillFrame = [itemsStillFrames[j] CGRectValue];
            collageItem.finalSize = itemStillFrame.size;
            
            [frameItems addObject:collageItem];
            
            if (![collageItem isStatic]) {
                frame.isStatic = NO;
            }
        }
        
        frame.collageLayout.addedItemsIndexes = addedItemsIndexes;
        frame.collageLayout.removableItemsIndexes = removableItemsIndexes;
        
        frame.collageItems = frameItems;
        
        VTransition* transition = nil;
        if (previousFrame != nil) {
            transition = [self makeTransitionBetweenFrame:previousFrame andFrame:frame];
        }
        
        [collage addFrameProvider:frame withFrontTransition:transition];
        
        if (self.previewMode && (i == 0)) {
            collage.startPositionTime = [frame getDuration]/2;
        }
        
        previousFrame = frame;
    }
    
    return collage;
}

-(CollageLayout*)makeLayoutWithFrames:(NSArray *)layoutFrames
{
    CollageLayout* layout = [CollageLayout new];
    layout.frames = layoutFrames;
    
    return layout;
}

-(VEffect*)makeCollageItemEffect:(VFrameProvider *)collageItem
{
    VEAspectFill* itemEffect = [VEAspectFill new];
    
    itemEffect.frameProvider = collageItem;
    
    return itemEffect;
}

-(VTransition*)makeTransitionBetweenFrame:(VCollageFrame *)frame1 andFrame:(VCollageFrame *)frame2
{
    VTransition* transition = [VTransition01Dissolve new];
    
    transition.content1 = frame1;
    transition.content2 = frame2;
    
    return transition;
}

-(BOOL)isCollageStatic
{
    return YES;
}

@end
