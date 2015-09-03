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

-(void)parseAssets {
    if ((self.momentsData != nil) && (self.momentsKeys != nil)) {
        return;
    }
    
    self.momentsData = [NSMutableDictionary new];
    
    for (int i =0; i < self.assets.count; i++) {
        PickerAsset *asset = self.assets[i];
        
        NSDate* date = [asset getDate];
        NSTimeInterval timeInterval = [date timeIntervalSince1970];
        
        timeInterval = timeInterval - fmod(timeInterval, 60*60*24);
        
        NSDate *cleanDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        if (self.momentsData[cleanDate] == nil) {
            self.momentsData[cleanDate] = [NSMutableArray new];
        }
        [((NSMutableArray*) self.momentsData[cleanDate]) addObject:asset];
    }
    
    self.momentsKeys = [NSMutableArray arrayWithArray:[self.momentsData allKeys]];
    
    [self.momentsKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *d1 = obj1;
        NSDate *d2 = obj2;
        return [d1 compare:d2];
    }];
}

-(NSInteger)getNumberofSectionsInData {
    [self parseAssets];
    return self.momentsKeys.count;
}

-(NSDictionary*) getAssetsBySections {
    [self parseAssets];
    return self.momentsData;
}

-(NSArray*) getSectionsKeys {
    [self parseAssets];
    return self.momentsKeys;
}

-(NSString*) getSectionTitle: (id) sectionKey {
    NSDate *date = sectionKey;

    return [self.dateFormatter stringFromDate:date];
}

-(NSMutableDictionary*) momentsData {
    if (_momentsData == nil) {

    }
    
    return _momentsData;
}

@end
