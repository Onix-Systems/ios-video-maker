//
//  VCoreVideoPBImage.h
//  VideoEditor2
//
//  Created by Alexander on 10/17/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VFrameProvider.h"

@interface VCoreVideoFrameProvider : VFrameProvider

@property (nonatomic) double videoDuration;
@property (nonatomic) CGSize videoSize;
@property (nonatomic, strong) AVAsset* asset;
@property (nonatomic) CMPersistentTrackID registeredTrackID;
@property (nonatomic) NSInteger activeTrackNo;

@end
