//
//  CollageLayoutViewPlusBadge.m
//  VideoEditor2
//
//  Created by Alexander on 9/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "CollageLayoutViewPlusBadge.h"

@interface CollageLayoutViewPlusBadge ()

@property (nonatomic, strong) UILabel* selectionLabel;

@end

@implementation CollageLayoutViewPlusBadge

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup
{
    self.contentMode = UIViewContentModeCenter;
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 1;
    self.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.layer.cornerRadius = self.bounds.size.height / 2;
    
    self.selectionLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.selectionLabel.textColor = [UIColor whiteColor];
    self.selectionLabel.backgroundColor = [UIColor clearColor];
    self.selectionLabel.opaque = NO;
    self.selectionLabel.textAlignment = NSTextAlignmentCenter;
    self.selectionLabel.font = [self.selectionLabel.font fontWithSize: 12];

    self.selectionLabel.text = @"+";
    
    [self addSubview:self.selectionLabel];
}


@end
