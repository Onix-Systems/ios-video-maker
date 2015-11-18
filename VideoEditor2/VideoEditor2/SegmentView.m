//
//  SegmentView.m
//  VideoEditor2
//
//  Created by Alexander on 11/4/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "SegmentView.h"

@implementation SegmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, self.bounds);
    
    CGContextSetRGBFillColor(context, 1.0, 0.5, 0.5, 1.0);
    CGContextFillRect(context, self.bounds);
    
//    CGRect frameRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
//    UIImage* segmentImage = [self.drawer renderThumbnail:[self.segment getFrameForTime:self.segment.cropTimeRange.start frameSize: frameRect.size] frameRect:frameRect];
//    [segmentImage drawInRect:frameRect];
}

@end
