//
//  TWImageLoader.h
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import <Foundation/Foundation.h>
#import "TWPhoto.h"

@interface TWPhotoLoader : NSObject

+ (TWPhotoLoader *)sharedLoader;
@property (strong, readonly, nonatomic) ALAssetsLibrary *assetsLibrary;

+ (void)loadAllPhotosFromAlbum: (ALAssetsGroup *)album completion:(void (^)(NSArray *photos, NSError *error))completion;

@end
