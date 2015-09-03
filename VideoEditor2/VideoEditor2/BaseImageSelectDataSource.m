//
//  BasePickerAssetsDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "BaseImageSelectDataSource.h"
#import "PickerAsset.h"

@implementation BaseImageSelectDataSource

+(ALAssetsLibrary*) assetLibrary {
    static ALAssetsLibrary* library;
    
    if (library == nil) {
        library = [ALAssetsLibrary new];
    }
    
    return library;
}

-(void) loadAssetsFromGrop: (ALAssetsGroup*) group into: (NSMutableArray*) assets withCmpletion:(PickerAssetLoadCompletionBlock) groupLoaded {
    
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result != nil) {
            PickerAsset *asset = [PickerAsset makeFromALAsset:result];
            [assets addObject:asset];
        } else {
            groupLoaded(nil);
        }
    }];
}

-(void)loadAssets {
    
}

-(int)numberofSectionsInData {
    return 0;
}

-(NSInteger)getNumberofSectionsInData {
    return 0;
}

-(NSDictionary*) getAssetsBySections {
    return nil;
}

-(NSArray*) getSectionsKeys {
    return nil;
}

-(NSString*) getSectionTitle: (id) sectionKey {
    return nil;
}


-(void)searchFor: (NSString*) searchTerm withCompletion: (PickerAssetLoadCompletionBlock) onLoad {
    
}

-(void)loadMore: (PickerAssetLoadCompletionBlock) onLoad {
    
}

-(NSString*) getCurrentSearchTerm {
    return nil;
}

-(NSArray*) getSeachScopes {
    return nil;
}

-(NSInteger) selectedSearchScope {
    return 0;
}

-(void) switchSearhcScope: (NSInteger) searchScope {
    
}
@end
