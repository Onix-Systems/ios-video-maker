//
//  VideoCompositor.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VideoCompositor.h"
#import "VCompositionInstruction.h"

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
        self.myEAGLContext = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
        
        self.ciContext = [CIContext contextWithEAGLContext:self.myEAGLContext options: nil];
        
        NSMutableArray* renderingQueue = [NSMutableArray new];
        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue1", DISPATCH_QUEUE_SERIAL)];
        [renderingQueue addObject: dispatch_queue_create("CustomVideoCompositorRenderingQueue2", DISPATCH_QUEUE_SERIAL)];
        
        self.renderingQueue = renderingQueue;
    }
    return self;
}

-(NSDictionary*) sourcePixelBufferAttributes
{
    return @{
             (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32ARGB],
            (id)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool: YES]
            };
}

-(NSDictionary*) requiredPixelBufferAttributesForRenderContext
{
    return @{
            (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32ARGB],
            (id) kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool: YES]
            };
}

-(void) renderContextChanged: (AVVideoCompositionRenderContext*) newRenderContext
{
    self.renderContext = newRenderContext;
}

-(void) startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)asyncVideoCompositionRequest
{
    self.requestNumber++;
    dispatch_async(self.renderingQueue[(self.requestNumber % 2)], ^{
        [self processRequest: asyncVideoCompositionRequest];
    });
}

-(void) processRequest: (AVAsynchronousVideoCompositionRequest*) request
{
    if ([request.videoCompositionInstruction class] == [VCompositionInstruction class]) {
        VCompositionInstruction* instruction = (VCompositionInstruction*)request.videoCompositionInstruction;
        
        [instruction processRequest: request usingCIContext:self.ciContext];
    }
    
}//    var imageInstruction = request.videoCompositionInstruction as? StillImageInstuction
//    var passthroughInstruction = request.videoCompositionInstruction as? PassthroughInstuction
//    var transitionInstruction = request.videoCompositionInstruction as? TransitionInstuction
//    
//    if (imageInstruction != nil) {
//        let unmanagedBuffer : Unmanaged<CVImageBuffer> = request.renderContext.newPixelBuffer()
//        let buffer : CVPixelBuffer = unmanagedBuffer.takeRetainedValue()
//        let image : CIImage = CIImage(CGImage: imageInstruction!.image)
//        let bufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
//        var transformValue = NSValue(CGAffineTransform: VideoCompositor.getAspectFitTransform(image: image, desiredSize: bufferSize))
//        
//        let filter = CIFilter(name: "CIAffineTransform")
//        filter.setDefaults()
//        filter.setValue(image, forKey: kCIInputImageKey)
//        filter.setValue(transformValue, forKey: "inputTransform")
//        
//        var resultImage : CIImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
//        
//        ciContext.render(resultImage, toCVPixelBuffer: buffer)
//        
//        request.finishWithComposedVideoFrame(buffer)
//        //unmanagedBuffer.release()
//        
//    } else if (transitionInstruction != nil) {
//        let unmanagedBuffer : Unmanaged<CVImageBuffer> = request.renderContext.newPixelBuffer()
//        let buffer : CVPixelBuffer = unmanagedBuffer.takeRetainedValue()
//        let bufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
//        
//        let filter = CIFilter(name: "CIAffineTransform")
//        
//        var fromImage : CIImage = transitionInstruction!.getPreviousImage(request: request)
//        var transformValue = NSValue(CGAffineTransform: VideoCompositor.getAspectFitTransform(image: fromImage, desiredSize: bufferSize))
//        filter.setDefaults()
//        filter.setValue(fromImage, forKey: kCIInputImageKey)
//        filter.setValue(transformValue, forKey: "inputTransform")
//        fromImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
//        
//        var toImage : CIImage = transitionInstruction!.getCurrentImage(request: request)
//        transformValue = NSValue(CGAffineTransform: VideoCompositor.getAspectFitTransform(image: toImage, desiredSize: bufferSize))
//        filter.setDefaults()
//        filter.setValue(toImage, forKey: kCIInputImageKey)
//        filter.setValue(transformValue, forKey: "inputTransform")
//        toImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
//        
//        let timeRange = transitionInstruction!.timeRange
//        let inputTime : Double = (CMTimeGetSeconds(request.compositionTime) - CMTimeGetSeconds(timeRange.start)) / CMTimeGetSeconds(timeRange.duration)
//        
//        let resultImage = transitionInstruction?.transitionFilter.getTransitionFromImage(fromImage, toImage: toImage, inputTime: inputTime)
//        
//        ciContext.render(resultImage, toCVPixelBuffer: buffer)
//        
//        request.finishWithComposedVideoFrame(buffer)
//        
//    } else {
//        let sourceTrackIDs = request.sourceTrackIDs
//        let sourceTrackID = sourceTrackIDs[0] as? NSNumber
//        
//        let unmanagedSourceBuffer = request.sourceFrameByTrackID(sourceTrackID!.intValue)
//        let buffer : CVPixelBuffer = unmanagedSourceBuffer.takeRetainedValue()
//        
//        request.finishWithComposedVideoFrame(buffer)
//    }


@end
