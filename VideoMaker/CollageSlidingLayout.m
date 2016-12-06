//
//  CollageSlidingLayout.m
//  VideoEditor2
//
//  Created by Alexander on 10/19/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "CollageSlidingLayout.h"

@interface CollageSlidingLayout()

@property (nonatomic, strong) NSMutableArray* repeatingFrameNumbers;

@end

@implementation CollageSlidingLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.totalDuration = kSlidingPanelsTotalDuration;
        self.slideInDuration = kSlidingPanelsSlidingDuration;
        self.slideOutDuration = kSlidingPanelsSlidingDuration;
        
        self.repeatingFrameNumbers = [NSMutableArray new];
    }
    return self;
}


-(NSArray*)getSlidingDirectoinsForFrame:(CGRect)frame totalSize:(CGSize)totalSize
{
    NSMutableArray* possibleDirections = [NSMutableArray new];
    if (frame.origin.x == 0) {
        [possibleDirections addObject:kSlidingPanelsDirectionToLeft];
    }
    if (frame.origin.y == 0) {
        [possibleDirections addObject:kSlidingPanelsDirectionToBottom];
    }
    if ((frame.origin.x + frame.size.width) == totalSize.width) {
        [possibleDirections addObject:kSlidingPanelsDirectionToRight];
    }
    if ((frame.origin.y + frame.size.height) == totalSize.height) {
        [possibleDirections addObject:kSlidingPanelsDirectionToTop];
    }
    
    return possibleDirections;
}

-(void)setFrames:(NSArray<NSValue *> *)frames
{
    [super setFrames:frames];
    
    NSArray* slidingDirections = @[
                                   kSlidingPanelsDirectionToLeft,
                                   kSlidingPanelsDirectionToRight,
                                   kSlidingPanelsDirectionToTop,
                                   kSlidingPanelsDirectionToBottom
                                   ];
    CGSize totalSize = CGSizeMake([self getLayoutWidth], [self getLayoutHeight]);

    
    NSMutableArray* slideInDirections = [NSMutableArray new];
    NSMutableArray* slideOutDirections = [NSMutableArray new];
    
    
    NSArray* stillFrames = [self getStillFramesForFinalSize:totalSize];
    
    for (int i = 0; i < stillFrames.count; i++) {
        NSArray* framePossibleSlidingDirections = [self getSlidingDirectoinsForFrame:[stillFrames[i] CGRectValue] totalSize:totalSize];
        if (framePossibleSlidingDirections.count > 0) {
            NSString* slideInDirection = framePossibleSlidingDirections[arc4random_uniform((int)framePossibleSlidingDirections.count)];
            [slideInDirections addObject:slideInDirection];
            NSString* slideOutDirection = framePossibleSlidingDirections[arc4random_uniform((int)framePossibleSlidingDirections.count)];
            [slideOutDirections addObject:slideOutDirection];
            
        } else {
            [slideInDirections addObject:slidingDirections[arc4random_uniform((int)slidingDirections.count)]];
            [slideOutDirections addObject:slidingDirections[arc4random_uniform((int)slidingDirections.count)]];
        }
    }
    
    self.slideInDirections = slideInDirections;
    self.slideOutDirections = slideOutDirections;
}

-(NSMutableArray*) calculateSlideInForFrames:(NSArray*)stillFrames slideInPercent:(double)slideInPercent
{
    NSMutableArray* frames = [NSMutableArray new];
    
    //double k = 1 - ((1 + sin(3.1415 * (-0.5 + slideInPercent))) / 2);
    double k = 1 - slideInPercent;
    
    for (int i = 0; i < stillFrames.count; i++) {
        NSString *direction = self.slideInDirections[i];
        
        CGRect frame = [stillFrames[i] CGRectValue];
        
        double x = frame.origin.x;
        double y = frame.origin.y;
        double width = frame.size.width;
        double height = frame.size.height;
        
        if ([direction isEqual:kSlidingPanelsDirectionToLeft]) {
            x = x - width * k;
        }
        
        if ([direction isEqual:kSlidingPanelsDirectionToRight]) {
            x = x + width * k;
        }
        
        if ([direction isEqual:kSlidingPanelsDirectionToTop]) {
            y = y + height * k;
        }
        
        if ([direction isEqual:kSlidingPanelsDirectionToBottom]) {
            y = y - height * k;
        }
        
        [frames addObject:[NSValue valueWithCGRect:CGRectMake(x, y, width, height)]];
    }
    
    return frames;
}

