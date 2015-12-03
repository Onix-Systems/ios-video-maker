//
//  ImageSelectDZNDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectDZNDataSource.h"
#import "DZNPhotoMetadata.h"
#import "DZNPhotoServiceFactory.h"
#import "VAssetWebImage.h"

@interface ImageSelectDZNDataSource ()

@property (strong, nonatomic) NSString* currentSearchTerm;
@property (strong, nonatomic) NSArray* seachScopes;
@property (nonatomic) NSInteger selectedSearchScope;
@property (nonatomic) NSInteger currentPage;

@property (nonatomic, strong) NSMutableArray* mutableAssetsList;

@end

@implementation ImageSelectDZNDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supportSearch = YES;
        self.currentSearchTerm = @"";
        self.selectedSearchScope = 0;
        self.resultPerPage = 20;
        self.mutableAssetsList = [NSMutableArray new];
        self.isLoading = NO;
    }
    return self;
}

-(NSArray*) getAssets {
    return self.mutableAssetsList;
}

-(void)loadAssets
{
    [self searchFor: self.initialSearchTerm withCompletion:self.didFinishLoading];
}

-(DZNPhotoPickerControllerServices)selectedService
{
    return DZNPhotoServiceFromName([self getSeachScopes][self.selectedSearchScope]);
}
-(id<DZNPhotoServiceClientProtocol>)selectedServiceClient
{
    return [[DZNPhotoServiceFactory defaultFactory] clientForService:self.selectedService];
}

- (void)searchFor:(NSString *)searchTerm withCompletion:(PickerAssetLoadCompletionBlock)onLoad
{
    self.currentSearchTerm = searchTerm;
    self.currentPage = 0;
    self.mutableAssetsList = [NSMutableArray new];
    
    [self loadMore:onLoad];
}

-(void)loadMore: (PickerAssetLoadCompletionBlock) onLoad {
    self.isLoading = YES;
    self.currentPage++;
    
    [self.selectedServiceClient searchPhotosWithKeyword:self.currentSearchTerm page:self.currentPage resultPerPage:self.resultPerPage completion:^(NSArray *list, NSError *error) {
        
        if (list) {
            DZNPhotoMetadata* metaData = nil;
            for (metaData in list) {
                [self.mutableAssetsList addObject:[VAssetWebImage makeFromDZNMetaData:metaData]];
            }
        }
        
        self.isLoading = NO;
        onLoad(error);
    }];
};

- (NSString*) getCurrentSearchTerm
{
    return [self.currentSearchTerm isEqual:@""] ? self.initialSearchTerm : self.currentSearchTerm;
}

-(NSArray*) getSeachScopes
{
    if (self.seachScopes == nil) {
        self.seachScopes = NSArrayFromServices(self.supportedServices);
    }
    
    return self.seachScopes;
}

-(NSInteger) selectedSearchScope
{
    return _selectedSearchScope;
}

-(void) switchSearhcScope: (NSInteger) searchScope
{
    self.selectedSearchScope = searchScope;
}


-(VAsset*) getAssetWithID:(NSString*)assetID
{
    for (NSInteger i = 0; i < self.mutableAssetsList.count; i++) {
        VAsset* asset = self.mutableAssetsList[i];
        if ([[asset getIdentifier] isEqualToString:assetID]) {
            return asset;
        }
    }
    return nil;
}

@end
