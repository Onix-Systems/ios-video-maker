//
//  VInstrucionPassthrough.m
//  VideoEditor2
//
//  Created by Alexander on 9/29/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VInstrucionPassthrough.h"

@implementation VInstrucionPassthrough

-(void) processRequest: (AVAsynchronousVideoCompositionRequest*) request usingCIContext: (CIContext*) ciContext
{
    CVPixelBufferRef passthroughFrame = [request sourceFrameByTrackID: self.sourceTrackID];
    CFRetain(passthroughFrame);
    [request finishWithComposedVideoFrame: passthroughFrame];
    CFRelease(passthroughFrame);
}


@end
