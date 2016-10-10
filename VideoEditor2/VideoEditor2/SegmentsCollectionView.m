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

@interface SegmentsCollectionView() <SegmentsThumbnailDrawer, SegmentViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) double currentZoomScale;
@property (nonatomic) double currentScrollingTime;

@property (nonatomic, strong) NSMutableArray<SegmentView*>* segmentViews;
@property (nonatomic, strong) NSMutableArray<TransitionView*>* transitionViews;
@property (nonatomic, strong) UIView* contentContainer;

@property (nonatomic) CMTime totalDuration;

@property (nonatomic, strong) UIPinchGestureRecognizer* pinchGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer* swipeLeftGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer* swipeRightGestureRecognizer;

@property (nonatomic) double scrollingStartTime;
@property (nonatomic) double scrollingStartCoordinate;

@property (nonatomic) double zoomingStartScale;
@property (nonatomic) double zoomingStartCurrentScale;

@property (nonatomic, strong) TimePionter* timePointer;

@property (nonatomic, strong) CIContext *thumbanilDrawingContext;

@property (nonatomic) BOOL hasPanActiveGesure;

@property (nonatomic, strong) SegmentView *selectedSegmentView;
@property (nonatomic, strong) UIView *timeLineView;
@property (nonatomic, strong) UIView *timeLineBackgroundView;

@end

@implementation SegmentsCollectionView

-(void)setup
{
    if (self.self.segmentViews != nil) {
        return;
    }
    self.countSmallLineBetweenSeconds = 5;
    self.timeLineHeight = 35;
    
    self.segmentViews = [NSMutableArray new];
    self.transitionViews = [NSMutableArray new];
    
    self.currentZoomScale = 1;
    
    self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    [self addGestureRecognizer:self.pinchGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureAction:)];
    [self.swipeLeftGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    self.swipeLeftGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.swipeLeftGestureRecognizer];
    
    self.swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureAction:)];
    [self.swipeRightGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    self.swipeRightGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.swipeRightGestureRecognizer];
   
    self.timePointer = [[TimePionter alloc] initWithFrame:self.bounds];
    self.timePointer.userInteractionEnabled = NO;
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
    CGRect newRect = self.timeLineView.frame;
    newRect.origin.x = self.contentContainer.frame.origin.x;
    self.timeLineView.frame = newRect;
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
    return self.timeLineHeight;
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
    
    if (self.timeLineView != nil) {
        [self.timeLineView removeFromSuperview];
        
    }
    
    if (self.timeLineBackgroundView != nil) {
        [self.timeLineBackgroundView removeFromSuperview];
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
        segmentView.delegate = self;
        
        [self.segmentViews addObject:segmentView];
        
        totalDuration = CMTimeAdd(totalDuration, segmentDuration);
    }
    self.totalDuration = totalDuration;
    
    self.contentContainer = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.0 + [self getPxForTime:CMTimeMakeWithSeconds(self.currentScrollingTime, 1000)], [self getSegmentsVerticalPosition], [self getPxForTime:totalDuration], [self getSegmentsHeight])];
    [self addSubview:self.contentContainer];
    
    
    CGFloat countSecond = CMTimeGetSeconds(totalDuration);
    if (countSecond > 0) {
        [self drawTimeLineByTime:countSecond];
    }
    
    for (NSInteger i = 0; i < self.segmentViews.count; i++) {
        [self.contentContainer addSubview: self.segmentViews[i]];
    }
    
    for (NSInteger i = 0; i < self.transitionViews.count; i++) {
        [self.contentContainer addSubview:self.transitionViews[i]];
    }
    
    [self bringSubviewToFront:self.timePointer];
}

-(void)drawTimeLineByTime:(CGFloat)seconds {
    CGRect contentFrame = self.contentContainer.frame;
    self.timeLineBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.timeLineHeight)];
    self.timeLineBackgroundView.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:58.0/255.0 blue:78.0/255.0 alpha:1.0];
    
    [self addSubview:self.timeLineBackgroundView];
    
    self.timeLineView = [[UIView alloc] initWithFrame:CGRectMake(contentFrame.origin.x, 0, contentFrame.size.width, self.timeLineHeight)];
    self.timeLineView.clipsToBounds = YES;
    self.timeLineView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.timeLineView];
    
    [self drawLineInTimeLineByTime:seconds];
}

-(void)drawLineInTimeLineByTime:(CGFloat)seconds {
    UIColor *lineColor = [UIColor colorWithRed:98.0/255.0 green:100.0/255.0 blue:119.0/255.0 alpha:1.0];
    for (NSInteger i = 0; i <= seconds; i++) {
        UIView *line = [UIView new];
        line.backgroundColor = lineColor;
        CGRect frameTimeLine = self.timeLineView.frame;
        CGFloat positionLine = ((frameTimeLine.size.width - 1) / seconds) * i;
        CGFloat heigthLine = frameTimeLine.size.height * 0.65;
        line.frame = CGRectMake(positionLine,
                                frameTimeLine.origin.y + (frameTimeLine.size.height - heigthLine),
                                1,
                                heigthLine);
        [self.timeLineView addSubview:line];
        
        if (i < seconds) {
            CGFloat firstLinePosition = (frameTimeLine.size.width / seconds) * i;
            CGFloat secondLinePosition = (frameTimeLine.size.width / seconds) * (i + 1);
            CGFloat durationBetweenSeconds = (secondLinePosition - firstLinePosition);
            
            for (NSInteger lineNumber = 1; lineNumber <= self.countSmallLineBetweenSeconds; lineNumber++) {
                CGFloat smallLinePosition = (durationBetweenSeconds / (self.countSmallLineBetweenSeconds + 1) * lineNumber) + firstLinePosition;
                
                UIView *smallLine = [UIView new];
                smallLine.backgroundColor = lineColor;
                CGRect frameTimeLine = self.timeLineView.frame;
                CGFloat heigthLine = frameTimeLine.size.height * 0.35;
                smallLine.frame = CGRectMake(smallLinePosition,
                                             frameTimeLine.origin.y + (frameTimeLine.size.height - heigthLine),
                                             1,
                                             heigthLine);
                [self.timeLineView addSubview:smallLine];
            }
        }
    }
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

-(VAsset *)getSelectedSegment {
    return self.selectedSegmentView.segment.asset;
}

#pragma SegmentViewDelegate 
-(void)segmentViewTapped:(SegmentView *)view {
    
    if ([self.selectedSegmentView isEqual:view]) {
        [self deselectSelectedSegmentView];
    } else {
        [self.selectedSegmentView changeHighlightingView:NO];
        [view changeHighlightingView:YES];
        self.selectedSegmentView = view;
        [self.delegate assetSelected:view.segment.asset];
    }
}


- (void)swipeGestureAction:(UISwipeGestureRecognizer *)sender {
    [self deselectSelectedSegmentView];
}

- (void)deselectSelectedSegmentView {
    [self.delegate assetDeselected:self.selectedSegmentView.segment.asset];
    [self.selectedSegmentView changeHighlightingView:NO];
    self.selectedSegmentView = nil;
}

#pragma mark - UIGesturerecognizerdelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
