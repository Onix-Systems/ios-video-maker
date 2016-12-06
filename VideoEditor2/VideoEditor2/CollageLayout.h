//
//  CollageLayout.h
//  VideoEditor2
//
//  Created by Alexander on 9/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CollageLayout : NSObject

//array fo CGRect
@property (nonatomic, strong) NSArray<NSValue *>* frames;
-(void)setFrames:(NSArray<NSValue *> *)frames;

-(CGFloat) getLayoutWidth;
-(CGFloat) getLayoutHeight;

-(NSArray*) getStillFramesForFinalSize:(CGSize)finalSize;
-(NSArray*) getFramesForFinalSize:(CGSize)finalSize andTime:(double)time;

@end
