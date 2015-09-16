//
//  ImageSelectorPlayerView.m
//  VideoEditor2
//
//  Created by Alexander on 9/10/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorPlayerView.h"

@interface ImageSelectorPlayerView ()

@property (nonatomic) BOOL isPlayingNow;

@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (nonatomic) BOOL playerItemObserversSetUp;
@property (strong, nonatomic) NSString* context;

@property (weak,nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic) BOOL autoPlay;

@end

@implementation ImageSelectorPlayerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isPlayingNow = false;
        self.playerItemObserversSetUp = NO;
        //self.alpha = .5;
        self.context = @"zzz";
        self.autoPlay = NO;
    }
    return self;
}

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

- (void) setHidden:(BOOL)hidden {
    [self cleanPlayer];
    
    [super setHidden:hidden];
}

-(void) updateControls {
    if (self.playerItem != nil && self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        self.playButton.enabled = YES;
        if (self.isPlayingNow) {
            [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        } else {
            [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        //        self.playButton.enabled = NO;
    }
}

-(void)play {
    if (self.player != nil && self.playerItem.status == AVPlayerItemStatusReadyToPlay && !self.isPlayingNow) {
        self.isPlayingNow = YES;
        [self.player play];
    }
    [self updateControls];
}

-(void)pause {
    if (self.player != nil && self.playerItem.status == AVPlayerItemStatusReadyToPlay && self.isPlayingNow) {
        self.isPlayingNow = NO;
        [self.player pause];
    }
    [self updateControls];
}

- (IBAction)playButtonAction:(id)sender {
    if (self.isPlayingNow) {
        [self pause];
    } else {
        [self play];
    }
}

-(AVPlayer*) player {
    return ((AVPlayerLayer*)self.layer).player;
}

-(void)setPlayer:(AVPlayer *)player {
    ((AVPlayerLayer*)self.layer).player = player;
}

-(void) setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem != nil && self.playerItemObserversSetUp ) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.playerItemObserversSetUp = NO;
    }
    
    _playerItem = playerItem;
}

- (void) cleanPlayer {
    [self pause];
    self.player = nil;
    self.playerItem = nil;
    [self updateControls];
}

- (void)dealloc
{
    [self cleanPlayer];
}

-(void) playVideoFromURL: (NSURL*) url autoPlay: (BOOL) autoPlay
{
    AVURLAsset* asset = [AVURLAsset assetWithURL:url];
    [self playVideoFromAsset:asset autoPlay: autoPlay];
}

-(void) playVideoFromAsset: (AVAsset*) asset autoPlay: (BOOL) autoPlay
{
    [self cleanPlayer];
    
    self.autoPlay = autoPlay;
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks", @"duration"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
            
            if (status == AVKeyValueStatusLoaded) {
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                
                [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:(void*)self.context];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
                
                self.playerItemObserversSetUp = YES;
                
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
            };
        });
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"] && self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            if (self.autoPlay) {
                [self play];
            } else {
                [self pause];
            }
        }
    }
}

- (void) didPlayToEnd {
    self.isPlayingNow = NO;
    [self.player seekToTime: kCMTimeZero];
    [self updateControls];
}

@end
