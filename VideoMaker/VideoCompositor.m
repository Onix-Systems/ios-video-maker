//
//  VideoCompositor.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VideoCompositor.h"
#import "VCompositionInstruction.h"
#import <CoreImage/CoreImage.h>
#import "VFrameProvider.h"

@interface VideoCompositor ()

@property (strong) AVVideoCompositionRenderContext* renderContext;
@property (strong, nonatomic) CIContext* ciContext;
@property (strong, nonatomic) EAGLContext* myEAGLContext;
@property (strong, nonatomic) NSArray* renderingQueue;
@property NSInteger requestNumber;

@end

@implementation VideoCompositor

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if (useGPUrendering) {
            self.myEAGLContext = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
            
            NSDictionary *options = @{
                                      kCIContextOutputColorSpace : [NSNull null],
                                      kCIContextWorkingColorSpace : [NSNull null],
                                      kCIContextUseSoftwareRenderer : @(NO)
                                      };
            
            self.ciContext = [CIContext contextWithEAGLContext:self.myEAGLContext options: options];
            
        } else {
            NSDictionary *options = @{
                                      kCIContextOutputColorSpace : [NSNull null],
                                      kCIContextWorkingColorSpace : [NSNull null],
                                      kCIContextUseSoftwareRenderer : @(YES)
                                      };
            
            self.ciContext = [CIContext contextWithOptions:options];
        }
        
        NSMutableArray* renderingQueue = [NSMutableArray new];
        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue1", DISPATCH_QUEUE_SERIAL)];
        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue2", DISPATCH_QUEUE_SERIAL)];
        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue3", DISPATCH_QUEUE_SERIAL)];
        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue4", DISPATCH_QUEUE_SERIAL)];
//        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue5", DISPATCH_QUEUE_SERIAL)];
//        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue6", DISPATCH_QUEUE_SERIAL)];
//        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue7", DISPATCH_QUEUE_SERIAL)];
//        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue8", DISPATCH_QUEUE_SERIAL)];
        
        self.renderingQueue = renderingQueue;
    }
    return self;
}

-(NSDictionary*) sourcePixelBufferAttributes
{
    return @{
             (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA],
            (id)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool: useGPUrendering]
            };
}

-(NSDictionary*) requiredPixelBufferAttributesForRenderContext
{
    return @{
            (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA],
            (id) kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool: useGPUrendering]
            };
}

-(void) renderContextChanged: (AVVideoCompositionRenderContext*) newRenderContext
{
    self.renderContext = newRenderContext;
}

-(void) startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)asyncVideoCompositionRequest
{
    self.requestNumber++;
    dispatch_async(self.renderingQueue[self.requestNumber % self.renderingQueue.count], ^{
        [self processRequest: asyncVideoCompositionRequest];
    });
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        [self processRequest: asyncVideoCompositionRequest];
//    });
}

-(void) processRequest: (AVAsynchronousVideoCompositionRequest*) request
{
    VCompositionInstruction* instruction = (VCompositionInstruction*)request.videoCompositionInstruction;
    [instruction processRequest: request usingCIContext:self.ciContext];
}

@end
