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
import MobileCoreServices

enum VideoCompositionSegemntType {
    case video, image
}
    
class VideoCompositionSegment {
    static func createSegmentWithPickerInfo(info : [NSObject : AnyObject], onLoad : Void -> Void ) -> VideoCompositionSegment? {
        let mediaType : NSString = info[UIImagePickerControllerMediaType] as! NSString
        
        if (mediaType == kUTTypeImage) {
            let editedImage  = info[UIImagePickerControllerEditedImage] as? UIImage
            if (editedImage != nil) {
                return VideoCompositionImageSegment(image: editedImage!, onLoad: {})
            }
            let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            if (originalImage != nil) {
                return VideoCompositionImageSegment(image: originalImage!, onLoad: {})
            }
        } else if (mediaType == kUTTypeMovie) {
            let videoURL : NSURL = info[UIImagePickerControllerMediaURL] as! NSURL
            
            return VideoCompositionVideoSegment(assetURL: videoURL, onLoad : onLoad)
        }
        
        return nil
    }
    
    var duration : CMTime! = kCMTimeZero;

    func segmentType() -> VideoCompositionSegemntType!  {
        return nil
    }

    func getThumbnail(onReady : UIImage -> Void) {
    }

    private(set) var isLoaded = false
    var onLoad : (Void -> Void)? {
        didSet {
            if (self.isLoaded && self.onLoad != nil) {
                self.onLoad!();
            }
        }
    }
    init(onLoad : Void -> Void) {
        self.onLoad = onLoad
    }

}

class VideoCompositionVideoSegment: VideoCompositionSegment {
    let asset : AVURLAsset;
    
    var videoTrack : AVAssetTrack?
    var audioTrack : AVAssetTrack?
    var thumbnailImage : UIImage?
    
    init(assetURL : NSURL, onLoad : Void -> Void) {
        self.asset = AVURLAsset(URL: assetURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        
        super.init(onLoad: onLoad);
        
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
                
                self.onLoad?()
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
                let thumbnailTime = kCMTimeZero

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
    
    init(image : UIImage, onLoad : Void -> Void) {
        self.image = image
        
        super.init(onLoad: onLoad);
        
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