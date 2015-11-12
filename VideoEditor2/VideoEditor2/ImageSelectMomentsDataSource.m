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

@property (strong, nonatomic) NSMutableDictionary *momentsTitles;
@property (strong, nonatomic) NSMutableDictionary *momentsData;
@property (strong, nonatomic) NSMutableArray *momentsKeys;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) PHFetchResult* collectionsFetchResult;
@property (strong, nonatomic) NSMutableDictionary* momentsFetchResults;

@property (strong,nonatomic) NSArray<NSIndexPath *>* removedIndexes;
@property (strong,nonatomic) NSArray<NSIndexPath *>* insertedIndexes;
@property (strong,nonatomic) NSArray<NSIndexPath *>* changedIndexes;

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
    
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.collectionsFetchResult];
    if (collectionChanges == nil) {
        NSLog(@"There are no changes for the collection");
        return;
    }
    
    [self loadAssets];
    
//    if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self getAssetsFromFetchResults: [collectionChanges fetchResultAfterChanges]];
//            self.didFinishLoading(nil);
//        });
//    } else {
//        PHFetchResult* newFetchResults = [collectionChanges fetchResultAfterChanges];
//        
//        self.removedIndexes = nil;
//        NSIndexSet* removedIndexesSet = collectionChanges.removedIndexes;
//        if ([removedIndexesSet count] > 0) {
//            NSMutableArray* removedIndexes = [NSMutableArray new];
//            
//            [removedIndexesSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
//                [removedIndexes addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
//                [self.assets removeObjectAtIndex:idx];
//            }];
//            
//            self.removedIndexes = removedIndexes;
//        }
//        
//        self.insertedIndexes = nil;
//        NSIndexSet* insertedIndexesSet = collectionChanges.insertedIndexes;
//        if ([insertedIndexesSet count] > 0) {
//            NSMutableArray* insertedIndexes = [NSMutableArray new];
//            
//            [insertedIndexesSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
//                [insertedIndexes addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
//                [self.assets insertObject:[VAssetPHImage makeFromPHAsset:newFetchResults[idx]] atIndex:idx];
//                
//            }];
//            
//            self.insertedIndexes = insertedIndexes;
//        }
//        
//        self.changedIndexes = nil;
//        NSIndexSet* changedIndexesSet = collectionChanges.changedIndexes;
//        if ([changedIndexesSet count] > 0) {
//            NSMutableArray* changedIndexes = [NSMutableArray new];
//            [changedIndexesSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
//                [changedIndexes addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
//                VAssetPHImage* asset = self.assets[idx];
//                if (![asset isDownloading]) {
//                    [asset updateAsset: newFetchResults[idx]];
//                }
//            }];
//            self.changedIndexes = changedIndexes;
//        }
//        
//        NSLog(@"ImageSelectDataSouce batchUpdate removedIndexes=%lu insertedIndexes=%lu changedIndexes=%lu", (unsigned long)self.removedIndexes.count, (unsigned long)self.insertedIndexes.count, (unsigned long)self.changedIndexes.count);
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kImageSelectDataSourceHasBatchChanges object:self];
//    };
    
}

-(void)loadAssets {
    self.isLoading = YES;
    
    self.momentsTitles = [NSMutableDictionary new];
    self.momentsData = [NSMutableDictionary new];
    self.momentsKeys = [NSMutableArray new];
    
    PHFetchOptions* options = [PHFetchOptions new];
    options.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO],
                                ];
    //options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    self.collectionsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType: PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAny options:options];
    self.momentsFetchResults = [NSMutableDictionary new];
    
    for(PHAssetCollection *collection in self.collectionsFetchResult) {
        NSString *key = collection.localIdentifier;

        NSString *title = collection.localizedTitle != nil ? collection.localizedTitle : [self.dateFormatter stringFromDate:collection.startDate];
        
        self.momentsTitles[key] = title;
        
        [self.momentsKeys addObject:key];
        
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                         ];
        
        PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
        self.momentsFetchResults[key] = results;
        
        NSMutableArray* assets = [NSMutableArray new];
        for (PHAsset *asset in results) {
            [assets addObject:[VAssetPHImage makeFromPHAsset:asset]];
        }
        self.momentsData[key] = assets;
    }

    self.isLoading = NO;
    self.didFinishLoading(nil);
}

-(NSInteger)getNumberofSectionsInData {
    return self.momentsKeys.count;
}

-(NSDictionary*) getAssetsBySections {
    return self.momentsData;
}

-(NSArray*) getSectionsKeys {
    return self.momentsKeys;
}

-(NSString*) getSectionTitle: (id) sectionKey {
    return self.momentsTitles[sectionKey];
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

@end
