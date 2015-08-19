//
//  ImageSelect.m
//  VideoEditor2
//
//  Created by Alexander on 8/18/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectController.h"
#import "PickerAssetsCollection.h"
#import "ImageSelectCollectionViewCell.h"
#import "ImageSelectCollectionViewHeader.h"
#import "TWImageScrollView.h"

@interface ImageSelectController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet TWImageScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *gripImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPositionConstraint;

@property (nonatomic) CGFloat panGestureBeginConstant;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (strong, nonatomic) PickerAssetsCollection *data;
@property (strong, nonatomic) NSMutableDictionary *momentsData;
@property (strong, nonatomic) NSMutableArray *momentsKeys;
@end

@implementation ImageSelectController


- (instancetype)init {
    self = [super init];
    if (self) {
        self.displayInMomentsStyle =  NO;
    }
    return self;
}

-(void) loadDataFromALAssetsGroup: (ALAssetsGroup*) group {
    __weak ImageSelectController *weakSelf = self;
    
    self.data = [PickerAssetsCollection makeFromALAssetsGroup:group onLoad:^{
        [weakSelf reloadData];
    }];
}

-(void) reloadData {
    self.momentsData = nil;

    if (self.data != nil && self.collectionView != nil) {
        [self.collectionView reloadData];
    }
    
    if (self.data.count > 0) {
        [self.scrollView displayImage:[self.data getAsset:0].originalImage];
    }
    
}

-(NSMutableDictionary*) momentsData {
    if (_momentsData == nil) {
        _momentsData = [NSMutableDictionary new];
        
        for (int i =0; i < self.data.count; i++) {
            PickerAsset *asset = [self.data getAsset:i];
            
            NSDate * date = [asset.asset valueForProperty:ALAssetPropertyDate];
            NSTimeInterval timeInterval = [date timeIntervalSince1970];
            
            timeInterval = timeInterval - fmod(timeInterval, 60*60*24);
            
            NSDate *cleanDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            
            if (_momentsData[cleanDate] == nil) {
                _momentsData[cleanDate] = [NSMutableArray new];
            }
            [((NSMutableArray*) _momentsData[cleanDate]) addObject:asset];
        }
        
        _momentsKeys = [NSMutableArray arrayWithArray:[_momentsData allKeys]];
        [_momentsKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *d1 = obj1;
            NSDate *d2 = obj2;
            return [d1 compare:d2];
        }];
    }
    
    return _momentsData;
}

-(NSMutableArray*) momentsKeys{
    if (_momentsKeys == nil) {
        NSMutableDictionary *tmpVar = self.momentsData;
        assert(tmpVar.count > 0);
    }
    
    return _momentsKeys;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (IBAction)panGestureAction:(UIPanGestureRecognizer *)sender {
    CGFloat minOffset = (self.scrollView.frame.size.height -20-44) * -1;
    
    switch (sender.state) {
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (self.topPositionConstraint.constant < self.panGestureBeginConstant) {
                self.topPositionConstraint.constant = minOffset;
            } else {
                self.topPositionConstraint.constant = 0;
            }
            
            [self.view setNeedsLayout];
            
            [UIView animateWithDuration:.3f animations:^{
                [self.view layoutIfNeeded];
            }];
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            self.panGestureBeginConstant = self.topPositionConstraint.constant;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [sender translationInView:self.view];
            
            CGFloat newConstant = self.panGestureBeginConstant;
            newConstant += translation.y;
            newConstant = newConstant > 0 ? 0 : newConstant;
            newConstant = newConstant < minOffset ? minOffset : newConstant;
            
            self.topPositionConstraint.constant = newConstant;
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
            break;
        }
        default:
            break;
    }
}

-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.topPositionConstraint.constant = 0;
    [self.view setNeedsLayout];
}

- (IBAction)tapGestureAction:(UITapGestureRecognizer *)sender {

    CGFloat newTopPosition = self.topPositionConstraint.constant == 0 ? -(CGRectGetHeight(self.scrollView.bounds)-20-44) : 0;

    self.topPositionConstraint.constant = newTopPosition;
    [self.view setNeedsLayout];
    
    [UIView animateWithDuration:.3f animations:^{

        [self.view layoutIfNeeded];
    }];
}


- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)okButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.displayInMomentsStyle) {
       return [self.momentsData count];
    }
    return 1;
}

- (PickerAsset*) getAssetForIndexPath: (NSIndexPath*)indexPath {
    PickerAsset *asset = nil;
    
    if (self.displayInMomentsStyle) {
        NSMutableArray *sectionData = self.momentsData[self.momentsKeys[indexPath.section]];
        asset = sectionData[indexPath.row];
    } else {
        asset = [self.data getAsset:(int)indexPath.row];
    }
    
    return asset;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.displayInMomentsStyle) {
        NSMutableArray *sectionData = self.momentsData[self.momentsKeys[section]];
        return sectionData.count;
    }
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageSelectCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageSelectCollectionViewCell" forIndexPath:indexPath];
    PickerAsset *asset = [self getAssetForIndexPath:indexPath];
    
    cell.asset = asset;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ImageSelectCollectionViewHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ImageSelectCollectionViewHeader" forIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    header.label.text = [dateFormatter stringFromDate:self.momentsKeys[indexPath.section]];
    return header;
};

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.displayInMomentsStyle) {
        return CGSizeMake(0, 50);
    }
    
    return CGSizeMake(0, 0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PickerAsset *asset = [self getAssetForIndexPath:indexPath];
    
    [self.scrollView displayImage: asset.originalImage];
}

@end
