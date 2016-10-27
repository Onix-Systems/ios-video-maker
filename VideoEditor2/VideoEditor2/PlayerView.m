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

@property (nonatomic, weak) id timeObserverObj;

@property (nonatomic) BOOL shouldStartPlayingWhenAppActive;
@property (nonatomic) BOOL isSuspended;

@property (nonatomic, strong) UILabel* renderingStatsLabel;

@end

#define kPlayerViewApplicationWillResignActive @"kPlayerViewApplicationWillResignActive"
#define kPlayerViewApplicationDidBecomeActive @"kPlayerViewApplicationDidBecomeActive"

@implementation PlayerView

+ (Class)layerClass
{
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
        self.autoRewind = 0;
        self.shouldStartPlayingWhenAppActive = NO;
        _renderingStats = nil;
        self.renderingStatsLabel = nil;
    }
    return self;
}

- (void)dealloc
{
    [self cleanPlayer];
}


-(void) subscribeToAppNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void) unsubscribeToAppNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void) applicationWillResignActive: (NSNotification*) notification
{
    if (self.isPlayingNow) {
        self.shouldStartPlayingWhenAppActive = YES;
        [self pause];
    } else {
        self.shouldStartPlayingWhenAppActive = NO;
    }
}

-(void) applicationDidBecomeActive: (NSNotification*) notification
{
    if (self.shouldStartPlayingWhenAppActive) {
        [self play];
    }
}

- (AVPlayer*)player
{
    return ((AVPlayerLayer*)self.layer).player;
}

- (void)setPlayer:(AVPlayer *)player {
    AVPlayer* prevPlayer = ((AVPlayerLayer*)self.layer).player;
    
    if ((prevPlayer != nil) && (self.timeObserverObj != nil)) {
        [prevPlayer removeTimeObserver:self.timeObserverObj];
        self.timeObserverObj = nil;
    }
    
//    ((AVPlayerLayer*)self.layer).videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    ((AVPlayerLayer*)self.layer).player = player;
}

- (void)updateControls
{
    if (self.delegate) {
        [self.delegate playerStateDidChanged:self];
    }
}

- (BOOL)isReadyToPlay
{
    return (self.player != nil) && (self.playerItem != nil) && (self.playerItem.status == AVPlayerItemStatusReadyToPlay);
}

- (CMTime)maxDuration {
    return self.playerItem.duration;
}

- (void)play
{
    if (self.isReadyToPlay && !self.isPlayingNow) {
        self.isPlayingNow = YES;
        self.isSuspended = NO;
        [self.player play];
        [self updateControls];
    }
}

- (void)pause
{
    self.isSuspended = YES;
    [self pauseAndUpdateControls:YES];
}

-(void)pauseAndUpdateControls: (BOOL)updateControls
{
    if (self.isPlayingNow) {
        self.isPlayingNow = NO;
        
        [self.player pause];
        if (updateControls) {
            [self updateControls];
        }
    }
}

-(void)setRenderingStats:(id<VRenderingStats>)renderingStats
{
    _renderingStats = renderingStats;
    
    if (self.renderingStats != nil) {
        if (self.renderingStatsLabel == nil) {
            self.renderingStatsLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 300, 20)];
            self.renderingStatsLabel.font = [UIFont systemFontOfSize:10.0];
            self.renderingStatsLabel.textAlignment = NSTextAlignmentLeft;
            self.renderingStatsLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.renderingStatsLabel];
        }
    } else {
        if (self.renderingStatsLabel != nil) {
            [self.renderingStatsLabel removeFromSuperview];
            self.renderingStatsLabel = nil;
        }
    }
}

-(void)updateRenderingStats
{
    if (self.renderingStatsLabel != nil && self.renderingStats != nil) {
        self.renderingStatsLabel.text = [NSString stringWithFormat:@"min=%.2f av=%.2f max=%.2f", [self.renderingStats getMinDuration], [self.renderingStats getAverageDuration], [self.renderingStats getMaxDuration]];
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem != nil && self.playerItemObserversSetUp ) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.playerItemObserversSetUp = NO;
    }
    
    _playerItem = playerItem;
}

- (void)cleanPlayer
{
    [self pauseAndUpdateControls:NO];
    
    [self unsubscribeToAppNotifications];
    
    self.player = nil;
    self.playerItem = nil;
    self.playerTime = CMTimeMake(0, 1000);
    
    self.renderingStats = nil;
    [self.player seekToTime: kCMTimeZero];
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
    [self subscribeToAppNotifications];
    
    self.autoPlay = autoPlay;
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks", @"duration"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
            
            if (status == AVKeyValueStatusLoaded) {
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                if ([self.delegate respondsToSelector:@selector(playerUpdatedDuration:)]) {
                    [self.delegate playerUpdatedDuration:self];
                }
                
                self.playerItem.videoComposition = videoComposition;
                self.playerItem.audioMix = audioMix;
                
                [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:(void*)self.context];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
                
                
                self.playerItemObserversSetUp = YES;
                
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
            
                self.timeObserverObj = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:nil usingBlock:^(CMTime time) {
                    self.playerTime = time;
                    [self updateRenderingStats];
                    [self.delegate playerTimeDidChanged:self];
                }];
            };
        });
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"] && self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            if (self.autoPlay) {
                self.autoPlay = NO;
                [self play];
            } else {
                [self updateControls];
            }
        }
    }
}

- (void)didPlayToEnd
{
    self.isPlayingNow = NO;
    [self.player seekToTime: kCMTimeZero];
    if ((self.autoRewind > 0) && !self.isSuspended) {
        self.autoRewind--;
        [self play];
    } else {
        [self updateControls];
    }
}

@end
