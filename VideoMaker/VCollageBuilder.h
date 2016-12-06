//
//  VCollageBuilder.h
//  VideoEditor2
//
//  Created by Alexander on 10/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VProvidersCollection.h"
#import "VCollageFrame.h"
#import "CollageLayout.h"
#import "VEffect.h"

@interface VCollageBuilder : NSObject

@property (nonatomic) BOOL previewMode;

-(VProvidersCollection*) makeCollageWithItems:(NSArray<VFrameProvider*>*)items layoutFrames:(NSArray*)layoutFrames finalSize:(CGSize)finalSize;

-(CollageLayout*) makeLayoutWithFrames:(NSArray*)layoutFrames;
-(VEffect*) makeCollageItemEffect: (VFrameProvider*)collageItem;
-(VTransition*) makeTransitionBetweenFrame:(VCollageFrame*)frame1 andFrame:(VCollageFrame*)frame2;

-(BOOL)isCollageStatic;

@end
