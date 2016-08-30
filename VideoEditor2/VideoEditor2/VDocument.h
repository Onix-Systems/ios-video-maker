//
//  VDocument.h
//  VideoEditor2
//
//  Created by Alexander on 9/18/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetsCollection.h"
#import "VSegmentsCollection.h"

@interface VDocument : NSObject

+(VDocument*) getCurrentDocument;

@property (strong, readonly) AssetsCollection* assetsCollection;
@property (strong, readonly) VSegmentsCollection* segmentsCollection;
@property (strong, readonly) AssetsCollection* tmpAssetsCollection;

-(void)updateAssetsCollection;
@end
