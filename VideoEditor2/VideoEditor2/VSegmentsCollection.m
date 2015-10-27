//
//  VSegementsCollection.m
//  VideoEditor2
//
//  Created by Alexander on 9/24/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VSegmentsCollection.h"

#import "VAssetSegment.h"
#import "VTransition.h"
#import "VTransitionFactory.h"

@interface VSegmentsCollection ()

@property (strong, nonatomic) NSMutableArray<VAssetSegment *> *segments;
@property (strong, nonatomic) NSMutableArray<VTransition *> *transitions;
@property (strong, nonatomic) VideoComposition* videoComposition;

@end

@implementation VSegmentsCollection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.segments = [NSMutableArray new];
        self.transitions = [NSMutableArray new];
        self.videoComposition = nil;
    }
    return self;
}

-(CMTime)duration
{
    CMTime duration = CMTimeMake(0, 1000);
    
    for (int i = 0; i < self.segments.count; i++) {
        VAssetSegment* segment = self.segments[i];
        
        duration = CMTimeAdd(duration, segment.duration);
    }
    
    return duration;
}

-(NSInteger)segmentsCount
{
    return self.segments.count;
}

-(VAssetSegment*) getSegment : (NSInteger) index
{
    return self.segments[index];
}

-(void)synchronizeTransitions
{
    while (self.transitions.count > (self.segments.count - 1)) {
        [self.transitions removeLastObject];
    }
    
    while ((self.segments.count) && (self.transitions.count < (self.segments.count - 1))) {
        [self.transitions addObject:[VTransitionFactory makeRandomTransition]];
    }
}

-(void)moveSegmentFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    [self.segments insertObject:self.segments[fromIndex] atIndex:toIndex];
    if (fromIndex > toIndex) {
        fromIndex++;
    }
    [self.segments removeObjectAtIndex:fromIndex];
    
    [self synchronizeTransitions];
}

-(void)deleteSegmentAtIndex: (NSInteger) index
{
    [self.segments removeObjectAtIndex:index];
    
    [self synchronizeTransitions];
}


-(void)insertAssetSegment: (VAssetSegment*) aSegement intoPosition: (NSInteger) position
{
    [self.segments insertObject:aSegement atIndex:position];
    
}

-(BOOL)hasAssetInSegments: (VAsset*) asset
{
    for (int i = 0; i < self.segments.count; i++) {
        VAssetSegment *segment = self.segments[i];
        if ([self.segments[i] class] == [VAssetSegment class]) {
            VAssetSegment *aSegment = (VAssetSegment *)segment;
            if (aSegment.asset == asset) {
                return true;
            }
        }
    }
    
    return false;
}

-(void)updateSegmentsFromAssetsCollection
{
    NSArray *assets = [self.assetsCollection getAssets];
    for (int i = 0; i < assets.count; i++) {
        if (![self hasAssetInSegments:assets[i]]) {
            VAssetSegment* segment = [VAssetSegment new];
            segment.asset = assets[i];
            [self insertAssetSegment:segment intoPosition:self.segments.count];
        }
    }
    
    NSMutableArray* segementsToRemove = [NSMutableArray new];
    for (int i = 0; i < self.segments.count; i++) {
        if ([self.segments[i] class] == [VAssetSegment class]) {
            VAssetSegment *aSegment = (VAssetSegment *)self.segments[i];
            if ([assets indexOfObject:aSegment.asset] == NSNotFound) {
                [segementsToRemove addObject:self.segments[i]];
            }
        }
    }
    [self.segments removeObjectsInArray:segementsToRemove];

    [self synchronizeTransitions];
}

-(void)subscribeToAssetsCollectionNotifications
{
    if (self.assetsCollection != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSegmentsFromAssetsCollection) name:kAssetsCollectionAssetAddedNitification object:self.assetsCollection];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSegmentsFromAssetsCollection) name:kAssetsCollectionAssetRemovedNitification object:self.assetsCollection];
    }
}

-(void)unsubscribeFromAssetsCollectionNotifications
{
    if (self.assetsCollection != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAssetsCollectionAssetAddedNitification object:self.assetsCollection];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAssetsCollectionAssetRemovedNitification object:self.assetsCollection];
    }
}

-(void)setAssetsCollection:(AssetsCollection *)assetsCollection {
    [self unsubscribeFromAssetsCollectionNotifications];
    _assetsCollection = assetsCollection;
    [self subscribeToAssetsCollectionNotifications];
    
    [self.segments removeAllObjects];
    
    NSArray* assets = [self.assetsCollection getAssets];
    
    for (int i = 0; i < assets.count ; i++) {
        VAsset* asset = assets[i];
        VAssetSegment* aSegment = [VAssetSegment new];
        aSegment.asset = asset;
        [self insertAssetSegment:aSegment intoPosition:self.segments.count];
    }
    
    [self synchronizeTransitions];
}

