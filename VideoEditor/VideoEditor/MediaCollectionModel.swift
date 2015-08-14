//
//  MediaCollectionModel.swift
//  VideoEditor
//
//  Created by Alexander on 8/12/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

import Foundation

protocol MediaCollectionModelDelagate {
    func didFinishedWorkwithImagePicker() -> Void
}

class MediaCollectionModel {
    static var currentModel : MediaCollectionModel?
    
    static func startEditingNewModel() {
        MediaCollectionModel.currentModel = MediaCollectionModel()
    }
    
    var delegate : MediaCollectionModelDelagate?
    var collectionItems : [VideoCompositionSegment]
    
    init() {
        self.collectionItems = [VideoCompositionSegment]()
    }
    
}