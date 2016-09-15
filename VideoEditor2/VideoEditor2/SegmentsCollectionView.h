//
//  SegmentsCollectionView.h
//  VideoEditor2
//
//  Created by Alexander on 11/4/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "VSegmentsCollection.h"
@class VAsset;

@protocol SegmentsCollectionViewDelegate

-(void) willStartScrolling;
-(void) didScrollToTime: (double)time;
-(void) didFinishScrolling;
-(void) assetSelected:(VAsset *)asset;

@end

@interface SegmentsCollectionView : UIView

@property (weak, nonatomic) VSegmentsCollection* segmentsCollection;
@property (weak, nonatomic) id<SegmentsCollectionViewDelegate> delegate;

//Default is 5
@property (nonatomic) NSInteger countSmallLineBetweenSeconds;

//Default is 35
@property (nonatomic) CGFloat timeLineHeight;

-(void) synchronizeToPlayerTime: (double) time;
-(VAsset *)getSelectedSegment;

@end
