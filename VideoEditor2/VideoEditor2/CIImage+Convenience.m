//
//  CIImage+Convenience.m
//  VideoEditor2
//
//  Created by Alexander on 11/16/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "CIImage+Convenience.h"
#import <UIKit/UIKit.h>

#define useFilters NO

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

-(CIImage*) vScale: (CGFloat)scale
{
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    if (useFilters) {
        CIFilter* filter = [CIFilter filterWithName:@"CIAffineTransform"];
        [filter setDefaults];
        [filter setValue:self forKey:@"inputImage"];
        [filter setValue:[NSValue valueWithBytes:&scaleTransform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
        
//        CIFilter* filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
//        [filter setDefaults];
//        [filter setValue:self forKey:@"inputImage"];
//        [filter setValue:[NSNumber numberWithDouble:scale] forKey:@"inputScale"];
        
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

+(CIContext*) getCacheRenderingContext
{
    static CIContext *context = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (useGPUrendering) {
            EAGLContext* myEAGLContext = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
            NSDictionary* options = @{
                                      kCIContextOutputColorSpace : [NSNull null],
                                      kCIContextWorkingColorSpace : [NSNull null],
                                      kCIContextUseSoftwareRenderer : @(NO)
                                      };
            context = [CIContext contextWithEAGLContext:myEAGLContext options: options];
        } else {
            NSDictionary* options = @{
                                      kCIContextOutputColorSpace : [NSNull null],
                                      kCIContextWorkingColorSpace : [NSNull null],
                                      kCIContextUseSoftwareRenderer : @(YES)
                                      };
            context = [CIContext contextWithOptions:options];
        }

        

    });
    
    return context;
    
}

-(CIImage*) renderRectForChaching:(CGRect)rect
{
    NSLog(@"Render for caching");
    
    CIContext *context = [CIImage getCacheRenderingContext];
    
    CGImageRef renderedCGImage =  [context createCGImage:self fromRect:rect];
    CIImage* result = [CIImage imageWithCGImage:renderedCGImage];
    CGImageRelease(renderedCGImage);
    return result;
    
//    UIImage* renderedUIImage = [UIImage imageWithCGImage:renderedCGImage];
//    CIImage* renderedCIImage = [CIImage imageWithData: UIImageJPEGRepresentation(renderedUIImage, 0.9)];
//    
//    return renderedCIImage;
}

@end
