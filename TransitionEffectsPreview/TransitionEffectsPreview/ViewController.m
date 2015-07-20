//
//  ViewController.m
//  TransitionEffectsPreview
//
//  Created by Alexander on 19.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "ViewController.h"
#import "Transition.h"

@interface ViewController ()

@property (weak) UIButton *imageButton1;
@property (weak) UIButton *imageButton2;

@property (weak, nonatomic) IBOutlet UIImageView *selectedImage1;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage2;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;

@property (weak, nonatomic) IBOutlet UISlider *frameSlider;
@property NSInteger frameSliderCurrentValue;

@property (weak, nonatomic) IBOutlet UISlider *filterSlider;
@property NSInteger filterSliderCurrentValue;

@property (weak, nonatomic) IBOutlet UILabel *frameLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;


@property Transition *transition;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSArray *validNames = [Transition filterNames];
    self.transition = [[Transition new] initForFilter:validNames[0]];
    self.filterLabel.text = [NSString stringWithFormat: @"Filter: %@", validNames[0]];
    
    self.filterSlider.value = 0;
    self.filterSlider.minimumValue = 0;
    self.filterSlider.maximumValue = validNames.count - 1;
    self.filterSliderCurrentValue = 0;
    
    self.frameSlider.value = 0;
    self.frameSlider.minimumValue = 0;
    self.frameSlider.maximumValue = self.transition.numberOfFrames - 1;
    self.frameSliderCurrentValue = 0;
    self.frameLabel.text = [NSString stringWithFormat: @"Frame: %ld of %ld", (long)self.frameSliderCurrentValue, (long)self.transition.numberOfFrames];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) setTransitionFromImage:(UIImage*) from {
    if (from != nil) {
        self.selectedImage1.image = from;
        
        self.transition.from = [CIImage imageWithCGImage:from.CGImage];
    }
}

-(void) setTransitionToImage:(UIImage*) to {
    if (to != nil) {
        self.selectedImage2.image = to;
        
        self.transition.to = [CIImage imageWithCGImage:to.CGImage];
    }
}

-(void) drawCurrentTransitionFrame {
    self.frameLabel.text = [NSString stringWithFormat: @"Frame: %ld of %ld", (long)self.frameSliderCurrentValue+1, (long)self.transition.numberOfFrames];
    self.previewImage.image = [self.transition getImageNo:self.frameSliderCurrentValue];
    [self.previewImage setNeedsDisplay];
}

- (IBAction)imageSelected:(id)sender {
    if (self.imageButton1 != nil && self.imageButton2 != nil) {
        self.imageButton1.selected = NO;
        self.imageButton1.alpha = 0.3;
        self.imageButton1 = nil;
        self.selectedImage1.image = nil;
        
        self.imageButton2.selected = NO;
        self.imageButton2.alpha = 0.3;
        self.imageButton2 = nil;
        self.selectedImage2.image = nil;
    }
    
    if (self.imageButton1 == nil && self.imageButton2 == nil) {
        self.imageButton1 = sender;
        self.imageButton1.selected = YES;
        self.imageButton1.alpha = 1;
        
        [self setTransitionFromImage:self.imageButton1.imageView.image];
    } else {
        self.imageButton2 = sender;
        self.imageButton2.selected = YES;
        self.imageButton2.alpha = 1;
        
        [self setTransitionToImage:self.imageButton2.imageView.image];
        
        [self drawCurrentTransitionFrame];
    }
}

- (IBAction)frameSliderChanged {
    NSInteger value = lround(self.frameSlider.value);
    
    if (value != self.frameSliderCurrentValue) {
        self.frameSliderCurrentValue = value;
        
        [self drawCurrentTransitionFrame];
    }
}


- (IBAction)filterSliderChanged {
    NSInteger value = lround(self.filterSlider.value);
    if (value != self.filterSliderCurrentValue) {
        self.filterSliderCurrentValue = value;
        
        NSArray *validNames = [Transition filterNames];
        self.transition = [[Transition new] initForFilter:validNames[self.filterSliderCurrentValue]];
        self.filterLabel.text = [NSString stringWithFormat: @"Filter: %@", validNames[self.filterSliderCurrentValue]];
        
        [self setTransitionFromImage:self.selectedImage1.image];
        [self setTransitionToImage:self.selectedImage2.image];
        
        [self drawCurrentTransitionFrame];
    }
}

@end
