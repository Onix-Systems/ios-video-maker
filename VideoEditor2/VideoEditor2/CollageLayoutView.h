//
//  CollageView.h
//  VideoEditor2
//
//  Created by Alexander on 9/11/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CollageLayout.h"
#import "AssetsCollection.h"

@class CollageLayoutView;
@protocol CollageLayoutViewDelegate

-(void) collageLayoutViewTouchUpInsideAction: (CollageLayoutView*) collageLayoutView;

@end

@interface CollageLayoutView: UIView

//array of CGRect
@property (strong, nonatomic) CollageLayout* collageLayout;
//array of PickerAssets
@property (strong, nonatomic) AssetsCollection* assetsCollection;

@property (weak, nonatomic) id<CollageLayoutViewDelegate> delegate;

@end
