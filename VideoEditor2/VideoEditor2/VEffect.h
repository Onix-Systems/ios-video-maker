//
//  VEffect.h
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <CoreMedia/CoreMedia.h>

@interface VEffect : NSObject

@property (nonatomic) CGSize originalSize;

-(NSDictionary*) getAttributes;
-(void) setupParameterAttributes: (NSString*) paramName defaultValue: (NSObject*) defaultValue;
-(NSObject*) getParamValue: (NSString*) paramName;
-(NSDictionary*) getParameters;

-(CIImage*) getImageForFrameSize: (CGSize) frameSize atTime: (double) time;

-(NSInteger) getNumberOfInputFrames;
-(VEffect*) getInputFrameProvider: (NSInteger) inputFrameNumber;
-(void) setInputFrameProvider: (VEffect*) provider forInputFrameNum: (NSInteger) inputFrameNumber;

@end
