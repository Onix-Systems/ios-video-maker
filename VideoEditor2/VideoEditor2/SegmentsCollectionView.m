//
//  SegmentsCollectionView.m
//  VideoEditor2
//
//  Created by Alexander on 11/4/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "SegmentsCollectionView.h"
#import "SegmentView.h"
#import "TransitionView.h"
#import "TimePionter.h"

#define pxPerSecond 100.0
#define maxPxPerSecond 300.0
#define minPxPerSecond 40.0

@interface SegmentsCollectionView() <SegmentsThumbnailDrawer>

@property (nonatomic) double currentZoomScale;
@property (nonatomic) double currentScrollingTime;

@property (nonatomic, strong) NSMutableArray<SegmentView*>* segmentViews;
@property (nonatomic, strong) NSMutableArray<TransitionView*>* transitionViews;
@property (nonatomic, strong) UIView* contentContainer;

@property (nonatomic) CMTime totalDuration;

@property (nonatomic, strong) UIPinchGestureRecognizer* pinchGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;

@property (nonatomic) double scrollingStartTime;
@property (nonatomic) double scrollingStartCoordinate;

@property (nonatomic) double zoomingStartScale;
@property (nonatomic) double zoomingStartCurrentScale;

@property (nonatomic, strong) TimePionter* timePointer;

@property (nonatomic, strong) CIContext *thumbanilDrawingContext;

@property (nonatomic) BOOL hasPanActiveGesure;

@end

@implementation SegmentsCollectionView

-(void)setup
{
    if (self.self.segmentViews != nil) {
        return;
    }
    
    self.segmentViews = [NSMutableArray new];
    self.transitionViews = [NSMutableArray new];
    
    self.currentZoomScale = 1;
    
    self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    [self addGestureRecognizer:self.pinchGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.timePointer = [[TimePionter alloc] initWithFrame:self.bounds];
    [self addSubview:self.timePointer];
    
    self.thumbanilDrawingContext = [CIContext contextWithOptions:nil];
    
    self.hasPanActiveGesure = NO;
}

-(UIImage*) renderThumbnail:(CIImage *)thumbailImage frameRect:(CGRect)frameRect
{
    CGImageRef renderedImage = [self.thumbanilDrawingContext createCGImage:thumbailImage fromRect:frameRect];
    
    return [UIImage imageWithCGImage:renderedImage];
}

- (void)pinchGestureAction:(UIPinchGestureRecognizer *)sender
{
    double scaleDiff = 0.0;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.zoomingStartScale = sender.scale;
            self.zoomingStartCurrentScale = self.currentZoomScale;
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateChanged:
            
            scaleDiff = (self.zoomingStartScale - sender.scale);
            
            break;
            
        default:
            break;
    }
    
    self.currentZoomScale = self.zoomingStartCurrentScale - scaleDiff;
    
    self.currentZoomScale = MAX(self.currentZoomScale, minPxPerSecond / pxPerSecond);
    self.currentZoomScale = MIN(self.currentZoomScale, maxPxPerSecond / pxPerSecond);
    
    NSLog(@"Got customPinchGesture with scale=%f currentZoomScale=%f", sender.scale, self.currentZoomScale);
    
    [self setNeedsLayout];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)sender
{
    CGFloat scrollingScreenShift = 0;
    double finalVelocity = 0.0;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint translation = [sender translationInView:self];
            
            self.scrollingStartCoordinate = translation.x;
            self.scrollingStartTime = self.currentScrollingTime;
            
            if (self.delegate != nil) {
                [self.delegate willStartScrolling];
            }
            self.hasPanActiveGesure = YES;
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [sender translationInView:self];
            scrollingScreenShift = (self.scrollingStartCoordinate - translation.x);
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGPoint translation = [sender translationInView:self];
            scrollingScreenShift = (self.scrollingStartCoordinate - translation.x);
            
            finalVelocity = [sender velocityInView:self].x;
            
            self.hasPanActiveGesure = NO;
            if (self.delegate != nil) {
                [self.delegate didFinishScrolling];
            }
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            
            self.hasPanActiveGesure = NO;
            if (self.delegate != nil) {
                [self.delegate didFinishScrolling];
            }
            
        default:
            break;
    }
    
    
    double newScrollingTime = self.scrollingStartTime + (scrollingScreenShift / pxPerSecond) / self.currentZoomScale;
    newScrollingTime = MAX(0, newScrollingTime);
    newScrollingTime = MIN(CMTimeGetSeconds(self.totalDuration), newScrollingTime);
    
    if (self.delegate) {
        [self.delegate didScrollToTime:newScrollingTime];
    }
    
    [self scrollContentToTime:newScrollingTime];

}


-(void) synchronizeToPlayerTime: (double) time{
    if (!self.hasPanActiveGesure) {
        [self scrollContentToTime:time];
    };
}

-(void) scrollContentToTime: (double) time
{
    self.currentScrollingTime = time;
    
    double timePx = (self.bounds.size.width/2.0) - [self getPxForTime:CMTimeMakeWithSeconds(time, 1000)];
    
//    NSLog(@"scrollContentToTime=%f timePx=%f", time, timePx);
    
    self.contentContainer.frame = CGRectMake(timePx, [self getSegmentsVerticalPosition], self.contentContainer.frame.size.width, self.contentContainer.frame.size.height);
}

