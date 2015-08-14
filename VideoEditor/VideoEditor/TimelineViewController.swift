//
//  TimelineViewController.swift
//  VideoEditor
//
//  Created by Alexander on 8/13/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

import Foundation

class TimelineViewController: UIViewController {
    
    override func  viewDidLoad() {
        super.viewDidLoad()
    }
    
    var videoComposition : VideoComposition?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.videoComposition = VideoComposition()
        
        for videoSegment in MediaCollectionModel.currentModel!.collectionItems {
            self.videoComposition!.add(videoSegment)
        }
        
        self.updateState()
    }
    
    var playerController : PlayerViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "PlayerViewControllerSegue") {
            self.playerController = segue.destinationViewController as? PlayerViewController
            self.updateState()
        }
    }
    
    func updateState() {
        if (self.videoComposition != nil && self.playerController != nil) {
            self.playerController?.loadAsset(asset: self.videoComposition!.getAsset(), withVideoComposition: self.videoComposition!.mutableVideoComposition)
        }
    }
    
    @IBAction func doneButtonTouched(sender: AnyObject) {
        UIView.animateWithDuration(0.3) {
            self.tabBarController?.selectedIndex = 3
        }
    }

}