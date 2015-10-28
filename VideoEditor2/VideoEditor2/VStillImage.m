//
//  VStillImage.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VStillImage.h"

#define kVStillImageDuration 2.0

@implementation VStillImage

-(CGSize) getOriginalSize
{
    return self.imageSize;
}

-(double) getDuration
{
    return kVStillImageDuration;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    return self.image;
}

@end
