//
//  PickerAssetDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 8/31/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectDataSource.h"
#import "VAssetPHImage.h"

@interface ImageSelectDataSource() <PHPhotoLibraryChangeObserver>

@property (strong,nonatomic) PHAssetCollection* collection;
@property (strong,nonatomic) PHFetchResult* fetchResults;

@property (strong,nonatomic) NSArray<NSIndexPath *>* removedIndexes;
@property (strong,nonatomic) NSArray<NSIndexPath *>* insertedIndexes;
@property (strong,nonatomic) NSArray<NSIndexPath *>* changedIndexes;

@property (strong,nonatomic) NSMutableArray* assets;

@end

@implementation ImageSelectDataSource

+(PHImageManager*) getImageManager
{
    return [PHImageManager defaultManager];
}

-(instancetype)initWithAssetsCollection:(PHAssetCollection *)collection
{
    self = [super init];
    if (self) {
        self.collection = collection;
        
        self.assets = [NSMutableArray new];
        
        self.supportSearch = NO;
        self.isLoading = NO;
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver: self];

    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

-(NSArray *) getAssets
{
    return self.assets;
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    NSLog(@"dataSource photoLibraryDidChange - %@", changeInstance);
    
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.fetchResults];
    if (collectionChanges == nil) {
        return;
    }
    
    if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
        [self getAssetsFromFetchResults: [collectionChanges fetchResultAfterChanges]];
        self.didFinishLoading(nil);

    } else {
        PHFetchResult* newFetchResults = [collectionChanges fetchResultAfterChanges];
        self.fetchResults = newFetchResults;
        
        self.removedIndexes = nil;
        NSIndexSet* removedIndexesSet = collectionChanges.removedIndexes;
        if ([removedIndexesSet count] > 0) {
            NSMutableArray* removedIndexes = [NSMutableArray new];
            
            [removedIndexesSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [removedIndexes addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                [self.assets removeObjectAtIndex:idx];
            }];

            self.removedIndexes = removedIndexes;
        }
        
        self.insertedIndexes = nil;
        NSIndexSet* insertedIndexesSet = collectionChanges.insertedIndexes;
        if ([insertedIndexesSet count] > 0) {
            NSMutableArray* insertedIndexes = [NSMutableArray new];
            
            [insertedIndexesSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [insertedIndexes addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                [self.assets insertObject:[VAssetPHImage makeFromPHAsset:newFetchResults[idx]] atIndex:idx];
                
            }];
            
            self.insertedIndexes = insertedIndexes;
        }
        
        self.changedIndexes = nil;
        NSIndexSet* changedIndexesSet = collectionChanges.changedIndexes;
        if ([changedIndexesSet count] > 0) {
            NSMutableArray* changedIndexes = [NSMutableArray new];
            [changedIndexesSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                if ((removedIndexesSet != nil) && ![removedIndexesSet containsIndex:idx]) {
                    [changedIndexes addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                    VAssetPHImage* asset = self.assets[idx];
                    if (![asset isDownloading]) {
                        [asset updateAsset: newFetchResults[idx]];
                    }
                }
            }];
            self.changedIndexes = changedIndexes;
        }
        
        NSLog(@"ImageSelectDataSouce batchUpdate removedIndexes=%lu insertedIndexes=%lu changedIndexes=%lu", (unsigned long)self.removedIndexes.count, (unsigned long)self.insertedIndexes.count, (unsigned long)self.changedIndexes.count);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kImageSelectDataSourceHasBatchChanges object:self];
    };

}

-(void)getAssetsFromFetchResults: (PHFetchResult*) fetchResult
{
    NSMutableArray* assets = [NSMutableArray new];

    self.fetchResults = fetchResult;
    
    for (PHAsset *asset in self.fetchResults) {
        [assets addObject:[VAssetPHImage makeFromPHAsset:asset]];
    }
    
    self.assets = assets;
}

-(void)loadAssets {
    self.isLoading = YES;

    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[
                                     [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                     ];

    [self getAssetsFromFetchResults: [PHAsset fetchAssetsInAssetCollection:self.collection options:fetchOptions]];
    
    self.isLoading = NO;
    self.didFinishLoading(nil);
}

-(NSArray<NSIndexPath *>*)getBatchChangeRemovedIndexes
{
    return self.removedIndexes;
}

-(NSArray<NSIndexPath *>*)getBatchChangeInsertedIndexes
{
    return self.insertedIndexes;
}

-(NSArray<NSIndexPath *>*)getBatchChangedChangedIndexes
{
    return self.changedIndexes;
}

-(VAsset*) getAssetWithID:(NSString*)assetID
{
    for (NSInteger i = 0; i < self.assets.count; i++) {
        VAsset* asset = self.assets[i];
        if ([[asset getIdentifier] isEqualToString:assetID]) {
            return asset;
        }
    }
    return nil;
}

@end
