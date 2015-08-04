//
//  TransitionFilters.swift
//  Test
//
//  Created by Alexander on 04.08.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation
import CoreImage
import AVFoundation

class TransitionFilter : NSObject {
    static func makeRundomFilter() -> TransitionFilter {
        
        let possibleNames = [
            "CIAccordionFoldTransition",
            "CIBarsSwipeTransition",
            "CICopyMachineTransition",
            //"CIDisintegrateWithMaskTransition",
            "CIDissolveTransition",
            "CIFlashTransition",
            "CIModTransition",
            //"CIPageCurlTransition",
            //"CIPageCurlWithShadowTransition",
            //"CIRippleTransition",
            "CISwipeTransition"
        ]
        
        let randomNumber : Int  = Int(arc4random_uniform(UInt32(possibleNames.count)))
        let randomName : String = possibleNames[randomNumber]
        
         return TransitionFilter(filterName: randomName)
    }
    
    private(set) var filterName : String
    func getTransitionFromImage(fromImage : CIImage, toImage : CIImage, inputTime : Double) -> CIImage {
        
        let filter = CIFilter(name: self.filterName)
        filter.setDefaults()
        
        filter.setValue(fromImage, forKey: "inputImage")
        filter.setValue(toImage, forKey: "inputTargetImage")
        
        filter.setValue(NSNumber(double: inputTime), forKey: "inputTime")
        
        return filter.valueForKey(kCIOutputImageKey) as! CIImage
        
    }
    
    private init(filterName : String) {
        self.filterName = filterName
        super.init()
    }
}