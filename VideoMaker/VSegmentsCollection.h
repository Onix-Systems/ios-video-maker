//
//  VSegementsCollection.h
//  VideoEditor2
//
//  Created by Alexander on 9/24/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AssetsCollection.h"
#import "VAssetSegment.h"
#import "VideoComposition.h"

#define kVSegmentsCollectionModifiedNotification @"kVSegmentsCollectionModifiedNotification";

@interface VSegmentsCollection : NSObject

@property (nonatomic, readonly) NSInteger segmentsCount;
@property (nonatomic, readonly) CMTime zzzDuration;

@property (weak, nonatomic) AssetsCollection* assetsCollection;

-(void) moveSegmentFromIndex: (NSInteger) fromIndex toIndex: (NSInteger) toIndex;
-(void) deleteSegmentAtIndex: (NSInteger) index;
-(VAssetSegment*) getSegment: (NSInteger) index;


-(VideoComposition*) makeVideoCompositionWithFrameSize: (CGSize) frameSize;

-(void) resetSegmentsState;

@end
