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
    if (self.playerView.isPlayingNow) {
        [self.playerView pause];
    } else {
        if (self.playerView.isReadyToPlay) {
            [self.playerView play];
        }
    }
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
    self.deleteButton.enabled = YES;
}
@end
