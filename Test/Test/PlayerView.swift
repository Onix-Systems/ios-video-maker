//
//  PlayerView.swift
//  Test
//
//  Created by Alexander on 29.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PlayerView: UIView {
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    var player : AVPlayer {
        get {
            return (self.layer as! AVPlayerLayer).player!
        }
        set(player) {
            (self.layer as! AVPlayerLayer).player = player
        }
    }
}