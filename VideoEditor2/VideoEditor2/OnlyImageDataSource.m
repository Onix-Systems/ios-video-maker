//
//  OnlyImageDataSource.m
//  VideoEditor2
//
//  Created by Vitaliy Savchenko on 19.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

#import "OnlyImageDataSource.h"
#import "VAssetPHImage.h"

@interface OnlyImageDataSource() <PHPhotoLibraryChangeObserver>

@property (strong,nonatomic) PHAssetCollection* collection;
@property (strong,nonatomic) PHFetchResult* fetchResults;

@property (strong,nonatomic) NSArray<NSIndexPath *>* removedIndexes;
@property (strong,nonatomic) NSArray<NSIndexPath *>* insertedIndexes;
@property (strong,nonatomic) NSArray<NSIndexPath *>* changedIndexes;

@property (strong,nonatomic) NSMutableArray* assets;

@end

@implementation OnlyImageDataSource

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver: self];
    }
    
    return self;
}

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
    
    if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves] || !self.allowVideoAssets) {
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

-(void)loadAssets {
    self.isLoading = YES;
    
    PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [self getAssetsFromFetchResults:results];
}

-(void)getAssetsFromFetchResults: (PHFetchResult*) fetchResult
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    NSMutableArray* assets = [NSMutableArray new];
    
    for (NSInteger i =0; i < fetchResult.count; i++) {
        PHAssetCollection *assetCollection = fetchResult[i];
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        self.fetchResults = assetsFetchResult;
        
        if (assetsFetchResult.count > 0) {
            for (PHAsset *asset in assetsFetchResult) {
                VAsset* phAsset = [VAssetPHImage makeFromPHAsset:asset];
                if (self.allowVideoAssets || !phAsset.isVideo) {
                    [assets addObject:phAsset];
                }
            }
        }
    }
    
    self.assets = assets;
    
    self.isLoading = NO;
    self.didFinishLoading(nil);
}



-(void)setAllowVideoAssets:(BOOL)allowVideoAssets
{
    if (self.allowVideoAssets != allowVideoAssets) {
        [super setAllowVideoAssets:allowVideoAssets];
        
        if (self.fetchResults != nil) {
            [self getAssetsFromFetchResults:self.fetchResults];
        }
    }
}

-(NSArray<NSIndexPath *>*)getBatchUpdateRemovedIndexes
{
    return self.removedIndexes;
}

-(NSArray<NSIndexPath *>*)getBatchUpdateInsertedIndexes
{
    return self.insertedIndexes;
}

-(NSArray<NSIndexPath *>*)getBatchUpdateChangedIndexes
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
