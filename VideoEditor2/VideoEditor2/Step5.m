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

@interface Step5 () <PlayerViewDelegate, SegmentsCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *createFilmView;
@property (weak, nonatomic) IBOutlet UIButton *createFilmButton;
@property (weak, nonatomic) IBOutlet UIImageView *createFilmImage;
@property (weak, nonatomic) IBOutlet PlayerView *playerView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@property (weak, nonatomic) VSegmentsCollection* segmentsCollection;
@property (weak, nonatomic) IBOutlet SegmentsCollectionView *segmentsCollectionView;

@property (strong, nonatomic) AVAsset* currentDebugViewAsset;

@property (strong, nonatomic) VideoComposition* videoComposition;

@property (nonatomic) BOOL isVideoSuspended;


@end

@implementation Step5

-(void)viewDidLoad {
    [super viewDidLoad];
    self.createFilmButton.layer.cornerRadius = 4;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playButton.enabled = NO;
    self.pauseButton.enabled = YES;
    
    self.playerView.delegate = self;
    
    self.segmentsCollectionView.delegate = self;
    
    self.isVideoSuspended = NO;
    
    self.deleteButton.enabled = NO;
    
    [self configureView];
}

-(void)configureView {
    [[VDocument getCurrentDocument] updateAssetsCollection];
    self.videoComposition = [[VDocument getCurrentDocument].segmentsCollection makeVideoCompositionWithFrameSize:CGSizeMake(1280, 720)];
    
    [self.playerView playVideoFromAsset:self.videoComposition.mutableComposition videoComposition:self.videoComposition.mutableVideoComposition audioMix:self.videoComposition.mutableAudioMix autoPlay:NO];
    
    self.segmentsCollection = [VDocument getCurrentDocument].segmentsCollection;
    self.segmentsCollectionView.segmentsCollection = self.segmentsCollection;
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.playerView cleanPlayer];
}

- (IBAction)playButtonAction:(id)sender
{
    if (self.playerView.isReadyToPlay) {
        [self.playerView play];
    }
}


- (IBAction)pauseButtonAction:(id)sender
{
    if (self.playerView.isPlayingNow) {
        [self.playerView pause];
    }
}

- (IBAction)deleteButtonAction:(id)sender {
    [[VDocument getCurrentDocument].assetsCollection removeAsset:[self.segmentsCollectionView getSelectedSegment]];
    [self configureView];
}

-(void) playerStateDidChanged: (PlayerView*) playerView
{
    if (self.playerView.isReadyToPlay) {
        
        if (self.currentDebugViewAsset != self.videoComposition.mutableComposition) {
            self.currentDebugViewAsset = self.videoComposition.mutableComposition;
        }

        if (self.playerView.isPlayingNow) {
            self.playButton.enabled = NO;
            self.pauseButton.enabled = YES;
        } else {
            self.playButton.enabled = YES;
            self.pauseButton.enabled = NO;
        }
    } else {
        self.playButton.enabled = NO;
        self.pauseButton.enabled = NO;
    }
}

-(void) playerTimeDidChanged:(PlayerView *)playerView
{
    [self.segmentsCollectionView synchronizeToPlayerTime:CMTimeGetSeconds(playerView.playerTime)];
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
    self.deleteButton.enabled = YES;
}
@end
