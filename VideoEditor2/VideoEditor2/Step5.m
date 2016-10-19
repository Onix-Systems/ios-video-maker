//
//  Step5.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "Step5.h"

#import "PlayerView.h"
#import "VDocument.h"
#import "APLCompositionDebugView.h"
#import "SegmentsCollectionView.h"
#import "VEButton.h"
#import "Step3.h"
#import "NSStringHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

@interface Step5 () <PlayerViewDelegate, SegmentsCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *createFilmView;
@property (weak, nonatomic) IBOutlet UIButton *createFilmButton;
@property (weak, nonatomic) IBOutlet UIImageView *createFilmImage;
@property (weak, nonatomic) IBOutlet PlayerView *playerView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet VEButton *deleteButton;

@property (weak, nonatomic) VSegmentsCollection* segmentsCollection;
@property (weak, nonatomic) IBOutlet SegmentsCollectionView *segmentsCollectionView;

@property (strong, nonatomic) AVAsset* currentDebugViewAsset;

@property (strong, nonatomic) VideoComposition* videoComposition;

@property (nonatomic) BOOL isVideoSuspended;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;
@end

@implementation Step5

-(void)viewDidLoad {
    [super viewDidLoad];
    self.createFilmButton.layer.cornerRadius = 4;
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playButton.enabled = NO;
    
    self.playerView.delegate = self;
    
    self.segmentsCollectionView.delegate = self;
    
    self.isVideoSuspended = NO;
    
    [self.deleteButton setEnabledWithAplha:NO];
    
    [self configureView];
}

-(void)configureView {
    [[VDocument getCurrentDocument] updateAssetsCollection];
    self.videoComposition = [[VDocument getCurrentDocument].segmentsCollection makeVideoCompositionWithFrameSize:CGSizeMake(1280, 720)];
    
    [self.playerView playVideoFromAsset:self.videoComposition.mutableComposition videoComposition:self.videoComposition.mutableVideoComposition audioMix:self.videoComposition.mutableAudioMix autoPlay:NO];
    
    self.segmentsCollection = [VDocument getCurrentDocument].segmentsCollection;
    self.segmentsCollectionView.segmentsCollection = self.segmentsCollection;
    
    if (self.segmentsCollection.segmentsCount && self.segmentsCollection.segmentsCount > 0) {
        self.createFilmView.hidden = YES;
        self.createFilmImage.hidden = YES;
    } else {
        self.createFilmView.hidden = NO;
        self.createFilmImage.hidden = NO;
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.playerView cleanPlayer];
}

- (IBAction)playButtonAction:(id)sender
{
//    if (self.playerView.isPlayingNow) {
//        [self.playerView pause];
//    } else {
//        if (self.playerView.isReadyToPlay) {
//            [self.playerView play];
//        }
//    }
    
    [self.videoComposition exportMovieToFileWithCompletion:^(NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
            [alert show];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];

        }
    }];
//    [self mergeAndSave];
}


- (void)mergeAndSave {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
    
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    NSLog(@"%@",myPathDocs);
    
    VideoComposition *new = [self.segmentsCollection makeVideoCompositionWithFrameSize: CGSizeMake(640, 480)];
//    new.mutableVideoComposition.renderSize = CGSizeMake(320.0, 480.0);
    
//    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    
////    self.videoComposition
////    [self.segmentsCollection getSegment:0]
//    
//    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
//    
//    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd([self.segmentsCollection getSegment:0].asset.downloadedAsset.duration, [self.segmentsCollection getSegment:1].asset.downloadedAsset.duration));
//    
//    //VIDEO TRACK
//    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.segmentsCollection getSegment:0].asset.downloadedAsset.duration) ofTrack:[[[self.segmentsCollection getSegment:0].asset.downloadedAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
//    
//    AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.segmentsCollection getSegment:1].asset.downloadedAsset.duration) ofTrack:[[[self.segmentsCollection getSegment:1].asset.downloadedAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:[self.segmentsCollection getSegment:0].asset.downloadedAsset.duration error:nil];
//    
//    
//    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
//    AVAssetTrack *FirstAssetTrack = [[[self.segmentsCollection getSegment:0].asset.downloadedAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    UIImageOrientation FirstAssetOrientation_  = UIImageOrientationUp;
//    BOOL  isFirstAssetPortrait_  = NO;
//    CGAffineTransform firstTransform = FirstAssetTrack.preferredTransform;
//    if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)  {FirstAssetOrientation_= UIImageOrientationRight; isFirstAssetPortrait_ = YES;}
//    if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)  {FirstAssetOrientation_ =  UIImageOrientationLeft; isFirstAssetPortrait_ = YES;}
//    if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)   {FirstAssetOrientation_ =  UIImageOrientationUp;}
//    if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {FirstAssetOrientation_ = UIImageOrientationDown;}
//    CGFloat FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.width;
//    if(isFirstAssetPortrait_){
//        FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.height;
//        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
//        [FirstlayerInstruction setTransform:CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
//    }else{
//        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
//        [FirstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
//    }
//    [FirstlayerInstruction setOpacity:0.0 atTime:[self.segmentsCollection getSegment:0].asset.downloadedAsset.duration];
//    
//    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
//    AVAssetTrack *SecondAssetTrack = [[[self.segmentsCollection getSegment:1].asset.downloadedAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    UIImageOrientation SecondAssetOrientation_  = UIImageOrientationUp;
//    BOOL  isSecondAssetPortrait_  = NO;
//    CGAffineTransform secondTransform = SecondAssetTrack.preferredTransform;
//    if(secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0)  {SecondAssetOrientation_= UIImageOrientationRight; isSecondAssetPortrait_ = YES;}
//    if(secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0)  {SecondAssetOrientation_ =  UIImageOrientationLeft; isSecondAssetPortrait_ = YES;}
//    if(secondTransform.a == 1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0)   {SecondAssetOrientation_ =  UIImageOrientationUp;}
//    if(secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0) {SecondAssetOrientation_ = UIImageOrientationDown;}
//    CGFloat SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.width;
//    if(isSecondAssetPortrait_){
//        SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.height;
//        CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
//        [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor) atTime:[self.segmentsCollection getSegment:0].asset.downloadedAsset.duration];
//    }else{
//        ;
//        CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
//        [SecondlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:[self.segmentsCollection getSegment:0].asset.downloadedAsset.duration];
//    }
//
//    
//    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
//    
//    CMTimeRange rannn = MainInstruction.timeRange;
//
//    
//    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
//    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
//    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
//    MainCompositionInst.renderSize = CGSizeMake(320.0, 480.0);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:new.mutableComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.videoComposition = new.mutableVideoComposition;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:exporter];
         });
     }];
}

