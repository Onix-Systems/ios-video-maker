//
//   VideoComposition.swift
//  Test
//
//  Created by Alexander on 27.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices
import UIKit



class VideoComposition: NSObject {
    private var segments = [VideoCompositionSegment]()
    
    var duration : CMTime {
        get {
            var duration = CMTimeMake(0, 1000);
            
            for (var i = 0; i < self.segments.count; i++) {
                duration = CMTimeAdd(duration, self.segments[i].duration);
            }
            
            return duration
        }
    }
    var count : Int {
        get {
            return self.segments.count
        }
    }
    
    func segmentsAreloaded() -> Bool {
        for sergment in self.segments {
            
        }
        return true
    }
    
    func canExport() -> Bool {
        return canPlay()
    }
    
    func canRewind() -> Bool {
        return false
    }
    
    func canPlay() -> Bool {
        if (self.segments.count >= 2) {
            return true
        }
        return false
    }
    
    func canRewinfForward() -> Bool {
        return false
    }
    
    func addSegmentWithPickerInfo(info : [NSObject : AnyObject]) {
        let mediaType : NSString = info[UIImagePickerControllerMediaType] as! NSString
        
        if (mediaType == kUTTypeImage) {
            let image  = info[UIImagePickerControllerEditedImage] as! UIImage
            
            self.add(VideoCompositionImageSegment(image: image))
            
        } else if (mediaType == kUTTypeMovie) {
            let videoURL : NSURL = info[UIImagePickerControllerMediaURL] as! NSURL
            
            self.add(VideoCompositionVideoSegment(assetURL: videoURL))
        }
    }
    
    func add(segment : VideoCompositionSegment) {
        segments.append(segment)
        self.clearCurrentComposition()
    }
    
    func deleteSegmentAtIndex(index : Int) {
        self.segments.removeAtIndex(index)
        self.clearCurrentComposition()
    }
    
    func insert(segment: VideoCompositionSegment, atIndex index : Int) {
        self.segments.insert(segment, atIndex: index)
        self.clearCurrentComposition()
    }
    
    func getSegment(index : Int) -> VideoCompositionSegment {
        return self.segments[index];
    }
    
    var mutableComposition : AVMutableComposition!
    
    var mutableVideoComposition : AVMutableVideoComposition!
    
    func clearCurrentComposition() {
        self.mutableComposition = nil
        self.mutableVideoComposition = nil
    }
    
    func getAsset() -> AVAsset {
        if (self.mutableComposition == nil || self.mutableVideoComposition == nil) {
            self.generateAVComposition()
        }
        
        return self.mutableComposition!
    }
    
    var debugImageView : UIImageView?
    
    var videoTracks : [AVMutableCompositionTrack]!
    var audioTrack : AVMutableCompositionTrack!
    func generateAVComposition() {
        let videoSize = CGSizeMake(720, 480)
        
        self.mutableComposition = AVMutableComposition()
        self.mutableComposition.naturalSize = videoSize
        
        self.videoTracks = []
        
        self.videoTracks.append(self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)))
        self.videoTracks.append(self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)))
        
        //self.audioTrack = self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        let placeholderVideoTrack : AVAssetTrack = self.placeholder.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
        
        self.mutableVideoComposition = AVMutableVideoComposition()
        
        self.mutableVideoComposition.renderSize = videoSize
        self.mutableVideoComposition.frameDuration = CMTimeMake(1,30)
        self.mutableVideoComposition.customVideoCompositorClass = VideoCompositor.self
        
        let transitionDuration = CMTimeMake(300, 1000)
        
        var currentTime = CMTimeMake(0, 1000)
        var instructions = [AnyObject]()
        var errorPointer = NSErrorPointer()
        
        for (var i = 0; i < self.segments.count; i++) {
            let currentVideoTrack = self.videoTracks![i % 2]
            let otherVideoTrack = self.videoTracks![i % 2]
            let segment = self.segments[i]
            
            var segmentTimeRange = CMTimeRange(start: currentTime, duration: segment.duration)
            
            let imageSegment = segment as? VideoCompositionImageSegment
            let videoSegment = segment as? VideoCompositionVideoSegment
            
            if (imageSegment != nil) {
                currentVideoTrack.insertTimeRange(segmentTimeRange, ofTrack: placeholderVideoTrack, atTime: kCMTimeZero, error: errorPointer)
                otherVideoTrack.insertEmptyTimeRange(segmentTimeRange)
                //self.videoTrack.insertEmptyTimeRange(segmentTimeRange)
                //self.audioTrack.insertEmptyTimeRange(segmentTimeRange)
                
                var segmentInstruction = StillImageInstuction(image: imageSegment!.image.CGImage, timeRange: segmentTimeRange)
                segmentInstruction.debugImageView = self.debugImageView
                instructions.append(segmentInstruction)
            }
            
            if (videoSegment != nil) {
                currentVideoTrack.insertTimeRange(segmentTimeRange, ofTrack: videoSegment!.videoTrack, atTime: kCMTimeZero, error: errorPointer)
                otherVideoTrack.insertEmptyTimeRange(segmentTimeRange)
                
//                var segmentInstruction = PassthroughImageInstuction(passthroughTrackID: self.videoTrack.trackID, timeRange: segmentTimeRange)
                
                var segmentInstruction = AVMutableVideoCompositionInstruction()
                var segmentLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: currentVideoTrack)
                segmentInstruction.timeRange = segmentTimeRange
                segmentInstruction.layerInstructions = [segmentLayerInstruction]
                
                instructions.append(segmentInstruction)
            }            
            
            currentTime = CMTimeAdd(currentTime, segment.duration)
        }
        self.mutableVideoComposition.instructions = instructions
        
    }
    
    func exportMovieToFile() {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory : String = paths![0] as! String
        let pathToMovieFile = documentsDirectory.stringByAppendingPathComponent("ExportedMovie.mp4")
        
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(pathToMovieFile, error: nil)
        
        let url = NSURL.fileURLWithPath(pathToMovieFile)
        NSLog("Export movie to URL = \(url)")
        
        let exportSession = AVAssetExportSession(asset: self.getAsset(), presetName: AVAssetExportPresetMediumQuality)
        exportSession.outputURL = url
        exportSession.outputFileType = "public.mpeg-4"
        exportSession.videoComposition = self.mutableVideoComposition
        
        exportSession.exportAsynchronouslyWithCompletionHandler() {
            NSLog("Export finished; status=\(exportSession.status); error=\(exportSession.error)")
        }
    }
    
    private var placeholder : AVAsset
    override init() {
        let mainBundle = NSBundle.mainBundle();
        let placeholderVideoPath = mainBundle.pathForResource("EmptyPleaceholder", ofType: "m4v");
        let placeholderURL = NSURL(fileURLWithPath: placeholderVideoPath!)
        self.placeholder = AVURLAsset(URL: placeholderURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        
        super.init()
    }
}