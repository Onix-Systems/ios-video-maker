//
//  PlayerView.h
//  VideoEditor2
//
//  Created by Alexander on 9/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "VRenderingStats.h"

@class PlayerView;

@protocol PlayerViewDelegate <NSObject>

-(void) playerStateDidChanged: (PlayerView*) playerView;

@optional
-(void) playerTimeDidChanged: (PlayerView*) playerView;

-(void) playerUpdatedDuration: (PlayerView*) playerView;

@end

@interface PlayerView : UIView

@property (nonatomic,readonly) BOOL isReadyToPlay;
@property (nonatomic,readonly) BOOL isPlayingNow;

@property (weak,nonatomic) AVPlayer *player;
@property (nonatomic) CMTime playerTime;

@property (nonatomic) NSInteger autoRewind;

@property (weak, nonatomic) id<PlayerViewDelegate> delegate;

@property (strong, nonatomic) id<VRenderingStats> renderingStats;

-(void) playVideoFromURL: (NSURL*) url autoPlay: (BOOL) autoPlay;
-(void) playVideoFromAsset: (AVAsset*) asset autoPlay: (BOOL) autoPlay;
-(void) playVideoFromAsset: (AVAsset*) asset videoComposition: (AVVideoComposition*) videoComposition audioMix: (AVAudioMix*) audioMix autoPlay: (BOOL) autoPlay;
-(void) cleanPlayer;

-(void) play;
-(void) pause;
- (CMTime)maxDuration;
@end
