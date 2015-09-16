//
//  ImageSelectorPlayerView.h
//  VideoEditor2
//
//  Created by Alexander on 9/10/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ImageSelectorPlayerView : UIView

@property (weak,nonatomic) AVPlayer *player;

-(void) playVideoFromURL: (NSURL*) url autoPlay: (BOOL) autoPlay;
-(void) playVideoFromAsset: (AVAsset*) asset autoPlay: (BOOL) autoPlay;
-(void) cleanPlayer;

@end
