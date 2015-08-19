//
//  VideoEditorAssetsCollection.m
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "VideoEditorAssetsCollection.h"

@interface VideoEditorAssetsCollection ()

@property (strong, nonatomic, readwrite) NSMutableArray* assets;

@end

@implementation VideoEditorAssetsCollection

+(instancetype) currentlyEditedCollection {
    static VideoEditorAssetsCollection *sharedCollection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCollection = [[self alloc] init];
    });
    return sharedCollection;
};


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.assets = [NSMutableArray new];
    }
    return self;
}

-(BOOL) hasAsset: (PickerAsset*) asset {
    return [self getIndexOfAsset:asset] >= 0 ? YES : NO;
}

-(NSInteger) getIndexOfAsset: (PickerAsset*) asset {
    NSURL *url = [asset getURL];
    
    NSInteger index = -1;
    for (PickerAsset* existingAsset in self.assets) {
        index++;
        
        if ([url isEqual:[existingAsset getURL]]) {
            return index;
        }
    }
    return -1;
}

-(void) addAsset: (PickerAsset*) asset {
    [self.assets addObject:asset];
}

-(void) removeAsset: (PickerAsset*) asset {
    NSInteger index = [self getIndexOfAsset:asset];
    
    if (index >= 0) {
        [self.assets removeObject:self.assets[index]];
    }
}

@end
