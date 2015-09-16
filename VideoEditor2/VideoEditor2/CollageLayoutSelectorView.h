//
//  CollageLayoutSelectorView.h
//  VideoEditor2
//
//  Created by Alexander on 9/11/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DMPagingScrollView.h"

@interface CollageLayoutSelectorView : DMPagingScrollView

-(void) addCoollageLayout: (NSArray*)layoutRects;
-(NSArray*)getLayouts;

-(NSInteger) getCurrentPageNo;
-(void) setCurrentPageNo: (NSInteger) currentPage;

-(void)willStartResizing;
-(void)didFinishedResizing;

@end
