//
//  ImageSelectPlayerView.h
//  VideoEditor2
//
//  Created by Alexander on 8/28/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import  <AVFoundation/AVFoundation.h>

@interface ImageSelectPlayerView : UIView

@property (weak,nonatomic) AVPlayer *player;

-(void) playVideoFromURL: (NSURL*) url;
-(void) playVideoFromAsset: (AVAsset*) asset;
-(void) cleanPlayer;

@end
