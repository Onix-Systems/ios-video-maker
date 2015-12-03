//
//  BasePickerAssetsDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "BaseImageSelectDataSource.h"
#import "VAsset.h"

@implementation BaseImageSelectDataSource

-(void)loadAssets
{
    
}

-(NSArray *) getAssets
{
    return nil;
}

-(NSInteger)getAssetsCount
{
    return 0;
}

-(VAsset*) getAssetatIndex:(NSInteger)index {
    return nil;
}

-(NSInteger)numberofSectionsInData
{
    return 0;
}

-(NSInteger)getNumberofSectionsInData
{
    return 0;
}

-(NSDictionary*) getAssetsBySections
{
    return nil;
}

-(NSArray*) getSectionsKeys
{
    return nil;
}

-(NSString*) getSectionTitle: (id) sectionKey
{
    return nil;
}

-(void)searchFor: (NSString*) searchTerm withCompletion: (PickerAssetLoadCompletionBlock) onLoad
{
    
}

-(void)loadMore: (PickerAssetLoadCompletionBlock) onLoad
{
    
}

-(NSString*) getCurrentSearchTerm
{
    return nil;
}

-(NSArray*) getSeachScopes
{
    return nil;
}

-(NSInteger) selectedSearchScope
{
    return 0;
}

-(void) switchSearhcScope: (NSInteger) searchScope
{
    
}

-(NSArray<NSIndexPath *>*)getBatchUpdateRemovedIndexes
{
    return nil;
}

-(NSArray<NSIndexPath *>*)getBatchUpdateInsertedIndexes
{
    return nil;
}

-(NSArray<NSIndexPath *>*)getBatchUpdateChangedIndexes
{
    return nil;
}

-(NSIndexSet*)getBatchUpdateRemovedSections
{
    return nil;
}

-(NSIndexSet*)getBatchUpdateInsertedSections
{
    return nil;
}

-(NSIndexSet*)getBatchUpdateChangedSections
{
    return nil;
}

@end
