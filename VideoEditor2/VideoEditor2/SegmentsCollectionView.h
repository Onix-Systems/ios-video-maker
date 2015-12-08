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

@protocol SegmentsCollectionViewDelegate

-(void) willStartScrolling;
-(void) didScrollToTime: (double)time;
-(void) didFinishScrolling;

@end

@interface SegmentsCollectionView : UIView

@property (weak, nonatomic) VSegmentsCollection* segmentsCollection;
@property (weak, nonatomic) id<SegmentsCollectionViewDelegate> delegate;

-(void) synchronizeToPlayerTime: (double) time;

@end
