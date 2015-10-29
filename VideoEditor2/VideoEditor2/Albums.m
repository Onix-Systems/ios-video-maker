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

@interface Albums () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *albums;

@end

@implementation Albums

- (void) viewDidLoad {
    [super viewDidLoad];
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
    AlbumsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumsTableViewCell" forIndexPath:indexPath];
    
    PHAssetCollection *album = self.albums[indexPath.row];
    
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
    
    ImageSelectDataSource *dataSource = [[ImageSelectDataSource alloc] initWithAssetsCollection:self.albums[indexPath.row]];
    
    imageSelector.dataSource = dataSource;
    
    [self presentViewController:imageSelector animated:YES completion:NULL];
}

@end
