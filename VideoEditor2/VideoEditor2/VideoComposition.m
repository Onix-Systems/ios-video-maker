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
