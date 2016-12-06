//
//  VideoComposition.h
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "VCompositionInstruction.h"

@interface VideoComposition : NSObject

@property (strong, nonatomic, readonly) AVAsset* placeholder;

@property (strong, nonatomic, readonly) AVMutableComposition* mutableComposition;
@property (strong, nonatomic, readonly) AVMutableVideoComposition* mutableVideoComposition;
@property (strong, nonatomic, readonly) AVMutableAudioMix* mutableAudioMix;

-(AVAssetTrack*) getPlaceholderVideoTrack;

-(AVMutableCompositionTrack*) getVideoTrackNo: (NSInteger) trackNumber;
-(AVMutableCompositionTrack*) getAudioTrackNo: (NSInteger) trackNumber;

-(void) appendVideoCompositionInstruction: (VCompositionInstruction*) vCompositionInstrcution;
-(void) appendAudioMixInputParameters: (AVMutableAudioMixInputParameters*) parameters;

-(void)setVideoFrameSize: (CGSize) videoSize;

@end