- (void)exportDidFinish:(AVAssetExportSession*)session
{
    if(session.status == AVAssetExportSessionStatusCompleted){
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL
                                        completionBlock:^(NSURL *assetURL, NSError *error){
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (error) {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
                                                    [alert show];
                                                }else{
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                    [alert show];
                                                }
                                                
                                            });
                                            
                                        }];
        }
    }
    
//    audioAsset = nil;
//    firstAsset = nil;
//    secondAsset = nil;
//    [ActivityView stopAnimating];
}




- (IBAction)fastBackButtonAction:(id)sender {
    
}

- (IBAction)backButtonAction:(id)sender {
    [self.playerView.player seekToTime: kCMTimeZero];
}

- (IBAction)fastForwardButtonAction:(id)sender {
}

- (IBAction)forwardButtonAction:(id)sender {
    [self.playerView.player seekToTime: [self.playerView maxDuration]];
}

- (IBAction)deleteButtonAction:(id)sender {
    [[VDocument getCurrentDocument].assetsCollection removeAsset:[self.segmentsCollectionView getSelectedSegment]];
    [self.segmentsCollectionView endEditing:YES];
    [self configureView];
}

- (IBAction)addButtonAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    Step3 *vc = [storyboard instantiateViewControllerWithIdentifier:@"Step3"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) playerStateDidChanged: (PlayerView*) playerView
{
    if (self.playerView.isReadyToPlay) {
        self.playButton.enabled = YES;
        if (self.currentDebugViewAsset != self.videoComposition.mutableComposition) {
            self.currentDebugViewAsset = self.videoComposition.mutableComposition;
        }

        if (self.playerView.isPlayingNow) {
            [self.playButton setImage:[UIImage imageNamed:@"Pause-1"] forState:UIControlStateNormal];
        } else {
            [self.playButton setImage:[UIImage imageNamed:@"Play-1"] forState:UIControlStateNormal];
        }
    } else {
        self.playButton.enabled = NO;
    }
}

-(void) playerTimeDidChanged:(PlayerView *)playerView
{
    [self updateTimeLabel:playerView.playerTime maxDuration:[playerView maxDuration]];
    [self.segmentsCollectionView synchronizeToPlayerTime:CMTimeGetSeconds(playerView.playerTime)];
}

- (void)playerUpdatedDuration:(PlayerView *)playerView {
    [self updateTimeLabel:playerView.playerTime maxDuration:[playerView maxDuration]];
}

-(void)updateTimeLabel:(CMTime)currentTime maxDuration:(CMTime)duration {
    NSString *currentStr = [NSStringHelper stringFromTimeInterval:CMTimeGetSeconds(currentTime)];
    NSString *durationStr = [NSStringHelper stringFromTimeInterval:CMTimeGetSeconds(duration)];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", currentStr, durationStr];
}

#pragma SegmentsCollectionViewDelegate
-(void) willStartScrolling
{
    if (self.playerView.isPlayingNow) {
        self.isVideoSuspended = YES;
        [self.playerView pause];
    }
}

-(void) didScrollToTime:(double)time
{
    [self.playerView.player seekToTime:CMTimeMakeWithSeconds(time, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)didFinishScrolling
{
    if (self.isVideoSuspended) {
        self.isVideoSuspended = NO;
        [self.playerView play];
    }
}

- (void)assetSelected:(VAsset *)asset {
    [self.deleteButton setEnabledWithAplha:YES];
}

- (void)assetDeselected:(VAsset *)asset {
    [self.deleteButton setEnabledWithAplha:NO];
}

- (void)panGestureAction:(UITapGestureRecognizer *)sender {
    [self.segmentsCollectionView deselectSelectedSegmentView];
}

@end
