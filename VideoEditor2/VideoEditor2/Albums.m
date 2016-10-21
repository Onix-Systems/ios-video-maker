//
//  Albums.m
//  VideoEditor2
//
//  Created by Alexander on 8/17/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "Albums.h"
#import "ImageSelectorController.h"
#import "ImageSelectDataSource.h"
#import "AlbumsCell.h"

@interface Albums () <UITableViewDelegate, UITableViewDataSource, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *fetchResults;

@end

@implementation Albums


- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self loadAlbums];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *popButton = [[UIBarButtonItem alloc] initWithTitle:@"Show" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = popButton;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

-(void) photoLibraryDidChange:(PHChange *)changeInstance
{
    NSLog(@"Albums photoLibraryDidChange - %@", changeInstance);
    
    BOOL hasChanges = NO;
    BOOL needCompleteReload = NO;
    
    NSMutableArray* newFetchResults = [NSMutableArray new];
    
    NSMutableArray* removedIndexes = [NSMutableArray new];
    NSMutableArray* insertedIndexes = [NSMutableArray new];
    NSMutableArray* changedIndexes = [NSMutableArray new];
    NSInteger previousFetchResultsCount = 0;
    
    for (NSInteger i = 0; i < self.fetchResults.count; i++) {
        PHFetchResult* oldResults = self.fetchResults[i];
        
        PHFetchResultChangeDetails *albumsCollectionChanges = [changeInstance changeDetailsForFetchResult:oldResults];
        
        if (albumsCollectionChanges != nil) {
            hasChanges = YES;
            
            PHFetchResult* newFetchResult = [albumsCollectionChanges fetchResultAfterChanges];
            [newFetchResults addObject:newFetchResult];
            
            if (![albumsCollectionChanges hasIncrementalChanges] || [albumsCollectionChanges hasMoves]) {
                needCompleteReload = YES;
                
            } else {
                [albumsCollectionChanges.removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [removedIndexes addObject: [NSIndexPath indexPathForItem:(previousFetchResultsCount + idx) inSection:0]];
                }];
                [albumsCollectionChanges.insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [insertedIndexes addObject: [NSIndexPath indexPathForItem:(previousFetchResultsCount + idx) inSection:0]];
                }];
                [albumsCollectionChanges.changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [changedIndexes addObject: [NSIndexPath indexPathForItem:(previousFetchResultsCount + idx) inSection:0]];
                }];
                
                for (NSInteger j = 0; j < oldResults.count; j++) {
                    if (
                        ([changeInstance changeDetailsForObject:oldResults[j]] != nil)
                        && (![albumsCollectionChanges.removedIndexes containsIndex:j])
                        && (![albumsCollectionChanges.insertedIndexes containsIndex:j])
                        && (![albumsCollectionChanges.changedIndexes containsIndex:j])
                    ) {
                        [changedIndexes addObject: [NSIndexPath indexPathForItem:(previousFetchResultsCount + j) inSection:0]];
                    }
                }
            }
        } else {
            [newFetchResults addObject:oldResults];
        }
        
        previousFetchResultsCount += oldResults.count;
    }
    
    NSLog(@"Albums photoLibraryDidChange: hasChanges=%@ needCompleteReload=%@ removedIndexes=%lu insertedIndexes=%lu changedIndexes=%lu", hasChanges ? @"YES" : @"No", needCompleteReload ? @"YES" : @"NO", (unsigned long)removedIndexes.count, (unsigned long)insertedIndexes.count, (unsigned long)changedIndexes.count);
    
    if (needCompleteReload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fetchResults = newFetchResults;
            [self.tableView reloadData];
        });
        
    } else if (hasChanges && ((removedIndexes.count > 0) || (insertedIndexes.count > 0) || (changedIndexes.count > 0))) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            
            if (removedIndexes.count > 0) {
                [self.tableView deleteRowsAtIndexPaths:removedIndexes withRowAnimation:UITableViewRowAnimationFade];
            }
            
            if (insertedIndexes.count > 0) {
                [self.tableView insertRowsAtIndexPaths:insertedIndexes withRowAnimation:UITableViewRowAnimationLeft];
            }
            
            if (changedIndexes.count > 0) {
                [self.tableView reloadRowsAtIndexPaths:changedIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            self.fetchResults = newFetchResults;
            
            [self.tableView endUpdates];

        });
    }
}

-(void)loadAlbums
{
    self.fetchResults = [NSMutableArray new];
    
    [self fetchAlbums:PHAssetCollectionTypeSmartAlbum subType:PHAssetCollectionSubtypeSmartAlbumVideos];
    [self fetchAlbums:PHAssetCollectionTypeAlbum subType:PHAssetCollectionSubtypeAny];
    [self fetchAlbums:PHAssetCollectionTypeSmartAlbum subType:PHAssetCollectionSubtypeSmartAlbumUserLibrary];
    
    [self.tableView reloadData];
}

-(void)fetchAlbums:(PHAssetCollectionType)type subType: (PHAssetCollectionSubtype) subType {
    PHFetchOptions* options = [PHFetchOptions new];
    //options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType: type subtype:subType options:options];
    [self.fetchResults addObject:results];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    for (NSInteger i = 0; i < self.fetchResults.count; i++) {
        PHFetchResult *result = self.fetchResults[i];
        count += result.count;
    }
    return count;
}

-(PHAssetCollection*)getAlbumForIndexPath: (NSIndexPath*) indexPath
{
    PHAssetCollection *album = nil;
    NSInteger currentFetchResult = 0;
    NSInteger prevFetchResultsItemsCount = 0;
    NSInteger index = indexPath.row;
    
    while ((album == nil) && (currentFetchResult < self.fetchResults.count)) {
        PHFetchResult *result = self.fetchResults[currentFetchResult];
        
        if ((result.count + prevFetchResultsItemsCount) > index) {
            NSInteger localIndex = index - prevFetchResultsItemsCount;
            album = [result objectAtIndex:localIndex];
        } else {
            currentFetchResult++;
            prevFetchResultsItemsCount += result.count;
            
            if (currentFetchResult >= self.fetchResults.count) {
                return nil;
            }
        }
    }
    
    return album;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumsTableViewCell" forIndexPath:indexPath];
    
    PHAssetCollection *album = [self getAlbumForIndexPath:indexPath];
    
    cell.albumTitle.text = album.localizedTitle;
    cell.albumThumbnail.image = [UIImage imageNamed:@"no-photo"];
    
    PHFetchResult *keyAssets = [PHAsset fetchKeyAssetsInAssetCollection:album options:nil];
    if (keyAssets.count > 0) {
        PHImageRequestOptions* options = [PHImageRequestOptions new];
        
        [[PHImageManager defaultManager] requestImageForAsset:keyAssets[0] targetSize:CGSizeMake(100.0, 100.0) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            cell.albumThumbnail.image = result;
        }];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ImageSelectorController *imageSelector = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorController"];
    
    ImageSelectDataSource *dataSource = [[ImageSelectDataSource alloc] initWithAssetsCollection:[self getAlbumForIndexPath:indexPath]];
    
    imageSelector.dataSource = dataSource;
    
    [self.navigationController pushViewController:imageSelector animated:YES];
}

@end
