//
//  SegmentView.h
//  VideoEditor2
//
//  Created by Alexander on 11/4/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VAssetSegment.h"
@class SegmentView;

@protocol SegmentsThumbnailDrawer

-(UIImage*) renderThumbnail:(CIImage *)thumbailImage frameRect:(CGRect)frameRect;

@end

@protocol SegmentViewDelegate

-(void)segmentViewTapped:(SegmentView *)view;

@end

@interface SegmentView : UIView

@property (nonatomic, weak) VAssetSegment* segment;
@property (nonatomic) CMTime startTime;
@property (nonatomic) CMTime calculatedDuration;

@property (nonatomic, weak) id<SegmentsThumbnailDrawer> drawer;
@property (nonatomic, weak) id<SegmentViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

-(void)changeHighlightingView:(BOOL)highlighted;

@end
