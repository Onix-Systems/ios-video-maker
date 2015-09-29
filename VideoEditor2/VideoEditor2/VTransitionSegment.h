//
//  VideoCompositionVideoSegment.h
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCompositionSegment.h"
#import "VideoCompositionAssetSegment.h"

@interface VTransitionSegment : VCompositionSegment

@property (weak, nonatomic) VideoCompositionAssetSegment* frontSegment;
@property (weak, nonatomic) VideoCompositionAssetSegment* rearSegment;

@end
