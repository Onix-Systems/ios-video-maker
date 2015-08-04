//
//  VideoCompositionSegment.swift
//  Test
//
//  Created by Alexander on 27.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum VideoCompositionSegemntType {
    case video, image
}
    
class VideoCompositionSegment {
    var duration : CMTime! = kCMTimeZero;

    func segmentType() -> VideoCompositionSegemntType!  {
        return nil
    }
    
    private(set) var isLoaded = false

    func getThumbnail(onReady : UIImage -> Void) {
    }

}

class VideoCompositionVideoSegment: VideoCompositionSegment {
    let asset : AVURLAsset;
    
    var videoTrack : AVAssetTrack?
    var audioTrack : AVAssetTrack?
    var thumbnailImage : UIImage?
    
    init(assetURL : NSURL, onLoad : Void -> Void) {
        self.asset = AVURLAsset(URL: assetURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        
        super.init();
        
        self.asset.loadValuesAsynchronouslyForKeys(["duration", "tracks"]) {
            var error = NSErrorPointer();
            let durationStatus = self.asset.statusOfValueForKey("duration", error: error)
            if (durationStatus == .Failed) {
                NSLog("Failed to load duration of asset - \(self.asset) with error = \(error)")
                return
            }
            let tracksStatus = self.asset.statusOfValueForKey("tracks", error: error)
            if (tracksStatus == .Failed) {
                NSLog("Failed to load tracks of asset - \(self.asset) with error = \(error)")
                return
            }
            
            if (durationStatus == .Loaded && tracksStatus == .Loaded) {
                
                if (self.asset.tracksWithMediaType(AVMediaTypeVideo).count > 0) {
                    self.videoTrack = self.asset.tracksWithMediaType(AVMediaTypeVideo)[0] as? AVAssetTrack
                }
                
                if (self.asset.tracksWithMediaType(AVMediaTypeAudio).count > 0) {
                    self.audioTrack = self.asset.tracksWithMediaType(AVMediaTypeAudio)[0] as? AVAssetTrack
                }

                self.duration = self.asset.duration
                
                NSLog("Successfully loaded asset \(self.asset)")
                
                self.isLoaded = true
                
                onLoad();
            }
        }
    }
    
    override func segmentType() -> VideoCompositionSegemntType! {
        return .video
    }
    
    override func getThumbnail(onReady: UIImage -> Void) {
        if (self.thumbnailImage != nil) {
            onReady(self.thumbnailImage!)
            return
        }
        if (self.isLoaded) {
            dispatch_async(dispatch_get_main_queue()) {
                let imageGenerator = AVAssetImageGenerator(asset: self.asset)
                
                let durationSeconds = CMTimeGetSeconds(self.asset.duration);
                let thumbnailTime = CMTimeMakeWithSeconds(durationSeconds/10.0, 1000);

                var errorPointer = NSErrorPointer()
                var actualTime = UnsafeMutablePointer<CMTime>()
                
                let thumbnailCGImage : CGImageRef = imageGenerator.copyCGImageAtTime(thumbnailTime, actualTime: actualTime, error: errorPointer)
                self.thumbnailImage = UIImage(CGImage: thumbnailCGImage)

                onReady(self.thumbnailImage!)
            }
        }
    }
    
}

class VideoCompositionImageSegment: VideoCompositionSegment {
    let image : UIImage;
    
    init(image : UIImage) {
        self.image = image
        
        super.init();
        
        self.duration = CMTimeMake(2000, 1000);
        
        self.isLoaded = true
    }
    
    override func segmentType() -> VideoCompositionSegemntType! {
        return .image
    }
    
    override func getThumbnail(onReady: UIImage -> Void) {
        onReady(self.image);
    }
    
}