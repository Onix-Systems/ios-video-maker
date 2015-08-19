//
//  VideoEditorAssetsCollection.h
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PickerAsset.h"

@interface VideoEditorAssetsCollection : NSObject
+(instancetype) currentlyEditedCollection;

@property (strong, nonatomic, readonly) NSMutableArray* assets;

-(BOOL) hasAsset: (PickerAsset*) asset;
-(NSInteger) getIndexOfAsset: (PickerAsset*) asset;
-(void) addAsset: (PickerAsset*) asset;
-(void) removeAsset: (PickerAsset*) asset;

@end
