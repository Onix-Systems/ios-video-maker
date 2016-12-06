//
//  CIImage+Convenience.h
//  VideoEditor2
//
//  Created by Alexander on 11/16/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

#define useGPUrendering NO

@interface CIImage (Convenience)

-(CIImage*) vCrop: (CGRect)rect;
-(CIImage*) vScale: (CGFloat)scale;
-(CIImage*) vShiftX: (CGFloat)x shiftY: (CGFloat)y;
-(CIImage*) vComposeOverBackground: (CIImage*) background;


-(CIImage*) renderRectForChaching:(CGRect)rect;

@end
