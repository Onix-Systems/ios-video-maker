//
//  ImageSelectPreviewController.m
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorPreviewController.h"
#import "PlayerView.h"
#import "ImageSelectorScrollView.h"

@interface ImageSelectorPreviewController () <PlayerViewDelegate>

@property (weak, nonatomic) IBOutlet PlayerView *playerView;

@property (weak, nonatomic) IBOutlet ImageSelectorScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *gridImageView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *playerControlPanel;

@end

@implementation ImageSelectorPreviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hidePlayerview:YES];
    self.playerView.delegate = self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.playerView cleanPlayer];
}

- (void) hidePlayerview:(BOOL)hidden {
    self.playerView.hidden = hidden;
    self.playerControlPanel.hidden = hidden;
    self.scrollView.hidden = !hidden;
    self.gridImageView.hidden = !hidden;
    [self.playerView cleanPlayer];
}

-(void) playerStateDidChanged:(PlayerView *)playerView {
    if (playerView.isReadyToPlay) {
        self.playButton.enabled = YES;
        if (playerView.isPlayingNow) {
            [self.playButton setImage:[UIImage imageNamed:@"Pause-1"] forState:UIControlStateNormal];
        } else {
            [self.playButton setImage:[UIImage imageNamed:@"Play-1"] forState:UIControlStateNormal];
        }
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"Play-1"] forState:UIControlStateNormal];
        //        self.playButton.enabled = NO;
    }
}

-(void)playerTimeDidChanged:(PlayerView *)playerView
{
    
}

- (IBAction)playButtonAction:(id)sender {
    if (self.playerView.isPlayingNow) {
        [self.playerView pause];
    } else {
        [self.playerView play];
    }
}

-(void) displayAsset: (VAsset*) asset autoPlay: (BOOL) autoPlay
{
    if (asset.isVideo) {
        [self hidePlayerview:NO];
        
        [asset downloadVideoAsset:^(AVAsset *asset, AVAudioMix* audioMix) {
            [self.playerView playVideoFromAsset:asset autoPlay:autoPlay];
        }];
        
    } else {
        [self hidePlayerview:YES];
        
        NSInteger requestTag = ++self.scrollView.tag;
        
        [asset getPreviewImageForSize:self.gridImageView.bounds.size withCompletion:^(UIImage *resultImage, BOOL requestFinished, BOOL requestError) {
            if (!requestError && requestTag == self.scrollView.tag) {
                [self.scrollView displayImage: resultImage];
            }
        }];
    }

}

@end
