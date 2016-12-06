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

@interface CollageLayoutSelectorView : UIScrollView

@property (weak, nonatomic) id<CollageLayoutSelectorViewDelegate> collageLayoutSelectorDelegate;

@property (weak, nonatomic) AssetsCollection* assetsCollection;

-(void) cleanExisitngCoollageLayoutViews;
-(void) addCoollageLayoutViewForCollageLayout: (CollageLayout*)collageLayout;
-(NSArray*)getCollageLayoutViews;

-(NSInteger) getCurrentPageNo;
-(void) setCurrentPageNo: (NSInteger) currentPage;

-(void)willStartResizing;
-(void)didFinishedResizing;

@end
