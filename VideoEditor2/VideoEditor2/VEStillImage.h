//
//  VEStillImage.h
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VEffect.h"

@interface VEStillImage : VEffect

@property (strong, nonatomic) CIImage* image;

-(void)setPixelBuffer: (CVPixelBufferRef) pixelBuffer;
-(void) releasePixelBuffer;

@end
