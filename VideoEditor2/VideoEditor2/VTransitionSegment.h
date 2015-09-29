//
//  VideoCompositionVideoSegment.h
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCompositionSegment.h"
@class VAssetSegment;

@interface VTransitionSegment : VCompositionSegment

@property (weak, nonatomic) VAssetSegment* frontSegment;
@property (weak, nonatomic) VAssetSegment* rearSegment;

@property (strong, nonatomic) NSString* transitionType;
@property (nonatomic, readwrite) CMTime transitionDuration;

-(CIImage*) drawTransitionForTime: (CMTime) inputTime frontFrame: (CIImage*) frontFrame rearFrame: (CIImage*) rearFrame;

@end