-(VideoComposition*)makeVideoCompositionWithFrameSize:(CGSize)frameSize
{
    VideoComposition* videoComposition = [VideoComposition new];
    
    videoComposition.frameSize = frameSize;
    
    CMTime segmentStartTime = kCMTimeZero;
    
    VCompositionInstruction* previousSegmentInstruction;
    
    for (int i = 0; i < self.segmentsCount; i++) {
        VAssetSegment *segment = self.segments[i];
        
        CMTime segmentEndTime = CMTimeAdd(segmentStartTime, segment.duration);
        CMTimeRange segmentTimeRange = CMTimeRangeFromTimeToTime(segmentStartTime, segmentEndTime);

        VFrameProvider* frameProvider =  [segment putFramePrividerIntoVideoComosition:videoComposition withinTimeRange:segmentTimeRange intoTrackNo: 1 + (i%2)];
        
        CMTime instructionStartTime = segmentStartTime;
        CMTime instructionEndTime = segmentEndTime;
        
        VCompositionInstruction *transitionInstruction = nil;
        if (i > 0) {
            VTransition* transition = self.transitions[i-1];
            transition.content1 = previousSegmentInstruction.frameProvider;
            transition.content2 = frameProvider;
            
            double frontDuration = [transition getContent1AppearanceDuration];
            double rearDuration = [transition getContent2AppearanceDuration];
            
            previousSegmentInstruction.frameProvider.transitionDurationRear = frontDuration;
            frameProvider.transitionDurationFront = rearDuration;
            
            CMTimeRange oldTimeRange = previousSegmentInstruction.timeRange;
            CMTime newDurationOfPrevInstruction = CMTimeSubtract(oldTimeRange.duration, CMTimeMakeWithSeconds(frontDuration, 1000));
            previousSegmentInstruction.timeRange = CMTimeRangeMake(oldTimeRange.start , newDurationOfPrevInstruction);
            
            CMTime transitionStartTime = CMTimeAdd(oldTimeRange.start, newDurationOfPrevInstruction);
            CMTime transitionDuration = CMTimeMakeWithSeconds([transition getDuration], 1000);
            CMTimeRange transitionTimeRange = CMTimeRangeMake(transitionStartTime, transitionDuration);
            
            transitionInstruction = [[VCompositionInstruction alloc] initWithFrameProvider:transition];
            transitionInstruction.timeRange = transitionTimeRange;
            transitionInstruction.segmentTimeRange = transitionTimeRange;
            transitionInstruction.containsTweening = YES;
            
            [transition reqisterIntoVideoComposition:videoComposition withInstruction:transitionInstruction withFinalSize:videoComposition.frameSize];
            
            NSArray* trackIDs = previousSegmentInstruction.requiredSourceTrackIDs;
            for (int i = 0; i < trackIDs.count; i++) {
                NSNumber* trackIDNumber = trackIDs[i];
                [transitionInstruction registerTrackIDAsInputFrameProvider:[trackIDNumber intValue]];
            }
            
            
            instructionStartTime = CMTimeAdd(transitionStartTime, transitionDuration);
        }
        
        CMTimeRange instructionTimeRange = CMTimeRangeFromTimeToTime(instructionStartTime, instructionEndTime);
        
        VCompositionInstruction *instruction = [[VCompositionInstruction alloc] initWithFrameProvider:frameProvider];
        instruction.timeRange = instructionTimeRange;
        instruction.segmentTimeRange = segmentTimeRange;
        instruction.containsTweening = YES;
        
        [frameProvider reqisterIntoVideoComposition:videoComposition withInstruction:instruction withFinalSize:videoComposition.frameSize];
        
        if (transitionInstruction) {
            NSArray* trackIDs = instruction.requiredSourceTrackIDs;
            for (int i = 0; i < trackIDs.count; i++) {
                NSNumber* trackIDNumber = trackIDs[i];
                [transitionInstruction registerTrackIDAsInputFrameProvider:[trackIDNumber intValue]];
            }
        
            [videoComposition appendVideoCompositionInstruction:transitionInstruction];
        }

        
        [videoComposition appendVideoCompositionInstruction:instruction];

        previousSegmentInstruction = instruction;
        segmentStartTime = segmentEndTime;
    }
    
    return videoComposition;
}

@end
