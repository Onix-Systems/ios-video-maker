
#import <UIKit/UIKit.h>

@interface VEButton : UIButton

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *pictures;

//used for subclasses. Do not call it directly.
- (void)touchEnded;

@end
