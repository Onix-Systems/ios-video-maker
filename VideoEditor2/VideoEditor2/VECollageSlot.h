//
//  VECollageSlot.h
//  VideoEditor2
//
//  Created by Alexander on 10/9/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import "VEffect.h"

#include "TimeLine.h"

@interface VECollageSlot : NSObject

@property (nonatomic) CGRect frame;

@property (nonatomic) double scale;

@property (nonatomic) double xShift;
@property (nonatomic) double yShift;

@property (nonatomic) double startTime;
@property (nonatomic) double endTime;
@property (nonatomic, strong) TimeLine* timeLine;

-(void) setupForFinalSize: (CGRect)frame andOriginalSize: (CGSize) originalSize;

-(CIImage*) getTranstaledImageFromFrameProvider: (VEffect*) frameProvider atTime: (double) time;

-(CIImage*) makeSlotImageFromFrameProvider:(VEffect*)frameProvider atTime:(double)time;

@end
