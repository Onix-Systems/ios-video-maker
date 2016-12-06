//
//  CollageSlidingLayout.h
//  VideoEditor2
//
//  Created by Alexander on 10/19/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollageLayout.h"

#define kSlidingPanelsDirectionToLeft @"kSlidingPanelsDirectionToLeft"
#define kSlidingPanelsDirectionToRight @"kSlidingPanelsDirectionToRight"
#define kSlidingPanelsDirectionToTop @"kSlidingPanelsDirectionToTop"
#define kSlidingPanelsDirectionToBottom @"kSlidingPanelsDirectionToBottom"

#define kSlidingPanelsTotalDuration 2.0
#define kSlidingPanelsSlidingDuration 0.5

@interface CollageSlidingLayout : CollageLayout

@property (nonatomic, strong) NSArray* slideInDirections;
@property (nonatomic, strong) NSArray* slideOutDirections;

@property (nonatomic) double totalDuration;
@property (nonatomic) double slideInDuration;
@property (nonatomic) double slideOutDuration;

@end
