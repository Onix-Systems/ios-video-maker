//
//  VideoComposition.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VideoComposition.h"
#import "VideoCompositor.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "VAssetSegment.h"

@interface VideoComposition ()

@property (strong, nonatomic, readwrite) AVAsset* placeholder;

@property (strong, nonatomic, readwrite) AVMutableComposition* mutableComposition;
@property (strong, nonatomic, readwrite) AVMutableVideoComposition* mutableVideoComposition;
@property (strong, nonatomic, readwrite) AVMutableAudioMix* mutableAudioMix;

@property (strong, nonatomic) NSMutableArray* videoTracks;
@property (strong, nonatomic) NSMutableArray* audioTracks;

@property (strong, nonatomic) NSMutableArray<VCompositionInstruction*>* videoCompositionInstructions;
@property (strong, nonatomic) NSMutableArray<AVMutableAudioMixInputParameters*>* audioMixInputParameters;

@end

@implementation VideoComposition

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mutableComposition = [AVMutableComposition new];
        
        self.mutableVideoComposition = [AVMutableVideoComposition new];
        self.mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
        
        self.mutableVideoComposition.customVideoCompositorClass = [VideoCompositor class];
        
        self.mutableAudioMix = [AVMutableAudioMix new];
        
        self.videoTracks = [NSMutableArray new];
        self.audioTracks = [NSMutableArray new];
        self.videoCompositionInstructions = [NSMutableArray new];
        self.audioMixInputParameters = [NSMutableArray new];
    }
    return self;
}

-(void)setFrameSize:(CGSize)frameSize
{
    _frameSize = frameSize;
    self.mutableComposition.naturalSize = frameSize;
    self.mutableVideoComposition.renderSize = frameSize;
}

