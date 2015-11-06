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

@interface SegmentView : UIView

@property (nonatomic, weak) VAssetSegment* segment;
@property (nonatomic) CMTime startTime;
@property (nonatomic) CMTime calculatedDuration;

- (instancetype)initWithFrame:(CGRect)frame;


@end
