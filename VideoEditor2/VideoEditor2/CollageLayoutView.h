//
//  CollageView.h
//  VideoEditor2
//
//  Created by Alexander on 9/11/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CollageLayoutView : UIView

//array of CGRect
@property (strong, nonatomic) NSArray* layoutRects;
//array of PickerAssets
@property (strong, nonatomic) NSArray* assets;

@end
