//
//  VideoCompositionLayerInstructions.swift
//  Test
//
//  Created by Alexander on 30.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage
import CoreGraphics
import UIKit

class StillImageInstuction : NSObject, AVVideoCompositionInstructionProtocol {
    var image : CGImageRef?
    
    @objc var timeRange: CMTimeRange
    
    @objc var enablePostProcessing: Bool = true
    
    @objc var containsTweening: Bool = true
    
     @objc var requiredSourceTrackIDs: [AnyObject]! {
        get {
            return []
        }
    }
    
    @objc var passthroughTrackID : CMPersistentTrackID {
        get {
            return CMPersistentTrackID(kCMPersistentTrackID_Invalid)
        }
    }
    
    init(image: CGImageRef, timeRange: CMTimeRange) {
        self.image = image
        self.timeRange = timeRange
    }
}

class PassthroughInstuction : NSObject, AVVideoCompositionInstructionProtocol {
    @objc var timeRange: CMTimeRange
    
    @objc var enablePostProcessing: Bool = true
    
    @objc var containsTweening: Bool = true
  
    var sourceTrackID : CMPersistentTrackID
    @objc var requiredSourceTrackIDs: [AnyObject]! {
        get {
            return [NSNumber(int: self.sourceTrackID)]
        }
    }
    
    @objc var passthroughTrackID : CMPersistentTrackID {
        get {
            return sourceTrackID
        }
    }
    
    init(passthroughTrackID : CMPersistentTrackID, timeRange: CMTimeRange) {
        self.sourceTrackID = passthroughTrackID
        self.timeRange = timeRange
    }
}

class TransitionInstuction : NSObject, AVVideoCompositionInstructionProtocol {
    @objc var timeRange: CMTimeRange
    
    @objc var enablePostProcessing: Bool = true
    
    @objc var containsTweening: Bool = true
    
    var sourceTrackIDs = [NSNumber]()
    @objc var requiredSourceTrackIDs: [AnyObject]! {
        get {
            return sourceTrackIDs
        }
    }
    
    @objc var passthroughTrackID : CMPersistentTrackID {
        get {
            return CMPersistentTrackID(kCMPersistentTrackID_Invalid)
        }
    }
    
    var transitionFilter : TransitionFilter
    
    var getCurrentImage : ((request: AVAsynchronousVideoCompositionRequest) -> CIImage)!
    var getPreviousImage : ((request: AVAsynchronousVideoCompositionRequest) -> CIImage)!
    
    init(curentSegment: VideoCompositionSegment, curentTrackID : CMPersistentTrackID, previousSegment: VideoCompositionSegment, previousTrackID: CMPersistentTrackID, timeRange: CMTimeRange) {
        self.timeRange = timeRange
        
        self.transitionFilter = TransitionFilter.makeRundomFilter()
        
        super.init()

        if (curentSegment.segmentType() == VideoCompositionSegemntType.video) {
            self.sourceTrackIDs.append(NSNumber(int: curentTrackID))
            
            self.getCurrentImage = {
                (request: AVAsynchronousVideoCompositionRequest) in
                
                let unmanagedBuffer = request.sourceFrameByTrackID(curentTrackID)
                
                let pixelBuffer : CVPixelBufferRef = unmanagedBuffer.takeUnretainedValue()
                
                let image :CIImage? = CIImage(CVPixelBuffer: pixelBuffer)
                return image!
            }
        } else {
            self.getCurrentImage = {
                (request: AVAsynchronousVideoCompositionRequest) in
                
                return CIImage(image: (curentSegment as! VideoCompositionImageSegment).image)
            }
        }
 
        if (previousSegment.segmentType() == VideoCompositionSegemntType.video) {
            self.sourceTrackIDs.append(NSNumber(int: previousTrackID))
            
            self.getPreviousImage = {
                (request: AVAsynchronousVideoCompositionRequest) in
                
                let unmanagedBuffer = request.sourceFrameByTrackID(previousTrackID)
                
                let pixelBuffer = unmanagedBuffer.takeUnretainedValue()
                
                let image :CIImage? = CIImage(CVPixelBuffer: pixelBuffer)
                return image!
            }
        } else {
            self.getPreviousImage = {
                (request: AVAsynchronousVideoCompositionRequest) in
                
                return CIImage(image: (previousSegment as! VideoCompositionImageSegment).image)
            }
        }

    }
}