//
//  VFrameProvider.h
//  VideoEditor2
//
//  Created by Alexander on 10/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <CoreMedia/CoreMedia.h>

#import "VFrameRequest.h"
#import "VideoComposition.h"
#import "VCompositionInstruction.h"

@interface VFrameProvider : NSObject

@property double transitionDurationFront;
@property double transitionDurationRear;

-(CGSize) getOriginalSize;
-(double) getDuration;
-(double) getDurationWithoutTransitions;

-(CIImage*) getFrameForRequest: (VFrameRequest*) request;

-(void)reqisterIntoVideoComposition:(VideoComposition*)videoComposition withInstruction:(VCompositionInstruction*)instruction withFinalSize:(CGSize)finalSize;

@end
