//
//  CollageLayoutSelectorView.h
//  VideoEditor2
//
//  Created by Alexander on 9/11/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CollageLayout.h"
#import "CollageLayoutView.h"

#import "DMPagingScrollView.h"

@protocol CollageLayoutSelectorViewDelegate

-(void) collageLayoutSelectorGotSelectedLayout: (CollageLayoutView*) collageLayoutView;

@end

@interface CollageLayoutSelectorView : DMPagingScrollView

@property (weak, nonatomic) id<CollageLayoutSelectorViewDelegate> collageLayoutSelectorDelegate;

-(void) cleanExisitngCoollageLayoutViews;
-(void) addCoollageLayoutViewForCollageLaout: (CollageLayout*)collageLayout withAssetsCollection: (AssetsCollection*) assetsCollection;
-(NSArray*)getCollageLayoutViews;

-(NSInteger) getCurrentPageNo;
-(void) setCurrentPageNo: (NSInteger) currentPage;

-(void)willStartResizing;
-(void)didFinishedResizing;

@end
