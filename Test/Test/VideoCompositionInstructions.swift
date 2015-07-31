//
//  VideoCompositionLayerInstructions.swift
//  Test
//
//  Created by Alexander on 30.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation
import AVFoundation
import CoreGraphics
import UIKit

class StillImageInstuction : NSObject, AVVideoCompositionInstructionProtocol {
    var image : CGImageRef?
    
    var debugImageView : UIImageView?
    
    @objc var timeRange: CMTimeRange
    
    @objc var enablePostProcessing: Bool = true
    
    @objc var containsTweening: Bool = false
    
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

class PassthroughImageInstuction : NSObject, AVVideoCompositionInstructionProtocol {
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