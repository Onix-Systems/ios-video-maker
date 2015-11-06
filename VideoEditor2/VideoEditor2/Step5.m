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

@interface Step5 () <PlayerViewDelegate>

@property (weak, nonatomic) IBOutlet PlayerView *playerView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;

@property (weak, nonatomic) VSegmentsCollection* segmentsCollection;
@property (weak, nonatomic) IBOutlet SegmentsCollectionView *segmentsCollectionView;

@property (strong, nonatomic) AVAsset* currentDebugViewAsset;

@property (strong, nonatomic) VideoComposition* videoComposition;

@end

@implementation Step5

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playButton.enabled = NO;
    self.pauseButton.enabled = YES;
    
    self.playerView.delegate = self;
    
    self.videoComposition = [[VDocument getCurrentDocument].segmentsCollection makeVideoCompositionWithFrameSize:CGSizeMake(1280, 720)];
    
    [self.playerView playVideoFromAsset:self.videoComposition.mutableComposition videoComposition:self.videoComposition.mutableVideoComposition audioMix:self.videoComposition.mutableAudioMix autoPlay:NO];
    
    self.segmentsCollection = [VDocument getCurrentDocument].segmentsCollection;
    self.segmentsCollectionView.segmentsCollection = self.segmentsCollection;
    
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

@end
