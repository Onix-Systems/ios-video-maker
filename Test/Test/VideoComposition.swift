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
import AssetsLibrary

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
    
    func addSegmentWithPickerInfo(info : [NSObject : AnyObject], onLoad : Void -> Void ) {
        let mediaType : NSString = info[UIImagePickerControllerMediaType] as! NSString
        
        if (mediaType == kUTTypeImage) {
            let image  = info[UIImagePickerControllerEditedImage] as! UIImage
            
            self.add(VideoCompositionImageSegment(image: image))
            
        } else if (mediaType == kUTTypeMovie) {
            let videoURL : NSURL = info[UIImagePickerControllerMediaURL] as! NSURL
            
            self.add(VideoCompositionVideoSegment(assetURL: videoURL, onLoad : onLoad))
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
    var mutableAudioMix : AVMutableAudioMix!
    
    func clearCurrentComposition() {
        self.mutableComposition = nil
        self.mutableVideoComposition = nil
        self.mutableAudioMix = nil
    }
    
    func getAsset() -> AVAsset {
        if (self.mutableComposition == nil || self.mutableVideoComposition == nil) {
            //self.buildCompositionObjectsForPlayback()
            //self.generateAVComposition()
            self.generateAVComposition()
        }
        
        return self.mutableComposition!
    }
    
    func hasAudio() -> Bool {
        for segment in self.segments {
            if (segment.segmentType() == VideoCompositionSegemntType.video) {
                let videoSegment = (segment as! VideoCompositionVideoSegment)
                if (videoSegment.audioTrack != nil) {
                    return true
                }
            }
        }
        return false
    }
    
    func generateAVComposition() {
        let videoSize = CGSizeMake(720, 480)
        
        self.mutableComposition = AVMutableComposition()
        self.mutableComposition.naturalSize = videoSize
        
        var videoTracks = [AVMutableCompositionTrack]()
        videoTracks.append(self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)))
        videoTracks.append(self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)))
        
        var audioTracks = [AVMutableCompositionTrack]()
        if (self.hasAudio()) {
            self.mutableAudioMix = AVMutableAudioMix()
            audioTracks.append(self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)))
            audioTracks.append(self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)))
        }
        
        self.mutableVideoComposition = AVMutableVideoComposition()
        self.mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
        self.mutableVideoComposition.renderSize = videoSize
        self.mutableVideoComposition.customVideoCompositorClass = VideoCompositor.self
        
        var currentSegmentStartTime = kCMTimeZero
        var instructions = [AVVideoCompositionInstructionProtocol]()
        
        var audioMixParameters = [AVMutableAudioMixInputParameters]()
            
        let placeholderVideoTrack : AVAssetTrack = self.placeholder.tracksWithMediaType(AVMediaTypeVideo)[0] 

        //self.audioTrack = self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        let transitionDuration = CMTimeMake(1500, 1000)
        
        for (var i = 0; i < self.segments.count; i++) {
            let currentTrackIndex = i % 2;
            
            let segment = self.segments[i]
            let segmentDuration = segment.duration
            
            let previousSegment : VideoCompositionSegment! = (i > 0 ? self.segments[i - 1] : nil)
            let hasTransitionBefore = i > 0 ? true : false
            let hasTransitionNext = i + 1 < self.segments.count ? true : false
            
            let timeRangeInOriginal = CMTimeRangeMake(kCMTimeZero, segment.duration)
            var transitionTimeRange : CMTimeRange?
            var passThroughTimeRange : CMTimeRange!
            
//            var passThroughTimeRange = CMTimeRangeMake(currentSegmentStartTime, timeRangeInOriginal.duration)
            
            if (hasTransitionBefore) {
                transitionTimeRange = CMTimeRangeMake(currentSegmentStartTime, transitionDuration)

                if (segment.segmentType() == VideoCompositionSegemntType.video) {
                    //Transition from ... to video
                    
                    let passThroughDuration = CMTimeSubtract(timeRangeInOriginal.duration, transitionDuration)
                    if (hasTransitionNext) {
                        passThroughTimeRange = CMTimeRangeMake(CMTimeAdd(transitionTimeRange!.start, transitionTimeRange!.duration), CMTimeSubtract(passThroughDuration, transitionDuration))
                    } else {
                        passThroughTimeRange = CMTimeRangeMake(CMTimeAdd(transitionTimeRange!.start, transitionTimeRange!.duration), passThroughDuration)
                    }
                } else if (segment.segmentType() == .image) {
                    //Transition from ... to image
                    if (previousSegment.segmentType() == VideoCompositionSegemntType.image) {
                        do {
                            //image to image transition
                            //put empty placeholder into transition timerange
                            try videoTracks[currentTrackIndex].insertTimeRange(CMTimeRangeMake(kCMTimeZero, transitionDuration), ofTrack: placeholderVideoTrack, atTime: currentSegmentStartTime)
                        } catch _ {
                        }
                    }
                    
                    //shift start time for the transition duration
                    currentSegmentStartTime = CMTimeAdd(currentSegmentStartTime, transitionDuration)

                    passThroughTimeRange = CMTimeRangeMake(currentSegmentStartTime, timeRangeInOriginal.duration)
                    do {
                        //fill image timerange with empty placeholder
                        try videoTracks[currentTrackIndex].insertTimeRange(timeRangeInOriginal, ofTrack: placeholderVideoTrack, atTime: currentSegmentStartTime)
                    } catch _ {
                    }
                }
            } else {
                transitionTimeRange = nil
                if (segment.segmentType() == VideoCompositionSegemntType.video) {
                    passThroughTimeRange = CMTimeRangeMake(currentSegmentStartTime, CMTimeSubtract(timeRangeInOriginal.duration, transitionDuration))
                    
                } else if (segment.segmentType() == .image) {
                    passThroughTimeRange = CMTimeRangeMake(currentSegmentStartTime, timeRangeInOriginal.duration)
                }
            }
            
            if (transitionTimeRange != nil) {
                let transitionInstruction = TransitionInstuction(curentSegment: segment, curentTrackID: videoTracks[currentTrackIndex].trackID, previousSegment: previousSegment, previousTrackID: videoTracks[1 - currentTrackIndex].trackID, timeRange: transitionTimeRange!)
                
//                var transitionInstruction = AVMutableVideoCompositionInstruction()
//                transitionInstruction.timeRange = transitionTimeRange!
//                var transitionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTracks[currentTrackIndex])
//                transitionInstruction.layerInstructions = [transitionLayerInstruction]

                instructions.append(transitionInstruction)
            }

            let imageSegment = segment as? VideoCompositionImageSegment
            let videoSegment = segment as? VideoCompositionVideoSegment
            
            if (imageSegment != nil) {
                let segmentInstruction = StillImageInstuction(image: imageSegment!.image.CGImage!, timeRange: passThroughTimeRange)
                instructions.append(segmentInstruction)
            }
            
            if (videoSegment != nil) {
                do {
                    try videoTracks[currentTrackIndex].insertTimeRange(timeRangeInOriginal, ofTrack: videoSegment!.videoTrack!, atTime: currentSegmentStartTime)
                } catch _ {
                }
                
                if (videoSegment?.audioTrack != nil) {
                    do {
                        try audioTracks[currentTrackIndex].insertTimeRange(timeRangeInOriginal, ofTrack: videoSegment!.audioTrack!, atTime: currentSegmentStartTime)
                    } catch _ {
                    }
                    
                    if (hasTransitionBefore) {
                        let param1 = AVMutableAudioMixInputParameters(track: audioTracks[currentTrackIndex])
                        param1.setVolumeRampFromStartVolume(0.0, toEndVolume: 1.0, timeRange: CMTimeRange(start: currentSegmentStartTime, duration: transitionDuration))
                        audioMixParameters.append(param1)
                    }
                    
                    let param2 = AVMutableAudioMixInputParameters(track: audioTracks[currentTrackIndex])
                    param2.setVolume(1.0, atTime: passThroughTimeRange.start)
                    audioMixParameters.append(param2)
                    
                    if (hasTransitionNext) {
                        let param3 = AVMutableAudioMixInputParameters(track: audioTracks[currentTrackIndex])
                        param3.setVolumeRampFromStartVolume(1.0, toEndVolume: 0.0, timeRange: CMTimeRange(start: CMTimeAdd(passThroughTimeRange.start, passThroughTimeRange.duration), duration: transitionDuration))
                        audioMixParameters.append(param3)
                    }
                }
                
                let segmentInstruction = PassthroughInstuction(passthroughTrackID: videoTracks[currentTrackIndex].trackID, timeRange: passThroughTimeRange)
//                var segmentInstruction = AVMutableVideoCompositionInstruction()
//                segmentInstruction.timeRange = passThroughTimeRange
//                var segmentLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTracks[currentTrackIndex])
//                segmentInstruction.layerInstructions = [segmentLayerInstruction]
               
                instructions.append(segmentInstruction)
            }
            
            currentSegmentStartTime = CMTimeAdd(passThroughTimeRange.start, passThroughTimeRange.duration)
        }
        self.mutableVideoComposition.instructions = instructions
        if (self.mutableAudioMix != nil) {
            self.mutableAudioMix.inputParameters = audioMixParameters
        }
    }
 
    func generateAVCompositionZzz() {
        let videoSize = CGSizeMake(720, 480)
        
        self.mutableComposition = AVMutableComposition()
        self.mutableComposition.naturalSize = videoSize
        
        var videoTracks = [AVMutableCompositionTrack]()
        videoTracks.append(self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)))
        videoTracks.append(self.mutableComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)))
        
        self.mutableVideoComposition = AVMutableVideoComposition()
        self.mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
        self.mutableVideoComposition.renderSize = videoSize
        
        var currentSegmentStartTime = kCMTimeZero
        var instructions = [AVMutableVideoCompositionInstruction]()
        
        for (var i = 0; i < self.segments.count; i++) {
            let currentTrackIndex = i % 2;

            let segment = self.segments[i]
            let asset = (self.segments[i] as! VideoCompositionVideoSegment).asset
            
            let timeRangeInOriginal = CMTimeRangeMake(kCMTimeZero, segment.duration)
            var segmentTimeRange = CMTimeRangeMake(currentSegmentStartTime, timeRangeInOriginal.duration)
            
            let videoSegment = segment as! VideoCompositionVideoSegment
            let clipVideoTrack : AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] ;
            let videoSegemntTrack = videoSegment.videoTrack
            
            NSLog("Assert tracks \(clipVideoTrack == videoSegemntTrack ? 1 : 0) clipVideoTrack \(clipVideoTrack) VideoSegmentTrack \(videoSegemntTrack)")
            
            do {
                try videoTracks[currentTrackIndex].insertTimeRange(timeRangeInOriginal, ofTrack: videoSegment.videoTrack!, atTime: currentSegmentStartTime)
            } catch _ {
            }
            
            var segmentInstruction = AVMutableVideoCompositionInstruction()
            segmentInstruction.timeRange = segmentTimeRange
            var segmentLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTracks[currentTrackIndex])
            segmentInstruction.layerInstructions = [segmentLayerInstruction]
                
            instructions.append(segmentInstruction)
            
            currentSegmentStartTime = CMTimeAdd(currentSegmentStartTime, timeRangeInOriginal.duration)
        }
        self.mutableVideoComposition.instructions = instructions
        
    }
    
    func exportMovieToFile(onFinished : Void -> Void) {
        let fileManager = NSFileManager.defaultManager()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let exportSession = AVAssetExportSession(asset: self.getAsset(), presetName: AVAssetExportPresetHighestQuality)
        
        var urlPart : NSURL
        
        urlPart = (try? fileManager.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true))!
        urlPart = urlPart.URLByAppendingPathComponent(dateFormatter.stringFromDate(NSDate()))
        let url = urlPart.URLByAppendingPathExtension(UTTypeCopyPreferredTagWithClass(AVFileTypeQuickTimeMovie, String(kUTTagClassFilenameExtension))!.takeRetainedValue() as String)
            
        NSLog("Export movie to URL = \(url)")
        
        exportSession!.outputURL = url
        
        exportSession!.outputFileType = AVFileTypeQuickTimeMovie
        exportSession!.shouldOptimizeForNetworkUse = true
        exportSession!.videoComposition = self.mutableVideoComposition
        exportSession!.audioMix = self.mutableAudioMix
        
        exportSession!.exportAsynchronouslyWithCompletionHandler() {
            dispatch_async(dispatch_get_main_queue()) {
                if (exportSession!.status == AVAssetExportSessionStatus.Completed) {
                    NSLog("Export finished; status==Completed;")
                    
                    let assetsLibrary = ALAssetsLibrary()
                    if (assetsLibrary.videoAtPathIsCompatibleWithSavedPhotosAlbum(exportSession!.outputURL)) {
                        NSLog("Add to asset library")
                        assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(exportSession!.outputURL, completionBlock : {
                            (_ : NSURL!, error : NSError!) -> Void in
                            
                            NSLog("Finished adding to asset library - \(error)")
                        });
                    }
                } else {
                    NSLog("Export finished; status!=Completed; error=\(exportSession!.error)")
                }
                
                onFinished()
            }
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