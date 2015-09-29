//
//  PlayerViewController.swift
//  Test
//
//  Created by Alexander on 29.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var timelineSlider: UISlider!
    @IBOutlet weak var timelineLabel: UILabel!
    
    var playingNow : Bool = false
    var playerObserver : AnyObject?
    var player : AVPlayer? = nil {
        willSet {
            self.stopPlaying()
        }
    }
    var playerItem : AVPlayerItem? {
        willSet {
            self.removePlayerItemObservers()
        }
    }
    
    func playerLoded() -> Bool {
        return (self.player != nil) && (self.playerItem != nil) && (self.player!.status == .ReadyToPlay) && (self.playerItem!.status == .ReadyToPlay)
    }
    
    @IBAction func playButtonAction(sender: UIBarButtonItem) {
        if (self.playingNow) {
            self.stopPlaying()
        } else {
            self.startPlaying()
        }
    }

    func playerFinishedPaying() {
        self.player?.seekToTime(kCMTimeZero);
        self.stopPlaying()
        self.updateViewState()
    }

    func startPlaying() {
        if (!self.playerLoded() || self.playingNow) {
            return
        }
        
        self.addTimeObserver()
        self.player!.play()
        self.playingNow = true
        self.updatePlayButton()
    }
    
    func stopPlaying() {
        if (!self.playerLoded() || !self.playingNow) {
            return
        }
        
        self.player!.pause()
        self.removeTimeObserver()
        self.playingNow = false
        self.updatePlayButton()
    }
    
    func updatePlayButton() {
        let buttonStyle : UIBarButtonSystemItem = self.playingNow ? UIBarButtonSystemItem.Pause : UIBarButtonSystemItem.Play;
        
        let newPlayButton  = UIBarButtonItem(barButtonSystemItem: buttonStyle, target: self, action: Selector("playButtonAction:"))
        
        var items = self.toolbar.items
        
        items![1] = newPlayButton
        
        self.toolbar.setItems(items, animated: true)
        
        self.playButton = newPlayButton;
    }
    
    func removeTimeObserver() {
        if (self.playerLoded() && self.playerObserver != nil) {
            self.player!.removeTimeObserver(self.playerObserver!)
            self.playerObserver = nil
        }
    }
    
    func addTimeObserver() {
        if (self.playerLoded() && self.playerObserver == nil) {
            self.playerObserver = self.player!.addPeriodicTimeObserverForInterval(CMTimeMake(200, 1000), queue: dispatch_get_main_queue()) {
                time -> Void in
                self.updateViewState()
            }
        }
    }
    
    var playerTime : CMTime {
        get {
            if (self.player != nil) {
                return self.player!.currentTime()
            }
            return CMTimeMake(0, 1000)
        }
        
        set(time) {
            if (self.player != nil) {
                self.player!.seekToTime(time)
            }
        }
    }
    
    var asset : AVAsset?
    
    var playerItemObservingContextStr = "Zzz"
    var playerItemObservingContext : UnsafeMutablePointer<Void> = nil
    
    func initPlayerItemObservingContext(pointer: UnsafeMutablePointer<Void>) {
        self.playerItemObservingContext = pointer
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateViewState()
        
        self.initPlayerItemObservingContext(&self.playerItemObservingContextStr)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.stopPlaying()
    }
    
    func updateViewState() {
        if (self.playerLoded()) {
            self.playButton.enabled = true
            
            self.timelineSlider.maximumValue = 0;
            self.timelineSlider.maximumValue = Float(CMTimeGetSeconds(self.playerItem!.duration))
            self.timelineSlider.value = Float(CMTimeGetSeconds(self.playerTime));
            
            self.timelineSlider.enabled = true
        } else {
            self.playButton.enabled = false
            self.timelineSlider.enabled = false
        }
        
        self.updateTimelineLabel()
    }
    
    @IBAction func timelineSliderChanged(sender: AnyObject) {
        let desiredTime = CMTimeMake(Int64(round(self.timelineSlider.value * 1000)), 1000)
        
        self.playerTime = desiredTime
        self.updateTimelineLabel()
    }
    
    func updateTimelineLabel() {
        var currentTime : Double = CMTimeGetSeconds(self.playerTime);
                
        if (!isfinite(currentTime)) {
            currentTime = 0;
        }
        
        currentTime = round(currentTime);
        
        let seconds = currentTime % 60;
        let minutes = (currentTime - seconds) / 60;
        
        self.timelineLabel.text = String(format: "%02.0f:%02.0f", arguments: [minutes, seconds]);
     }
    
    func loadAsset(fromResource resurce: String, ofType: String) {
        let mainBundle = NSBundle.mainBundle();
        let originalVideoPath = mainBundle.pathForResource(resurce, ofType: ofType);
        let url = NSURL(fileURLWithPath: originalVideoPath!)
        
        self.loadAsset(fromURL: url)
    }
    
    func loadAsset(fromURL url : NSURL) {
        let asset : AVURLAsset! = AVURLAsset(URL: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        self.loadAsset(asset: asset)
    }
    
    func loadAsset(asset asset : AVAsset) {
        self.loadAsset(asset: asset, withVideoComposition: nil)
    }
    
    var playerItemObserverIsSetup = false
    func loadAsset(asset asset : AVAsset, withVideoComposition videoComposition : AVVideoComposition?) {
        let keys = ["duration", "tracks"]
        
        self.player = nil
        self.playerItem = nil
        
        self.asset = asset
        
        asset.loadValuesAsynchronouslyForKeys(keys) {
            dispatch_async(dispatch_get_main_queue()) {
                let error = NSErrorPointer();
                
                let tracksStatus = asset.statusOfValueForKey("duration", error: error)
                
                switch (tracksStatus) {
                case AVKeyValueStatus.Loaded:
                    NSLog("loaded. Duration=%d %d", asset.duration.value, asset.duration.timescale)
                    
                    self.playerItem = AVPlayerItem(asset: asset)
                    
                    if (videoComposition != nil) {
                        self.playerItem!.videoComposition = videoComposition!
                    }
                    
                    self.playerItem!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.Initial, context: self.playerItemObservingContext)
                    self.playerItemObserverIsSetup = true
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerFinishedPaying"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
                    
                    
                    assert(self.playerItem != nil, "self.playerItem")
                    
                    
                    self.player = AVPlayer(playerItem: self.playerItem!)
                    self.playerView.player = self.player!
                    
                    //self.playerView.player = AVPlayer(playerItem: self.playerItem!)!
                    //self.player = self.playerView.player
                    
                case AVKeyValueStatus.Failed:
                    NSLog("Error loading asset")
                    
                case AVKeyValueStatus.Cancelled:
                    NSLog("Loading canceled")
                    
                default :
                    break
                }
            }
        }

    }
    
    func removePlayerItemObservers() {
        if (self.playerItem != nil && self.playerItemObserverIsSetup) {
            self.playerItemObserverIsSetup = false
            self.playerItem!.removeObserver(self, forKeyPath: "status")
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        NSLog("observedValue for \(keyPath) of \(object) = \(object)")
        NSLog("playerItem.status = %@", [self.playerItem!.status == .ReadyToPlay ? "ReadyToPlay" : self.playerItem!.status == .Failed ? "Failed" : "UnknownStatus"])
        NSLog("playerItem.error = \(self.playerItem!.error)")
        if (context == playerItemObservingContext) {
            dispatch_async(dispatch_get_main_queue(), {
                NSLog("playerItem Duration=\(self.playerItem!.duration.value)/\(self.playerItem!.duration.timescale)")
                self.updateViewState()
            })
        }
    }

}