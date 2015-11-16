//
//  CIImage+Convenience.h
//  VideoEditor2
//
//  Created by Alexander on 11/16/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface CIImage (Convenience)

-(CIImage*) vCrop: (CGRect)rect;
-(CIImage*) vScaleX: (CGFloat)x scaleY: (CGFloat)y;
-(CIImage*) vShiftX: (CGFloat)x shiftY: (CGFloat)y;
-(CIImage*) vComposeOverBackground: (CIImage*) background;

@end
