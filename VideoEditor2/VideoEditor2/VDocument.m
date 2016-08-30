//
//  VDocument.m
//  VideoEditor2
//
//  Created by Alexander on 9/18/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VDocument.h"

@interface VDocument ()

@property (strong, readwrite) AssetsCollection* assetsCollection;
@property (strong, readwrite) AssetsCollection* tmpAssetsCollection;
@property (strong, readwrite) VSegmentsCollection* segmentsCollection;

@end

@implementation VDocument

+(VDocument*) getCurrentDocument
{
    static VDocument *currentDocument = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        currentDocument = [VDocument new];
    });
    
    return currentDocument;

}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.assetsCollection = [AssetsCollection new];
        self.tmpAssetsCollection = [AssetsCollection new];
        self.segmentsCollection = [VSegmentsCollection new];
        
        self.segmentsCollection.assetsCollection = self.assetsCollection;
    }
    return self;
}

-(void)updateAssetsCollection {
    if (self.tmpAssetsCollection.getAssets.count > 0) {
        [self.assetsCollection addArrayAssets:self.tmpAssetsCollection.getAssets];
        self.tmpAssetsCollection = [AssetsCollection new];
    }
}

@end
