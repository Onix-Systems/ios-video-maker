//
//  TimePionter.m
//  VideoEditor2
//
//  Created by Alexander on 11/5/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "TimePionter.h"

@interface TimePionter()

@property (nonatomic, strong) UIImage* timePointer;

@end

@implementation TimePionter

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup
{
    self.timePointer = [UIImage imageNamed:@"timePointer"];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    self.backgroundColor = [UIColor clearColor];
    
    CGContextClearRect(context, self.bounds);
    
    CGContextSetRGBFillColor(context, 0x9e/255.0, 0x0b/255.0, 0x0f/255.0, 1.0);
    
    double lineWidth = 2;
    CGContextFillRect(context, CGRectMake((self.bounds.size.width/2.0) - (lineWidth/2.0), 0, lineWidth, self.bounds.size.height));
    
    
    double pointerWidth = self.timePointer.size.width;
    double pointerHeight = self.timePointer.size.height;
    
    [self.timePointer drawInRect:CGRectMake((self.bounds.size.width/2.0) - (pointerWidth/2.0), 0, pointerWidth, pointerHeight)];
}

@end
