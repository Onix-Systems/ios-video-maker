//
//  PickerAssetsMomentsDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectMomentsDataSource.h"
#import "PickerAsset.h"

@interface ImageSelectMomentsDataSource ()

@property (strong, nonatomic) NSMutableDictionary *momentsTitles;
@property (strong, nonatomic) NSMutableDictionary *momentsData;
@property (strong, nonatomic) NSMutableArray *momentsKeys;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;


@end

@implementation ImageSelectMomentsDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return self;
}

-(void)loadAssets {
    self.isLoading = YES;
    
    self.momentsTitles = [NSMutableDictionary new];
    self.momentsData = [NSMutableDictionary new];
    self.momentsKeys = [NSMutableArray new];
    
    PHFetchOptions* options = [PHFetchOptions new];
    //options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType: PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAny options:options];
    
    for(PHAssetCollection *collection in results) {
        NSString *key = collection.localIdentifier;

        NSString *title = collection.localizedTitle != nil ? collection.localizedTitle : [self.dateFormatter stringFromDate:collection.startDate];
        
        self.momentsTitles[key] = title;
        
        [self.momentsKeys addObject:key];
        
        PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        NSMutableArray* assets = [NSMutableArray new];
        for (PHAsset *asset in results) {
            [assets addObject:[PickerAsset makeFromPHAsset:asset]];
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

@end
