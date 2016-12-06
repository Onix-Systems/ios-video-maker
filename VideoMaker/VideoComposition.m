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

@import Photos;

@interface VideoComposition () <VFPSTracker>

@property (strong, nonatomic, readwrite) AVAsset* placeholder;

@property (strong, nonatomic, readwrite) AVMutableComposition* mutableComposition;
@property (strong, nonatomic, readwrite) AVMutableVideoComposition* mutableVideoComposition;
@property (strong, nonatomic, readwrite) AVMutableAudioMix* mutableAudioMix;

@property (strong, nonatomic) NSMutableArray* videoTracks;
@property (strong, nonatomic) NSMutableArray* audioTracks;

@property (strong, nonatomic) NSMutableArray<VCompositionInstruction*>* videoCompositionInstructions;
@property (strong, nonatomic) NSMutableArray<AVMutableAudioMixInputParameters*>* audioMixInputParameters;

@property () double totalFrameRequests;
@property () double totalRequestsDuration;
@property () double minRequestsDuration;
@property () double maxRequestsDuration;

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
        
        self.totalFrameRequests = 0;
        self.totalRequestsDuration = 0;
        self.minRequestsDuration = 0;
        self.maxRequestsDuration = 0;
    }
    return self;
}

-(void) trackFrameRenderingDuration:(double)duration
{
    if (self.totalFrameRequests < 300) {
        self.minRequestsDuration = self.minRequestsDuration == 0 ? duration : MIN(duration, self.minRequestsDuration);
        self.maxRequestsDuration = MAX(duration, self.maxRequestsDuration);
    
        self.totalFrameRequests++;
        self.totalRequestsDuration += duration;
    } else {
        self.minRequestsDuration = duration;
        self.maxRequestsDuration = duration;
        self.totalFrameRequests = 1;
        self.totalRequestsDuration = duration;
    }
}

-(double) getMinDuration
{
    return self.minRequestsDuration;
}

-(double) getMaxDuration
{
    return self.maxRequestsDuration;
}

-(double) getAverageDuration
{
    return self.totalRequestsDuration / self.totalFrameRequests;
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
    
    vCompositionInstruction.fpsTracker = self;
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

-(AVMutableCompositionTrack*) getFreeAudioTrack
{
    return [self getAudioTrackNo: (self.audioTracks.count + 1)];
}

-(AVMutableCompositionTrack*) getAudioTrackNo: (NSInteger) trackNumber
{
    while (self.audioTracks.count < trackNumber) {
        [self.audioTracks addObject:[self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid]];
    };
    
    return self.audioTracks[trackNumber -1];
}

-(void)exportMovieToFileWithCompletion: (void(^)(NSError * error))completionBlock
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    AVAssetExportSession* exportSession = [AVAssetExportSession exportSessionWithAsset:self.mutableComposition presetName:AVAssetExportPresetHighestQuality];
    
    NSError* error;
    
    NSURL* exportURL = [fileManager URLForDirectory: NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error: &error];
    
    exportURL = [exportURL URLByAppendingPathComponent: [NSString stringWithFormat:@"%@.mov",[dateFormatter stringFromDate: [NSDate new]]]];
    
//    NSString* pathExtension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension));
    
//    exportURL = [exportURL URLByAppendingPathExtension: pathExtension];
    
    NSLog(@"Export movie to URL = \%@", exportURL);
    
    exportSession.outputURL = exportURL;
    
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.videoComposition = self.mutableVideoComposition;
    exportSession.audioMix = self.mutableAudioMix;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveToLibraryWithExportSession:exportSession andCompletion:completionBlock];
        });
    }];
}

-(void)saveToLibraryWithExportSession:(AVAssetExportSession *)exportSession
                        andCompletion:(void(^)(NSError * error))completionBlock {
    if (exportSession.status == AVAssetExportSessionStatusCompleted) {
        NSLog(@"Export finished; status==Completed;");
        
        __block PHObjectPlaceholder *placeholder;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL: exportSession.outputURL];
            placeholder = [createAssetRequest placeholderForCreatedAsset];
            
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *removeError;
                BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtURL:exportSession.outputURL error:&removeError];
                if (removeSuccess) {
                    NSLog(@"File deleted");
                } else {
                    NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                }
                
                if (success) {
                    NSLog(@"didFinishRecordingToOutputFileAtURL - success");
                    completionBlock(nil);
                } else {
                    NSLog(@"%@", error);
                    completionBlock(error);
                }
            });
        }];
    } else {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        NSString *message = [NSString stringWithFormat:@"AVAssetExportSessionStatus:%ld", (long)exportSession.status];
        [details setValue:message forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:@"VideoEditor" code:400 userInfo:details];
        completionBlock(error);
        NSLog(@"Export finished; status!=Completed; error=\(exportSession.error)");
    }
}

@end
