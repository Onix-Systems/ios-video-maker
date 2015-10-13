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
@property (strong) NSArray<NSValue *>* frames;
+(CollageLayout*)layoutWithFrames:(NSArray<NSValue *>*) frames;

-(CGFloat) getLayoutWidth;
-(CGFloat) getLayoutHeight;
-(NSArray*) getLayoutFramesForSize: (CGSize) finalSize;

@end
