//
//  VAssetPHImage.h
//  VideoEditor2
//
//  Created by Alexander on 9/18/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "VAsset.h"

@interface VAssetPHImage : VAsset

+(VAsset*) makeFromPHAsset: (PHAsset *) asset;
-(void)updateAsset: (PHAsset *) asset;

@end