-(NSMutableArray*) calculateSlideOutForFrames:(NSArray*)stillFrames slideOutPercent:(double)slideOutPercent
{
    NSMutableArray* frames = [NSMutableArray new];
    
    //double k = (1 + sin(3.1415 * (-0.5 + slideOutPercent))) / 2;
    double k = slideOutPercent;
    
    for (int i = 0; i < stillFrames.count; i++) {
        NSString *direction = self.slideOutDirections[i];
        
        CGRect frame = [stillFrames[i] CGRectValue];
        
        double x = frame.origin.x;
        double y = frame.origin.y;
        double width = frame.size.width;
        double height = frame.size.height;
        
        if ([direction isEqual:kSlidingPanelsDirectionToLeft]) {
            x = x - width * k;
        }
        
        if ([direction isEqual:kSlidingPanelsDirectionToRight]) {
            x = x + width * k;
        }
        
        if ([direction isEqual:kSlidingPanelsDirectionToTop]) {
            y = y + height * k;
        }
        
        if ([direction isEqual:kSlidingPanelsDirectionToBottom]) {
            y = y - height * k;
        }
        
        [frames addObject:[NSValue valueWithCGRect:CGRectMake(x, y, width, height)]];
    }
    
    return frames;
}

-(NSArray*) getStillFramesForFinalSize:(CGSize)finalSize
{
    return [super getStillFramesForFinalSize:finalSize];
}

-(NSArray*) restoreSlideInFramesPositions: (NSMutableArray*)shiftedFrames stillFrames:(NSArray*)stillFrames
{
    if (self.addedItemsIndexes == nil) {
        return nil;
    }
    for (NSInteger i = 0; i < shiftedFrames.count; i++) {
        if (![self.addedItemsIndexes containsIndex:i]) {
            shiftedFrames[i] = stillFrames[i];
        }
    }
    
    return shiftedFrames;
}

-(NSArray*) restoreSlideOutFramesPositions: (NSMutableArray*)shiftedFrames stillFrames:(NSArray*)stillFrames
{
    if (self.removableItemsIndexes == nil) {
        return nil;
    }
    for (NSInteger i = 0; i < shiftedFrames.count; i++) {
        if (![self.removableItemsIndexes containsIndex:i]) {
            shiftedFrames[i] = stillFrames[i];
        }
    }
    
    return shiftedFrames;
}

-(NSArray*) getFramesForFinalSize:(CGSize)finalSize andTime:(double)time
{
    NSArray* stillFrames = [self getStillFramesForFinalSize:finalSize];
    NSMutableArray* finalFrames = nil;
    
    if ((self.slideInDuration > 0) && (time < self.slideInDuration)) {
        double slideInPercent = time/self.slideInDuration;
        finalFrames = [self calculateSlideInForFrames:stillFrames slideInPercent:slideInPercent];
        return [self restoreSlideInFramesPositions:finalFrames stillFrames:stillFrames];
    }
    
    if ((self.slideOutDuration > 0) && (time > (self.totalDuration - self.slideOutDuration))) {
        double slideOutPercent = (time - (self.totalDuration - self.slideOutDuration)) / self.slideOutDuration;
        finalFrames = [self calculateSlideOutForFrames:stillFrames slideOutPercent:slideOutPercent];
        return [self restoreSlideOutFramesPositions:finalFrames stillFrames:stillFrames];
    }
    
    return stillFrames;
}

-(BOOL)isLayoutStatic
{
    return NO;
}

-(void)markFrameAsRepeating:(NSInteger)frameNo
{
    [self.repeatingFrameNumbers addObject:[NSNumber numberWithInteger:frameNo]];
}

@end