-(AVAsset*)placeholder
{
    if (_placeholder == nil) {
        NSString* placeholderVideoPath =[NSBundle.mainBundle pathForResource:@"EmptyTrackPleaceholder" ofType: @"m4v"];
        NSURL* placeholderURL = [NSURL fileURLWithPath:placeholderVideoPath];
        _placeholder = [AVURLAsset URLAssetWithURL:placeholderURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
    }
    return _placeholder;
}

-(AVAssetTrack*) getPlaceholderVideoTrack
{
    return [self.placeholder tracksWithMediaType:AVMediaTypeVideo][0];
}

-(void) appendVideoCompositionInstruction: (VCompositionInstruction*) vCompositionInstruction
{
    [self.videoCompositionInstructions addObject:vCompositionInstruction];
    self.mutableVideoComposition.instructions = self.videoCompositionInstructions;
}

-(void) appendAudioMixInputParameters: (AVMutableAudioMixInputParameters*) parameters
{
    [self.audioMixInputParameters addObject:parameters];
    self.mutableAudioMix.inputParameters = self.audioMixInputParameters;
}

-(AVMutableCompositionTrack*) getFreeVideoTrack
{
    return [self getVideoTrackNo: (self.videoTracks.count + 1)];
}

-(AVMutableCompositionTrack*) getVideoTrackNo: (NSInteger) trackNumber
{
    while (self.videoTracks.count < trackNumber) {
        [self.videoTracks addObject:[self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid]];
    };
    
    return self.videoTracks[trackNumber -1];
}

-(AVMutableCompositionTrack*) getAudioTrackNo: (NSInteger) trackNumber
{
    while (self.audioTracks.count < trackNumber) {
        [self.audioTracks addObject:[self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid]];
    };
    
    return self.videoTracks[trackNumber -1];
}

//-(void) generateAVComposition
//{
//    CGSize videoSize = CGSizeMake(720, 480);
//    
//    self.mutableComposition = [AVMutableComposition new];
//    self.mutableComposition.naturalSize = videoSize;
//    
//    NSMutableArray* videoTracks = [NSMutableArray new];
//    
//    [videoTracks addObject: [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:1]];
//    [videoTracks addObject: [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:2]];
//    
//    
//    NSMutableArray* audioTracks = [NSMutableArray new];
//    [audioTracks addObject: [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:3]];
//    [audioTracks addObject: [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:4]];
//    
//    self.mutableVideoComposition = [AVMutableVideoComposition new];
//    self.mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
//    self.mutableVideoComposition.renderSize = videoSize;
//    
//    self.mutableVideoComposition.customVideoCompositorClass = [VideoCompositor class];
//    
//    CMTime currentSegmentStartTime = kCMTimeZero;
//    NSMutableArray* instructions = [NSMutableArray new];
//    
//    NSMutableArray* audioMixParameters = [NSMutableArray new];
//    
//    AVAssetTrack* placeholderVideoTrack  = [self.placeholder tracksWithMediaType:AVMediaTypeVideo][0];
//    
//    for (int i = 0; i < self.segmentsCollection.segmentsCount; i++) {
//        int currentTrackIndex = i % 2;
//        
//        VCompositionSegment* segment = [self.segmentsCollection getSegment:i];
//        CMTime segmentDuration = [segment duration];
//        
//        CMTimeRange timeRangeInOriginal = CMTimeRangeMake(kCMTimeZero, segmentDuration);
//        
//        if ([segment class] == [VAssetSegment class]) {
//            VAssetSegment* aSegment = (VAssetSegment *) aSegment;
//            
//            timeRangeInOriginal = aSegment.cropTimeRange;
//            
//        } else if ([segment class] == [VTransitionSegment class]) {
//            
//            
//        }
//        
//        
//        
//        
//        
////        if (hasTransitionBefore) {
////            transitionTimeRange = CMTimeRangeMake(currentSegmentStartTime, transitionDuration);
////            
////            if (segment.segmentType() == VideoCompositionSegemntType.video) {
////                //Transition from ... to video
////                
////                let passThroughDuration = CMTimeSubtract(timeRangeInOriginal.duration, transitionDuration)
////                if (hasTransitionNext) {
////                    passThroughTimeRange = CMTimeRangeMake(CMTimeAdd(transitionTimeRange!.start, transitionTimeRange!.duration), CMTimeSubtract(passThroughDuration, transitionDuration))
////                } else {
////                    passThroughTimeRange = CMTimeRangeMake(CMTimeAdd(transitionTimeRange!.start, transitionTimeRange!.duration), passThroughDuration)
////                }
////            } else if (segment.segmentType() == .image) {
////                //Transition from ... to image
////                if (previousSegment.segmentType() == VideoCompositionSegemntType.image) {
////                    do {
////                        //image to image transition
////                        //put empty placeholder into transition timerange
////                        try videoTracks[currentTrackIndex].insertTimeRange(CMTimeRangeMake(kCMTimeZero, transitionDuration), ofTrack: placeholderVideoTrack, atTime: currentSegmentStartTime)
////                    } catch _ {
////                    }
////                }
////                
////                //shift start time for the transition duration
////                currentSegmentStartTime = CMTimeAdd(currentSegmentStartTime, transitionDuration)
////                
////                passThroughTimeRange = CMTimeRangeMake(currentSegmentStartTime, timeRangeInOriginal.duration)
////                do {
////                    //fill image timerange with empty placeholder
////                    try videoTracks[currentTrackIndex].insertTimeRange(timeRangeInOriginal, ofTrack: placeholderVideoTrack, atTime: currentSegmentStartTime)
////                } catch _ {
////                }
////            }
////        } else {
////            transitionTimeRange = nil
////            if (segment.segmentType() == VideoCompositionSegemntType.video) {
////                passThroughTimeRange = CMTimeRangeMake(currentSegmentStartTime, CMTimeSubtract(timeRangeInOriginal.duration, transitionDuration))
////                
////            } else if (segment.segmentType() == .image) {
////                passThroughTimeRange = CMTimeRangeMake(currentSegmentStartTime, timeRangeInOriginal.duration)
////            }
////        }
////        
////        if (transitionTimeRange != nil) {
////            let transitionInstruction = TransitionInstuction(curentSegment: segment, curentTrackID: videoTracks[currentTrackIndex].trackID, previousSegment: previousSegment, previousTrackID: videoTracks[1 - currentTrackIndex].trackID, timeRange: transitionTimeRange!)
////            
////            //                var transitionInstruction = AVMutableVideoCompositionInstruction()
////            //                transitionInstruction.timeRange = transitionTimeRange!
////            //                var transitionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTracks[currentTrackIndex])
////            //                transitionInstruction.layerInstructions = [transitionLayerInstruction]
////            
////            instructions.append(transitionInstruction)
////        }
////        
////        let imageSegment = segment as? VideoCompositionImageSegment
////        let videoSegment = segment as? VideoCompositionVideoSegment
////        
////        if (imageSegment != nil) {
////            let segmentInstruction = StillImageInstuction(image: imageSegment!.image.CGImage, timeRange: passThroughTimeRange)
////            instructions.append(segmentInstruction)
////        }
////        
////        if (videoSegment != nil) {
////            do {
////                try videoTracks[currentTrackIndex].insertTimeRange(timeRangeInOriginal, ofTrack: videoSegment!.videoTrack, atTime: currentSegmentStartTime)
////            } catch _ {
////            }
////            
////            if (videoSegment?.audioTrack != nil) {
////                do {
////                    try audioTracks[currentTrackIndex].insertTimeRange(timeRangeInOriginal, ofTrack: videoSegment!.audioTrack, atTime: currentSegmentStartTime)
////                } catch _ {
////                }
////                
////                if (hasTransitionBefore) {
////                    let param1 = AVMutableAudioMixInputParameters(track: audioTracks[currentTrackIndex])
////                    param1.setVolumeRampFromStartVolume(0.0, toEndVolume: 1.0, timeRange: CMTimeRange(start: currentSegmentStartTime, duration: transitionDuration))
////                    audioMixParameters.append(param1)
////                }
////                
////                let param2 = AVMutableAudioMixInputParameters(track: audioTracks[currentTrackIndex])
////                param2.setVolume(1.0, atTime: passThroughTimeRange.start)
////                audioMixParameters.append(param2)
////                
////                if (hasTransitionNext) {
////                    let param3 = AVMutableAudioMixInputParameters(track: audioTracks[currentTrackIndex])
////                    param3.setVolumeRampFromStartVolume(1.0, toEndVolume: 0.0, timeRange: CMTimeRange(start: CMTimeAdd(passThroughTimeRange.start, passThroughTimeRange.duration), duration: transitionDuration))
////                    audioMixParameters.append(param3)
////                }
////            }
////            
////            let segmentInstruction = PassthroughInstuction(passthroughTrackID: videoTracks[currentTrackIndex].trackID, timeRange: passThroughTimeRange)
////            //                var segmentInstruction = AVMutableVideoCompositionInstruction()
////            //                segmentInstruction.timeRange = passThroughTimeRange
////            //                var segmentLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTracks[currentTrackIndex])
////            //                segmentInstruction.layerInstructions = [segmentLayerInstruction]
////            
////            instructions.append(segmentInstruction)
////        }
////        
////        currentSegmentStartTime = CMTimeAdd(passThroughTimeRange.start, passThroughTimeRange.duration);
//    }
//    
//    self.mutableVideoComposition.instructions = instructions;
//    self.mutableAudioMix.inputParameters = audioMixParameters;
//}


//-(void) exportMovieToFileWithCompletion: (void(^)(void)) completionBlock
//{
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    
//    NSDateFormatter* dateFormatter = [NSDateFormatter new];
//    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
//    dateFormatter.timeStyle = NSDateFormatterShortStyle;
//    
//    AVAssetExportSession* exportSession = [AVAssetExportSession exportSessionWithAsset:[self getAsset] presetName:AVAssetExportPresetHighestQuality];
//    
//    NSError* error;
//    
//    NSURL* exportURL = [fileManager URLForDirectory: NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error: &error];
//    
//    exportURL = [exportURL URLByAppendingPathComponent: [dateFormatter stringFromDate: [NSDate new]]];
//    
////    NSString* pathExtension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension));
//    
////    exportURL = [exportURL URLByAppendingPathExtension: pathExtension];
//    
//    NSLog(@"Export movie to URL = \%@", exportURL);
//    
//    exportSession.outputURL = exportURL;
//    
//    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
//    exportSession.shouldOptimizeForNetworkUse = YES;
//    exportSession.videoComposition = self.mutableVideoComposition;
//    exportSession.audioMix = self.mutableAudioMix;
//    
//    [exportSession exportAsynchronouslyWithCompletionHandler:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
//                NSLog(@"Export finished; status==Completed;");
//                
//                ALAssetsLibrary* assetsLibrary = [ALAssetsLibrary new];
//                
//                if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum: exportSession.outputURL]) {
//                    
//                    NSLog(@"Add to asset library");
//                    
//                    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:exportSession.outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
//                        NSLog(@"Finished adding to asset library - %@", error);
//                    }];
//                                                                      
//                }
//            } else {
//                NSLog(@"Export finished; status!=Completed; error=\(exportSession.error)");
//            }
//            
//            completionBlock();
//        });
//    }];
//}

@end
