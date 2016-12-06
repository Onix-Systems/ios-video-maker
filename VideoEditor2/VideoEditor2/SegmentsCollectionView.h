//
//  SegmentsCollectionView.h
//  VideoEditor2
//
//  Created by Alexander on 11/4/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "VSegmentsCollection.h"

@interface SegmentsCollectionView : UIView

@property (weak, nonatomic) VSegmentsCollection* segmentsCollection;

@end
