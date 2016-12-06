//
//  PlayerView.m
//  VideoEditor2
//
//  Created by Alexander on 9/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "PlayerView.h"

@interface PlayerView()

@property (nonatomic, readwrite) BOOL isPlayingNow;

@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (nonatomic) BOOL playerItemObserversSetUp;
@property (strong, nonatomic) NSString* context;

@property (nonatomic) BOOL autoPlay;


@end

@implementation PlayerView

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isPlayingNow = NO;
        self.playerItemObserversSetUp = NO;
        self.context = @"zzz";
        self.autoPlay = NO;
    }
    return self;
}

- (void)dealloc
{
    [self cleanPlayer];
}

- (AVPlayer*)player {
    return ((AVPlayerLayer*)self.layer).player;
}

- (void)setPlayer:(AVPlayer *)player {
    ((AVPlayerLayer*)self.layer).player = player;
}

- (void)updateControls {
    if (self.delegate) {
        [self.delegate playerStateDidChanged:self];
    }
}

- (BOOL)isReadyToPlay {
    return self.player != nil && self.playerItem.status == AVPlayerItemStatusReadyToPlay;
}

- (void)play {
    if (self.isReadyToPlay && !self.isPlayingNow) {
        self.isPlayingNow = YES;
        [self.player play];
    }
    [self updateControls];
}

- (void)pause {
    if (self.isReadyToPlay && self.isPlayingNow) {
        self.isPlayingNow = NO;
        [self.player pause];
    }
    [self updateControls];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem != nil && self.playerItemObserversSetUp ) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.playerItemObserversSetUp = NO;
    }
    
    _playerItem = playerItem;
}

- (void)cleanPlayer
{
    [self pause];
    self.player = nil;
    self.playerItem = nil;
    [self updateControls];
}

- (void)playVideoFromURL: (NSURL*) url autoPlay: (BOOL) autoPlay
{
    AVURLAsset* asset = [AVURLAsset assetWithURL:url];
    [self playVideoFromAsset:asset autoPlay: autoPlay];
}

- (void)playVideoFromAsset: (AVAsset*) asset autoPlay: (BOOL) autoPlay
{
    [self playVideoFromAsset:asset videoComposition:nil audioMix:nil autoPlay:autoPlay];
}

- (void)playVideoFromAsset: (AVAsset*) asset videoComposition: (AVVideoComposition*) videoComposition audioMix: (AVAudioMix*) audioMix autoPlay: (BOOL) autoPlay
{
    [self cleanPlayer];
    
    self.autoPlay = autoPlay;
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks", @"duration"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
            
            if (status == AVKeyValueStatusLoaded) {
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                self.playerItem.videoComposition = videoComposition;
                self.playerItem.audioMix = audioMix;
                
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

- (void)didPlayToEnd
{
    self.isPlayingNow = NO;
    [self.player seekToTime: kCMTimeZero];
    [self updateControls];
}



@end
