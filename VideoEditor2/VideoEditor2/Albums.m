//
//  Albums.m
//  VideoEditor2
//
//  Created by Alexander on 8/17/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "Albums.h"
#import "ImageSelectController.h"
#import "ImageSelectDataSource.h"

#include <Photos/Photos.h>

@interface Albums () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *albums;

@end

@implementation Albums

- (void) viewDidLoad {
    [super viewDidLoad];
    
//    [BaseImageSelectDataSource.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        if (group != nil) {
//            [self.albums addObject: group];
//        } else {
//            [self.tableView reloadData];
//        }
//        
//    } failureBlock:^(NSError *error) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
//                                                        message:error.localizedDescription
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                              otherButtonTitles:nil];
//        [alert show];
//    }];
    
    self.albums = [NSMutableArray new];
    
    
    [self fetchAlbums:PHAssetCollectionTypeSmartAlbum subType:PHAssetCollectionSubtypeSmartAlbumVideos];
    [self fetchAlbums:PHAssetCollectionTypeAlbum subType:PHAssetCollectionSubtypeAny];
    [self fetchAlbums:PHAssetCollectionTypeSmartAlbum subType:PHAssetCollectionSubtypeSmartAlbumUserLibrary];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)fetchAlbums:(PHAssetCollectionType)type subType: (PHAssetCollectionSubtype) subType {
    PHFetchOptions* options = [PHFetchOptions new];
    //options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType: type subtype:subType options:options];
    
    for(PHAssetCollection *collection in results) {
        [self.albums addObject:collection];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.albums.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumsTableViewCell" forIndexPath:indexPath];
    
    PHAssetCollection *album = self.albums[indexPath.row];
    
    NSString *type;
    
    switch (album.assetCollectionType) {
        case PHAssetCollectionTypeAlbum: type = @"TypeAlbum"; break;
        case PHAssetCollectionTypeSmartAlbum: type = @"TypeSmartAlbum"; break;
        case PHAssetCollectionTypeMoment: type = @"TypeMoment"; break;
        default: type = @"zzz"; break;
    }
    
    NSString *subType;
    
    switch (album.assetCollectionSubtype) {
        case PHAssetCollectionSubtypeAlbumRegular: subType = @"SubtypeAlbumRegular"; break;
        case PHAssetCollectionSubtypeAlbumSyncedEvent: subType = @"SubtypeAlbumSyncedEvent"; break;
        case PHAssetCollectionSubtypeAlbumSyncedFaces: subType = @"SubtypeAlbumSyncedFaces"; break;
        case PHAssetCollectionSubtypeAlbumSyncedAlbum: subType = @"SubtypeAlbumSyncedAlbum"; break;
        case PHAssetCollectionSubtypeAlbumImported: subType = @"SubtypeAlbumImported"; break;
        case PHAssetCollectionSubtypeAlbumMyPhotoStream: subType = @"SubtypeAlbumMyPhotoStream"; break;
        case PHAssetCollectionSubtypeAlbumCloudShared: subType = @"SubtypeAlbumCloudShared"; break;
        case PHAssetCollectionSubtypeSmartAlbumGeneric: subType = @"SubtypeSmartAlbumGeneric"; break;
        case PHAssetCollectionSubtypeSmartAlbumPanoramas: subType = @"SubtypeSmartAlbumPanoramas"; break;
        case PHAssetCollectionSubtypeSmartAlbumVideos: subType = @"SubtypeSmartAlbumVideos"; break;
        case PHAssetCollectionSubtypeSmartAlbumFavorites: subType = @"SubtypeSmartAlbumFavorites"; break;
        case PHAssetCollectionSubtypeSmartAlbumTimelapses: subType = @"SubtypeSmartAlbumTimelapses"; break;
        case PHAssetCollectionSubtypeSmartAlbumAllHidden: subType = @"SubtypeSmartAlbumAllHidden"; break;
        case PHAssetCollectionSubtypeSmartAlbumRecentlyAdded: subType = @"SubtypeSmartAlbumRecentlyAdded"; break;
        case PHAssetCollectionSubtypeSmartAlbumBursts: subType = @"SubtypeSmartAlbumBursts"; break;
        case PHAssetCollectionSubtypeSmartAlbumSlomoVideos: subType = @"SubtypeSmartAlbumSlomoVideos"; break;
        case PHAssetCollectionSubtypeSmartAlbumUserLibrary: subType = @"SubtypeSmartAlbumUserLibrary"; break;
        case PHAssetCollectionSubtypeAny: subType = @"SubtypeAny"; break;

        default:
            break;
    }
    
    NSString *name = album.localizedTitle;
    
    cell.textLabel.text = name;
    PHFetchResult *keyAssets = [PHAsset fetchKeyAssetsInAssetCollection:album options:nil];
    if (keyAssets.count > 0) {
        PHImageRequestOptions* options = [PHImageRequestOptions new];
    
        [[PHImageManager defaultManager] requestImageForAsset:keyAssets[0] targetSize:CGSizeMake(100.0, 100.0) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            cell.imageView.image = result;
            [cell setNeedsLayout];
        }];
    };

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"displayImageSelectFromAlbum"]) {
        ImageSelectController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        [controller loadDataFromDataSource:[[ImageSelectDataSource alloc] initWithAssetsCollection:self.albums[indexPath.row]]];
    }
}

@end
