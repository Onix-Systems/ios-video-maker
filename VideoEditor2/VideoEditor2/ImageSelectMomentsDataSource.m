//
//  PickerAssetsMomentsDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectMomentsDataSource.h"
#import "VAsset.h"
#import "VAssetPHImage.h"

@interface ImageSelectMomentsDataSource () <PHPhotoLibraryChangeObserver>

@property (strong, nonatomic) NSMutableArray *momentsData;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) PHFetchResult* collectionsFetchResult;
@property (strong, nonatomic) NSMutableArray* momentsFetchResults;

@property (strong,nonatomic) NSMutableArray<NSIndexPath *>* removedIndexes;
@property (strong,nonatomic) NSMutableArray<NSIndexPath *>* insertedIndexes;
@property (strong,nonatomic) NSMutableArray<NSIndexPath *>* changedIndexes;

@property (strong,nonatomic) NSIndexSet* removedSections;
@property (strong,nonatomic) NSIndexSet* inseretedSections;
@property (strong,nonatomic) NSIndexSet* changedSections;

@end

@implementation ImageSelectMomentsDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver: self];
    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    NSLog(@"dataSource Moments photoLibraryDidChange - %@", changeInstance);
    
    BOOL hasChanges = NO;
    BOOL needCompleteReload = NO;
    
    PHFetchResult* newCollectionsFetchResult = nil;
    
    self.removedSections = nil;
    self.inseretedSections = nil;
    self.changedSections = nil;
    
    self.removedIndexes = [NSMutableArray new];
    self.insertedIndexes = [NSMutableArray new];
    self.changedIndexes = [NSMutableArray new];
    
    PHFetchResultChangeDetails *collectionsChanges = [changeInstance changeDetailsForFetchResult:self.collectionsFetchResult];
    if (collectionsChanges != nil) {
        hasChanges = YES;
        newCollectionsFetchResult = [collectionsChanges fetchResultAfterChanges];
        
        if (![collectionsChanges hasIncrementalChanges] || [collectionsChanges hasMoves]) {
            needCompleteReload = YES;
        } else {
            self.removedSections = collectionsChanges.removedIndexes;
            self.inseretedSections = collectionsChanges.insertedIndexes;
            self.changedSections = collectionsChanges.changedIndexes;
        }
    }
    
    for (NSInteger i = 0; i < self.collectionsFetchResult.count; i++) {
        PHFetchResultChangeDetails *sectionChanges = [changeInstance changeDetailsForFetchResult:self.momentsFetchResults[i]];
        
        if (sectionChanges != nil) {
            hasChanges = YES;
        
            if (![collectionsChanges hasIncrementalChanges] || [collectionsChanges hasMoves]) {
                needCompleteReload = YES;
                break;
            } else {
                [sectionChanges.removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.removedIndexes addObject: [NSIndexPath indexPathForItem:idx inSection:i]];
                }];
                [sectionChanges.insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.insertedIndexes addObject: [NSIndexPath indexPathForItem:idx inSection:i]];
                }];
                [sectionChanges.changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    if ((sectionChanges.removedIndexes != nil) && ![sectionChanges.removedIndexes containsIndex:idx]) {
                        [self.changedIndexes addObject: [NSIndexPath indexPathForItem:idx inSection:i]];
                    }
                }];
            }
        }
    }
    

    if (hasChanges) {
        [self getAssetsFromCollectionsFetchResults:newCollectionsFetchResult];
        
        if (needCompleteReload) {
            self.didFinishLoading(nil);
        } else {
            NSLog(@"ImageSelectMomentsDataSource batchUpdate removedSections=%lu insertedSections=%lu changedSections=%lu; removedIndexes=%lu insertedIndexes=%lu changedIndexes=%lu", (unsigned long)self.removedSections.count, (unsigned long)self.inseretedSections.count, (unsigned long)self.changedSections.count, (unsigned long)self.removedIndexes.count, (unsigned long)self.changedIndexes.count, (unsigned long)self.changedIndexes.count);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kImageSelectDataSourceHasBatchChanges object:self];
        }
    }
    
}

-(void)getAssetsFromCollectionsFetchResults: (PHFetchResult*) collectionsFetchResult
{
    self.collectionsFetchResult = collectionsFetchResult;
    
    self.momentsFetchResults = [NSMutableArray new];
    self.momentsData = [NSMutableArray new];
    
    for(NSInteger i = 0; i < self.collectionsFetchResult.count; i++) {
        PHAssetCollection *collection = self.collectionsFetchResult[i];
        
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                         ];
        
        PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
        self.momentsFetchResults[i] = results;
        
        NSMutableArray* assets = [NSMutableArray new];
        for (PHAsset *asset in results) {
            [assets addObject:[VAssetPHImage makeFromPHAsset:asset]];
        }
        self.momentsData[i] = assets;
    }

}

-(void)loadAssets {
    self.isLoading = YES;
    
    PHFetchOptions* options = [PHFetchOptions new];
    options.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO],
                                ];
    
    [self getAssetsFromCollectionsFetchResults: [PHAssetCollection fetchAssetCollectionsWithType: PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAny options:options]];
    
    self.isLoading = NO;
    self.didFinishLoading(nil);
}

-(NSInteger)getNumberofSectionsInData {
    return self.collectionsFetchResult.count;
}

-(NSArray*) getAssetsBySections {
    return self.momentsData;
}

-(NSString*) getSectionTitle: (NSInteger) sectionNo {
    PHAssetCollection *collection = self.collectionsFetchResult[sectionNo];
    return collection.localizedTitle != nil ? collection.localizedTitle : [self.dateFormatter stringFromDate:collection.startDate];
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

-(NSIndexSet*)getBatchUpdateRemovedSections
{
    return self.removedSections;
}

-(NSIndexSet*)getBatchUpdateInsertedSections
{
    return self.inseretedSections;
}

-(NSIndexSet*)getBatchUpdateChangedSections
{
    return self.changedSections;
}

-(VAsset*) getAssetWithID:(NSString*)assetID
{
    for (NSInteger i = 0; i < self.momentsData.count; i++) {
        NSArray* momentAssets = self.momentsData[i];
        for (NSInteger j = 0; j < momentAssets.count; j++) {
            VAsset* asset = momentAssets[j];
            if ([[asset getIdentifier] isEqualToString:assetID]) {
                return asset;
            }
        }
    }
    return nil;
}

@end
