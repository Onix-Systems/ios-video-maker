//
//  VideoCompositor.swift
//  Test
//
//  Created by Alexander on 30.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage
import UIKit

class VideoCompositor : NSObject, AVVideoCompositing {
    
    static func getAspectFitTransform(image image: CIImage, desiredSize: CGSize) -> CGAffineTransform {
        let imageRect = image.extent
        
        let yScale = imageRect.height / desiredSize.height
        let xScale = imageRect.width / desiredSize.width
        let scale = 1 / (xScale > yScale ? xScale : yScale)
        
        let scaleTransform = CGAffineTransformMakeScale(scale, scale)
        
        let xShift = (desiredSize.width - (imageRect.width * scale)) / 2
        let yShift = (desiredSize.height - (imageRect.height * scale)) / 2
        let translationTransform = CGAffineTransformMakeTranslation(xShift, yShift)
        
        return CGAffineTransformConcat(scaleTransform, translationTransform)
    }
    
    var sourcePixelBufferAttributes: [String : AnyObject]? {
        get {
            return [
                kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32ARGB,
                kCVPixelBufferOpenGLESCompatibilityKey : NSNumber(bool: true)
            ];
        }
    }
    
    var requiredPixelBufferAttributesForRenderContext: [String : AnyObject] {
        get {
            return [
                kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32ARGB,
                kCVPixelBufferOpenGLESCompatibilityKey : NSNumber(bool: true)
            ];
        }
    }
    
    var renderContext : AVVideoCompositionRenderContext?
    func renderContextChanged(newRenderContext: AVVideoCompositionRenderContext) {
        self.renderContext = newRenderContext
    }
    
    func startVideoCompositionRequest(request: AVAsynchronousVideoCompositionRequest) {
        self.requestNumber++
        dispatch_async(self.renderingQueue[(self.requestNumber % 2)]) {
            self.processRequest(request)
        }
    }
    
    func processRequest(request: AVAsynchronousVideoCompositionRequest!) {
        var imageInstruction = request.videoCompositionInstruction as? StillImageInstuction
        var passthroughInstruction = request.videoCompositionInstruction as? PassthroughInstuction
        var transitionInstruction = request.videoCompositionInstruction as? TransitionInstuction
        
        if (imageInstruction != nil) {
            let unmanagedBuffer : Unmanaged<CVImageBuffer> = request.renderContext.newPixelBuffer()
            let buffer : CVPixelBuffer = unmanagedBuffer.takeRetainedValue()
            let image : CIImage = CIImage(CGImage: imageInstruction!.image)
            let bufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            var transformValue = NSValue(CGAffineTransform: VideoCompositor.getAspectFitTransform(image: image, desiredSize: bufferSize))
            
            let filter = CIFilter(name: "CIAffineTransform")
            filter.setDefaults()
            filter.setValue(image, forKey: kCIInputImageKey)
            filter.setValue(transformValue, forKey: "inputTransform")
            
            var resultImage : CIImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
            
            ciContext.render(resultImage, toCVPixelBuffer: buffer)
            
            request.finishWithComposedVideoFrame(buffer)
            //unmanagedBuffer.release()
            
        } else if (transitionInstruction != nil) {
            let unmanagedBuffer : Unmanaged<CVImageBuffer> = request.renderContext.newPixelBuffer()
            let buffer : CVPixelBuffer = unmanagedBuffer.takeRetainedValue()
            let bufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
 
            let filter = CIFilter(name: "CIAffineTransform")

            var fromImage : CIImage = transitionInstruction!.getPreviousImage(request: request)
            var transformValue = NSValue(CGAffineTransform: VideoCompositor.getAspectFitTransform(image: fromImage, desiredSize: bufferSize))
            filter.setDefaults()
            filter.setValue(fromImage, forKey: kCIInputImageKey)
            filter.setValue(transformValue, forKey: "inputTransform")
            fromImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
          
            var toImage : CIImage = transitionInstruction!.getCurrentImage(request: request)
            transformValue = NSValue(CGAffineTransform: VideoCompositor.getAspectFitTransform(image: toImage, desiredSize: bufferSize))
            filter.setDefaults()
            filter.setValue(toImage, forKey: kCIInputImageKey)
            filter.setValue(transformValue, forKey: "inputTransform")
            toImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
            
            let timeRange = transitionInstruction!.timeRange
            let inputTime : Double = (CMTimeGetSeconds(request.compositionTime) - CMTimeGetSeconds(timeRange.start)) / CMTimeGetSeconds(timeRange.duration)
            
            let resultImage = transitionInstruction?.transitionFilter.getTransitionFromImage(fromImage, toImage: toImage, inputTime: inputTime)
            
            ciContext.render(resultImage, toCVPixelBuffer: buffer)
            
            request.finishWithComposedVideoFrame(buffer)
            
        } else {
            let sourceTrackIDs = request.
            let sourceTrackID = sourceTrackIDs[0] as? NSNumber
            
            let unmanagedSourceBuffer = request.sourceFrameByTrackID(sourceTrackID!.intValue)
            let buffer : CVPixelBuffer = unmanagedSourceBuffer.takeRetainedValue()
            
            request.finishWithComposedVideoFrame(buffer)
        }
    }
    
    
    var ciContext : CIContext
    var renderingQueue = [dispatch_queue_t]()
    var requestNumber : Int = 0
    override init() {
//        ciContext = CIContext();
        
        let myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let options = [kCIContextWorkingColorSpace : NSNull()]
        self.ciContext = CIContext(EAGLContext: myEAGLContext, options: options)

        self.renderingQueue.append(dispatch_queue_create("CustomVideoCompositorRenderingQueue1", DISPATCH_QUEUE_SERIAL))
        self.renderingQueue.append(dispatch_queue_create("CustomVideoCompositorRenderingQueue2", DISPATCH_QUEUE_SERIAL))
        
        super.init()
    }
}