//
//  VInstructionStillImage.h
//  VideoEditor2
//
//  Created by Alexander on 9/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCompositionInstruction.h"

@interface VInstructionStillImage : VCompositionInstruction

@property (nonatomic, strong) CIImage* image;

@end
