//
//  TWImageLoader.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "TWPhotoLoader.h"

@interface TWPhotoLoader ()
@property (strong, nonatomic) NSMutableArray *allPhotos;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (readwrite, copy, nonatomic) void(^loadBlock)(NSArray *photos, NSError *error);
@property (weak, nonatomic) ALAssetsGroup *album;
@end



@implementation TWPhotoLoader

+ (TWPhotoLoader *)sharedLoader {
    static TWPhotoLoader *loader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[TWPhotoLoader alloc] init];
    });
    return loader;
}

+ (void)loadAllPhotosFromAlbum: (ALAssetsGroup *)album completion:(void (^)(NSArray *photos, NSError *error))completion {
    [TWPhotoLoader sharedLoader].album = album;
    [[TWPhotoLoader sharedLoader] setLoadBlock:completion];
    [[TWPhotoLoader sharedLoader] startLoading];
}

- (void)startLoading {
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            TWPhoto *photo = [TWPhoto new];
            photo.asset = result;
            [self.allPhotos addObject:photo];
        } else if (self.album != nil) {
            self.loadBlock(self.allPhotos, nil);
        }
        
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
//        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
//        [group setAssetsFilter:onlyPhotosFilter];
        
        if ([group numberOfAssets] > 0) {
//            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
//            }
        }
        
        if (group == nil) {
            self.loadBlock(self.allPhotos, nil);
        }
        
    };
    
    _allPhotos = [NSMutableArray array];
    
    if (self.album != nil) {
        [self.album enumerateAssetsUsingBlock:assetsEnumerationBlock];
    } else {
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:listGroupBlock failureBlock:^(NSError *error) {
            self.loadBlock(nil, error);
        }];
    }
}

- (NSMutableArray *)allPhotos {
    if (_allPhotos == nil) {
        _allPhotos = [NSMutableArray array];
    }
    return _allPhotos;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

@end
