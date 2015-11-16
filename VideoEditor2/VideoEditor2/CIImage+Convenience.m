//
//  CIImage+Convenience.m
//  VideoEditor2
//
//  Created by Alexander on 11/16/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "CIImage+Convenience.h"

#define useFilters YES

@implementation CIImage (Convenience)

-(CIImage*) vCrop: (CGRect)rect
{
    if (useFilters) {
        CIFilter* filter = [CIFilter filterWithName:@"CICrop"];
        [filter setDefaults];
        [filter setValue:self forKey:@"inputImage"];
        [filter setValue:[CIVector vectorWithCGRect:rect] forKey:@"inputRectangle"];
        return filter.outputImage;
    } else {
        return [self imageByCroppingToRect:rect];
    }
}

-(CIImage*) vScaleX: (CGFloat)x scaleY: (CGFloat)y
{
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(x, y);
    
    if (useFilters) {
        CIFilter* filter = [CIFilter filterWithName:@"CIAffineTransform"];
        [filter setDefaults];
        [filter setValue:self forKey:@"inputImage"];
        [filter setValue:[NSValue valueWithBytes:&scaleTransform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
        return filter.outputImage;
        

    } else {
        return [self imageByApplyingTransform:scaleTransform];
    }
}

-(CIImage*) vShiftX: (CGFloat)x shiftY: (CGFloat)y
{
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(x, y);
    
    if (useFilters) {
        CIFilter* filter = [CIFilter filterWithName:@"CIAffineTransform"];
        [filter setDefaults];
        [filter setValue:self forKey:@"inputImage"];
        [filter setValue:[NSValue valueWithBytes:&translationTransform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
        return filter.outputImage;
    } else {
        return [self imageByApplyingTransform:translationTransform];
    }
}

-(CIImage*) vComposeOverBackground: (CIImage*) background
{
    if (useFilters) {
        CIFilter* filter = [CIFilter filterWithName:@"CISourceOverCompositing"];
        [filter setDefaults];
        [filter setValue:self forKey:@"inputImage"];
        [filter setValue:background forKey:@"inputBackgroundImage"];
        return filter.outputImage;
    } else {
        return [self imageByCompositingOverImage:background];
    }
}

@end
