//
//  CollageLayout.m
//  VideoEditor2
//
//  Created by Alexander on 9/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "CollageLayout.h"

@implementation CollageLayout

+(CollageLayout*)layoutWithFrames:(NSArray*) frames
{
    CollageLayout* layout = [CollageLayout new];
    layout.frames = frames;
    
    return layout;
}

@end
