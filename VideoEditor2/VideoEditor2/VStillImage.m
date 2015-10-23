//
//  VStillImage.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VStillImage.h"

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
