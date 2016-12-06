
#import "VEButton.h"

@interface VEButton()

@property (strong, nonatomic) UIColor *labelTextColor;

@end

@implementation VEButton

- (void)setEnabledWithAplha:(BOOL)enabled {
    CGFloat alpha = 1;
    if(!enabled) {
        alpha = 0.3;
    }
    self.label.alpha = alpha;
    self.picture.alpha = alpha;
    [UIView animateWithDuration:0.3 animations:^{
        self.enabled = enabled;
    }];
}

- (instancetype)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    self = [super awakeAfterUsingCoder:aDecoder];
    if(self){
        [self addTarget:self action:@selector(touchBegin) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchEnded) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchEndedOutside) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(touchEndedOutside) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(touchEndedOutside) forControlEvents:UIControlEventTouchCancel];
    }
    return self;
}

- (void)touchBegin{
    [UIView animateWithDuration:0.1 animations:^{
        self.label.alpha = 0.5;
        self.picture.alpha = 0.5;
        for (UIView *view in self.pictures) {
            view.alpha = 0.5;
        }
    }];
}

- (void)touchEnded{
    [UIView animateWithDuration:0.15 animations:^{
        self.label.alpha = 1;
        self.picture.alpha = 1;
        for (UIView *view in self.pictures) {
            view.alpha = 1;
        }
    }];
}

- (void)touchEndedOutside{
    [UIView animateWithDuration:0.15 animations:^{
        self.label.alpha = 1;
        self.picture.alpha = 1;
        for (UIView *view in self.pictures) {
            view.alpha = 1;
        }
    }];
}

@end