-(double)getPxForTime: (CMTime)time
{
    return CMTimeGetSeconds(time) * pxPerSecond * self.currentZoomScale;
}

-(double) getSegmentsHeight
{
    return (self.bounds.size.height / 3);
}

-(double) getSegmentsVerticalPosition
{
    return (self.bounds.size.height  - [self getSegmentsHeight]) / 2;
}

-(void) setSegmentsCollection:(VSegmentsCollection *)segmentsCollection
{
    _segmentsCollection = segmentsCollection;
    
    [self setup];

    for (TransitionView* transitionView in self.transitionViews) {
        [transitionView removeFromSuperview];
    }
    [self.transitionViews removeAllObjects];

    for (SegmentView* segmentView in self.segmentViews) {
        [segmentView removeFromSuperview];
    }
    [self.segmentViews removeAllObjects];
    
    if (self.contentContainer != nil) {
        [self.contentContainer removeFromSuperview];
    }
    
    CMTime totalDuration = CMTimeMakeWithSeconds(0, 1000);
    
    for (NSInteger i=0; i < segmentsCollection.segmentsCount; i++) {
        VAssetSegment* segment = segment = [segmentsCollection getSegment:i];
        
        if (segment.frontTransition != nil) {
            CMTime transitionDuration = CMTimeMakeWithSeconds([segment.frontTransition getDuration], 1000);
            
            CGFloat x = [self getPxForTime:totalDuration];
            CGFloat y = 0;
            CGFloat width = [self getPxForTime:transitionDuration];
            CGFloat height = [self getSegmentsHeight];
            
            CGRect transitionFrame = CGRectMake(x, y, width, height);
            
            TransitionView *transitionView = [[TransitionView alloc] initWithFrame:transitionFrame];
            transitionView.transition = segment.frontTransition;
            transitionView.startTime = totalDuration;
            transitionView.calculatedDuration = transitionDuration;
            
            [self.transitionViews addObject:transitionView];
            
            totalDuration = CMTimeAdd(totalDuration, transitionDuration);
        }
        
        CMTime segmentDuration = segment.transitionFreeDuration;
        
        CGFloat segmentX = [self getPxForTime:totalDuration];
        CGFloat segmentY = 0;
        CGFloat segmentWidth = [self getPxForTime:segmentDuration];
        CGFloat segmentHeight = [self getSegmentsHeight];
        
        CGRect segmentFrame = CGRectMake(segmentX, segmentY, segmentWidth, segmentHeight);
        
        SegmentView* segmentView = [[SegmentView alloc] initWithFrame:segmentFrame];
        segmentView.segment = segment;
        segmentView.startTime = totalDuration;
        segmentView.calculatedDuration = segmentDuration;
        
        segmentView.drawer = self;
        
        [self.segmentViews addObject:segmentView];
        
        totalDuration = CMTimeAdd(totalDuration, segmentDuration);
    }
    self.totalDuration = totalDuration;
    
    self.contentContainer = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.0 + [self getPxForTime:CMTimeMakeWithSeconds(self.currentScrollingTime, 1000)], [self getSegmentsVerticalPosition], [self getPxForTime:totalDuration], [self getSegmentsHeight])];
    [self addSubview:self.contentContainer];
    
    for (NSInteger i = 0; i < self.segmentViews.count; i++) {
        [self.contentContainer addSubview: self.segmentViews[i]];
    }
    
    for (NSInteger i = 0; i < self.transitionViews.count; i++) {
        [self.contentContainer addSubview:self.transitionViews[i]];
    }
    
    [self bringSubviewToFront:self.timePointer];
}

-(void) layoutSubviews
{
    if (self.contentContainer == nil) {
        return;
    }
    
    self.contentContainer.frame = CGRectMake(self.bounds.size.width/2.0, [self getSegmentsVerticalPosition], [self getPxForTime:self.totalDuration], [self getSegmentsHeight]);
    
    [self scrollContentToTime: self.currentScrollingTime];
    
    for (NSInteger i = 0; i < self.segmentViews.count; i++) {
        CGFloat x = [self getPxForTime:self.segmentViews[i].startTime];
        CGFloat y = 0;
        CGFloat width = [self getPxForTime:self.segmentViews[i].calculatedDuration];
        CGFloat height = [self getSegmentsHeight];
        
        CGRect frame = CGRectMake(x, y, width, height);
        
        self.segmentViews[i].frame = frame;
    }
    
    for (NSInteger i = 0; i < self.transitionViews.count; i++) {
        CGFloat x = [self getPxForTime:self.transitionViews[i].startTime];
        CGFloat y = 0;
        CGFloat width = [self getPxForTime:self.transitionViews[i].calculatedDuration];
        CGFloat height = [self getSegmentsHeight];
        
        CGRect frame = CGRectMake(x, y, width, height);

        self.transitionViews[i].frame = frame;
    }
    
    self.timePointer.frame = self.bounds;
}


@end
