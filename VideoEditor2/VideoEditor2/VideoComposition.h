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

#import "VRenderingStats.h"

@interface VideoComposition : NSObject <VRenderingStats>

@property (strong, nonatomic, readonly) AVAsset* placeholder;

@property (strong, nonatomic, readonly) AVMutableComposition* mutableComposition;
@property (strong, nonatomic, readonly) AVMutableVideoComposition* mutableVideoComposition;
@property (strong, nonatomic, readonly) AVMutableAudioMix* mutableAudioMix;

@property (nonatomic) CGSize frameSize;

-(AVAssetTrack*) getPlaceholderVideoTrack;

-(AVMutableCompositionTrack*) getFreeVideoTrack;
-(AVMutableCompositionTrack*) getVideoTrackNo: (NSInteger) trackNumber;
-(AVMutableCompositionTrack*) getFreeAudioTrack;
-(AVMutableCompositionTrack*) getAudioTrackNo: (NSInteger) trackNumber;

-(void) appendVideoCompositionInstruction: (VCompositionInstruction*) vCompositionInstruction;
-(void) appendAudioMixInputParameters: (AVMutableAudioMixInputParameters*) parameters;
-(void) exportMovieToFileWithCompletion: (void(^)(NSError *error)) completionBlock;
@end
