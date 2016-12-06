//
//  CollageLayout.m
//  VideoEditor2
//
//  Created by Alexander on 9/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "CollageLayout.h"

@implementation CollageLayout

+(CollageLayout*)layoutWithFrames:(NSArray*) frames
{
    CollageLayout* layout = [CollageLayout new];
    layout.frames = frames;
    
    return layout;
}

-(CGFloat) getLayoutWidth {
    CGFloat layoutSize = 1;
    
    for (NSInteger i = 0; i < self.frames.count; i++) {
        NSValue *frame = self.frames[i];
        
        CGRect rect = [frame CGRectValue];
        
        layoutSize = MAX(layoutSize, rect.origin.x + rect.size.width);
    }
    
    return layoutSize;
}

-(CGFloat) getLayoutHeight {
    CGFloat layoutSize = 1;
    
    for (NSInteger i = 0; i < self.frames.count; i++) {
        CGRect rect = [self.frames[i] CGRectValue];
        
        layoutSize = MAX(layoutSize, rect.origin.y + rect.size.height);
    }
    
    return layoutSize;
}

-(NSArray*) getLayoutFramesForSize:(CGSize)finalSize
{
    double xScale = finalSize.width / [self getLayoutWidth];
    double yScale = finalSize.height / [self getLayoutHeight];
    
    NSMutableArray *frames = [NSMutableArray new];
    
    for (int i = 0; i < self.frames.count; i++) {
        CGRect src = [self.frames[i] CGRectValue];
        CGRect frame = CGRectMake(src.origin.x * xScale, src.origin.y * yScale, src.size.width * xScale, src.size.height * yScale);
        
        [frames addObject:[NSValue valueWithCGRect:frame]];
    }
    
    return frames;
}

@end
