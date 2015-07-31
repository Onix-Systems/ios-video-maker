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
    
    static func getAspectFitTransform(#image: CIImage, desiredSize: CGSize) -> CGAffineTransform {
        let imageRect = image.extent()
        
        let yScale = imageRect.height / desiredSize.height
        let xScale = imageRect.width / desiredSize.width
        let scale = 1 / (xScale > yScale ? xScale : yScale)
        
        let scaleTransform = CGAffineTransformMakeScale(scale, scale)
        
        let xShift = (desiredSize.width - (imageRect.width * scale)) / 2
        let yShift = (desiredSize.height - (imageRect.height * scale)) / 2
        let translationTransform = CGAffineTransformMakeTranslation(xShift, yShift)
        
        return CGAffineTransformConcat(scaleTransform, translationTransform)
    }
    
    var sourcePixelBufferAttributes: [NSObject : AnyObject]! {
        get {
            return [
                kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                kCVPixelBufferOpenGLESCompatibilityKey : NSNumber(bool: true)
            ];
        }
    }
    
    var requiredPixelBufferAttributesForRenderContext: [NSObject : AnyObject]! {
        get {
            return [
                kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                kCVPixelBufferOpenGLESCompatibilityKey : NSNumber(bool: true)
            ];
        }
    }
    
    var renderContext : AVVideoCompositionRenderContext?
    func renderContextChanged(newRenderContext: AVVideoCompositionRenderContext!) {
        self.renderContext = newRenderContext
    }
    
    func startVideoCompositionRequest(request: AVAsynchronousVideoCompositionRequest!) {
        var imageInstruction : StillImageInstuction? = request.videoCompositionInstruction as? StillImageInstuction
        
        var passthroughInstruction : PassthroughImageInstuction? = request.videoCompositionInstruction as? PassthroughImageInstuction
        
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
            
            if (imageInstruction!.debugImageView != nil) {
                dispatch_async(dispatch_get_main_queue()) {
                    var bufferImage = CIImage(CVPixelBuffer: buffer)
                    if (bufferImage != nil) {
                        imageInstruction!.debugImageView!.image = UIImage(CIImage: bufferImage)
                    } else {
                        imageInstruction!.debugImageView!.image = UIImage(CIImage: resultImage)
                    }
                }
            }

            request.finishWithComposedVideoFrame(buffer)
            //unmanagedBuffer.release()
            
        } else {
            let sourceTrackIDs = request.sourceTrackIDs
            let sourceTrackID = sourceTrackIDs[0] as? NSNumber
            
            let unmanagedSourceBuffer = request.sourceFrameByTrackID(sourceTrackID!.intValue)
            let buffer : CVPixelBuffer = unmanagedSourceBuffer.takeRetainedValue()
            
            request.finishWithComposedVideoFrame(buffer)
        }
    }
    
    
    var ciContext : CIContext
    override init() {
//        ciContext = CIContext();
        
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        var options = [kCIContextWorkingColorSpace : NSNull()]
        self.ciContext = CIContext(EAGLContext: myEAGLContext, options: options)

        super.init()
    }
}