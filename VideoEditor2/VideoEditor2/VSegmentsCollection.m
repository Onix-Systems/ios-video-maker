//
//  VSegementsCollection.m
//  VideoEditor2
//
//  Created by Alexander on 9/24/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VSegmentsCollection.h"

#import "VAssetSegment.h"
#import "VTransitionSegment.h"

@interface VSegmentsCollection ()

@property (strong, nonatomic) NSMutableArray<VCompositionSegment *> *segments;
@property (strong, nonatomic) VideoComposition* videoComposition;

@end

@implementation VSegmentsCollection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.segments = [NSMutableArray new];
        self.videoComposition = nil;
    }
    return self;
}

-(CMTime)duration
{
    CMTime duration = CMTimeMake(0, 1000);
    
    for (int i = 0; i < self.segments.count; i++) {
        VCompositionSegment* segment = self.segments[i];
        
        duration = CMTimeAdd(duration, segment.duration);
    }
    
    return duration;
}

-(NSInteger) segmentsCount
{
    return self.segments.count;
}

-(VCompositionSegment*) getSegment : (NSInteger) index
{
    return self.segments[index];
}

-(void) moveSegmentFromIndex: (NSInteger) fromIndex toIndex: (NSInteger) toIndex
{
    [self.segments insertObject:self.segments[fromIndex] atIndex:toIndex];
    if (fromIndex > toIndex) {
        fromIndex++;
    }
    [self.segments removeObjectAtIndex:fromIndex];
}

-(void) insertAssetSegment: (VAssetSegment*) aSegement intoPosition: (NSInteger) position
{
    [self.segments insertObject:aSegement atIndex:position];
    
//    VTransitionSegment *newFrontTransitionSegment = nil;
//   
//    if (self.segments.count > position) {
//        VCompositionSegment *prevSegment = self.segments[position - 1];
//        
//        if ([prevSegment class] == [VTransitionSegment class]) {
//            VTransitionSegment *prevTSegment = (VTransitionSegment *)prevSegment;
//            prevTSegment.rearSegment = aSegement;
//            
//        } else if ([prevSegment class] == [VAssetSegment class]) {
//            newFrontTransitionSegment = [VTransitionSegment new];
//            
//            VAssetSegment *prevASegment = (VAssetSegment *)prevSegment;
//            
//            newFrontTransitionSegment.frontSegment = prevASegment;
//            prevASegment.rearTransition = newFrontTransitionSegment;
//            
//            newFrontTransitionSegment.rearSegment = aSegement;
//            aSegement.frontTransition = newFrontTransitionSegment;
//        }
//    }
//    
//    if (newFrontTransitionSegment != nil) {
//        [self.segments insertObject:newFrontTransitionSegment atIndex:position];
//    }
}

-(void) deleteSegmentAtIndex: (NSInteger) index
{
    if (index >= self.segments.count || index < 0) {
        return;
    }
    
    //    VCompositionSegment* frontSegment = nil;
    //    if (index > 0) {
    //        frontSegment = self.segments[(index - 1)];
    //    }
    //
    //    VCompositionSegment* rearSegment = nil;
    //    if (index + 1 < self.segments.count) {
    //        rearSegment = self.segments[index +1];
    //    }
    //
    //    VCompositionSegment *segmemtForDeletion = self.segments[index];
    //
    //    if ([segmemtForDeletion class] == [VAssetSegment class]) {
    //        if (frontSegment != nil) {
    //            if ()
    //        }
    //
    //    } else if ([segmemtForDeletion class] == [VTransitionSegment class]) {
    //
    //    }
    //    
    
    [self.segments removeObjectAtIndex:index];
}

-(BOOL) hasAssetInSegments: (VAsset*) asset
{
    for (int i = 0; i < self.segments.count; i++) {
        VCompositionSegment *segment = self.segments[i];
        if ([self.segments[i] class] == [VAssetSegment class]) {
            VAssetSegment *aSegment = (VAssetSegment *)segment;
            if (aSegment.asset == asset) {
                return true;
            }
        }
    }
    
    return false;
}

-(void) updateSegmentsFromAssetsCollection
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
}

-(void) subscribeToAssetsCollectionNotifications
{
    if (self.assetsCollection != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSegmentsFromAssetsCollection) name:kAssetsCollectionAssetAddedNitification object:self.assetsCollection];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSegmentsFromAssetsCollection) name:kAssetsCollectionAssetRemovedNitification object:self.assetsCollection];
    }
}

-(void) unsubscribeFromAssetsCollectionNotifications
{
    if (self.assetsCollection != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAssetsCollectionAssetAddedNitification object:self.assetsCollection];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAssetsCollectionAssetRemovedNitification object:self.assetsCollection];
    }
}

-(void) setAssetsCollection:(AssetsCollection *)assetsCollection {
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
}

-(VideoComposition*) getVideoComposition
{
    self.videoComposition = [self makeVideoComposition];
    
    return self.videoComposition;
}

-(VideoComposition*) makeVideoComposition
{
    VideoComposition* videoComposition = [VideoComposition new];
    
    CMTime segmentStartTime = kCMTimeZero;
    for (int i = 0; i < self.segmentsCount; i++) {
        VCompositionSegment *segment = self.segments[i];
        
        CMTime segmentEndTime = CMTimeAdd(segmentStartTime, segment.duration);
        
        CMTimeRange segmentTimeRange = CMTimeRangeFromTimeToTime(segmentStartTime, segmentEndTime);
        
        if ([segment class] == [VAssetSegment class]) {
            VAssetSegment* aSegment = (VAssetSegment*)segment;
            
            [aSegment putIntoVideoComosition :videoComposition withinTimeRange:segmentTimeRange intoTrackNo: 1 + (i%2) ];
        }

        segmentStartTime = segmentEndTime;
    }
    
    return videoComposition;
}

@end
