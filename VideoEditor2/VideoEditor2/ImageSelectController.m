//
//  ImageSelect.m
//  VideoEditor2
//
//  Created by Alexander on 8/18/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectController.h"
#import "ImageSelectCollectionViewCell.h"
#import "ImageSelectCollectionViewHeader.h"
#import "ImageSelectCollectionViewFooter.h"
#import "ImageSelectPlayerView.h"
#import "ImageSelectScrollView.h"

#import "DZNPhotoServiceFactory.h"
#import "DZNPhotoTag.h"

@interface ImageSelectController () <UICollectionViewDataSource, UICollectionViewDelegate, ImageSelectCollectionViewCellDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPositionConstraint;

@property (weak, nonatomic) IBOutlet ImageSelectPlayerView*videoPlayerView;
@property (weak, nonatomic) IBOutlet ImageSelectScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *gridImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gripImageView;

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchTagsList;
@property (strong, nonatomic) NSTimer *searchTimer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) CGFloat panGestureBeginConstant;

@property (strong, nonatomic) BaseImageSelectDataSource *dataSource;

@end

@implementation ImageSelectController

-(void) loadDataFromDataSource: (BaseImageSelectDataSource*) dataSource {
    self.dataSource = dataSource;
    
    __weak ImageSelectController *weakSelf = self;
    
    self.dataSource.didFinishLoading = ^(NSError* error){
        [weakSelf reloadData];
    };
    
    if (self.dataSource.supportSearch) {
        self.searchBar = [UISearchBar new];
        self.searchBar.delegate = self;
        self.searchBar.text = self.dataSource.getCurrentSearchTerm;
        
        NSArray* searchScopes = [self.dataSource getSeachScopes];
        if (searchScopes.count > 1) {
            self.searchBar.scopeButtonTitles = searchScopes;
        }
        
        [self.searchBar sizeToFit];
        [self.collectionView.collectionViewLayout invalidateLayout];

        self.searchBar.showsScopeBar = NO;
        [self.searchBar sizeToFit];
        [self.collectionView.collectionViewLayout invalidateLayout];
        
        self.searchTagsList = [NSMutableArray new];
    }
    [self.dataSource loadAssets];
}

-(void) reloadData {
    if (self.dataSource != nil && self.collectionView != nil) {
        [self.collectionView reloadData];
    }
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.definesPresentationContext = YES;
    
    self.searchResultsTableView.dataSource = self;
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.hidden = YES;
    
    [self setActivityIndicatorsVisible: NO];
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
    if (self.searchBar != nil) {
        [self.searchBar sizeToFit];
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
    [self.view setNeedsLayout];
}

- (IBAction)tapGestureAction:(UITapGestureRecognizer *)sender {
    [self scrollTopViewToTop: (self.topPositionConstraint.constant == 0)];
}

-(void) scrollTopViewToTop: (BOOL) toTop {
    CGFloat newTopPosition = toTop ? -(CGRectGetHeight(self.scrollView.bounds)-20-44) : 0;
    
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

-(BOOL)hasSections {
    return self.dataSource != nil && [self.dataSource getNumberofSectionsInData] > 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self hasSections]) {
       return [self.dataSource getNumberofSectionsInData];
    }
    return 1;
}

- (PickerAsset*) getAssetForIndexPath: (NSIndexPath*)indexPath {
    PickerAsset *asset = nil;
    
    if ([self hasSections]) {
        id sectionKey = [self.dataSource getSectionsKeys][indexPath.section];
        NSMutableArray *sectionData = [self.dataSource getAssetsBySections][sectionKey];
        asset = sectionData[indexPath.row];
    } else {
        asset = self.dataSource.assets[indexPath.row];
    }
    
    return asset;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self hasSections]) {
        id sectionKey = [self.dataSource getSectionsKeys][section];
        NSMutableArray *sectionData = [self.dataSource getAssetsBySections][sectionKey];
        return sectionData.count;
    }
    return self.dataSource.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageSelectCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageSelectCollectionViewCell" forIndexPath:indexPath];
    PickerAsset *asset = [self getAssetForIndexPath:indexPath];
    
    cell.asset = asset;
    cell.delegate = self;
    
    return cell;
}

- (void) assetWasUnselected {
    __weak ImageSelectController *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.collectionView reloadData];
    });
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        ImageSelectCollectionViewHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ImageSelectCollectionViewHeader" forIndexPath:indexPath];
    
        if ([self hasSections]) {
            header.label.text = [self.dataSource getSectionTitle:([self.dataSource getSectionsKeys][indexPath.section])];
        } else if (self.dataSource.supportSearch) {
            header.label.text = @"";
        
            [header addSubview:self.searchBar];
            [self.searchBar sizeToFit];
        
        }
        return header;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        ImageSelectCollectionViewFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ImageSelectCollectionViewFooter" forIndexPath:indexPath];
        
        [footer hideButton];
        
        if (self.dataSource.supportSearch) {
            if (self.dataSource.assets.count > 0) {
                [footer showLoadMore];
            } else {
                [footer showNoPhotosFound];
            }
        }
        return footer;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([self hasSections]) {
        return CGSizeMake(0, 50);
    } else if (self.dataSource.supportSearch) {
        return CGSizeMake(0, self.searchBar.frame.size.height);
    }
    
    return CGSizeMake(0, 0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PickerAsset *asset = [self getAssetForIndexPath:indexPath];
    
    if (asset.isVideo) {
        self.videoPlayerView.hidden = NO;
        self.scrollView.hidden = YES;
        self.gridImageView.hidden = YES;
        
        [self.videoPlayerView playVideoFromURL:[asset getURL]];
        
    } else {
        self.videoPlayerView.hidden = YES;
        self.scrollView.hidden = NO;
        self.gridImageView.hidden = NO;
        
        UIImage* image = asset.originalImage;
        if (image != nil) {
            [self.scrollView displayImage: asset.originalImage];
        } else {
            [self.scrollView displayImageFromURL: [asset getURL]];
        }
    }
}

- (void) hideSearchControls {
    self.searchResultsTableView.hidden = YES;
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = [self.dataSource getCurrentSearchTerm];
    self.searchBar.showsScopeBar = NO;
    [self.searchBar sizeToFit];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void) startSearch: (NSString* ) searchTerm {
    [self hideSearchControls];
    self.searchBar.text = searchTerm;

    [self setActivityIndicatorsVisible: YES];
    
    [self.dataSource searchFor:searchTerm withCompletion:^(NSError* error){
        [self setActivityIndicatorsVisible: NO];
        [self.collectionView reloadData];
        if (error != nil) {
            [self setLoadingError:error];
        }
    }];
}

- (IBAction)loadMoreAction:(UIButton *)sender {
    if (!self.dataSource.isLoading) {
        [self setActivityIndicatorsVisible: YES];
        [self.dataSource loadMore:^(NSError *error) {
            [self setActivityIndicatorsVisible: NO];
            [self.collectionView reloadData];
            if (error != nil) {
                [self setLoadingError:error];
            }
        }];
    }
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setActivityIndicatorsVisible: NO];
    [self scrollTopViewToTop:YES];
    
    if (self.searchBar.scopeButtonTitles.count > 1) {
        self.searchBar.showsScopeBar = YES;
        self.searchBar.selectedScopeButtonIndex = [self.dataSource selectedSearchScope];
    }
    [self.searchBar sizeToFit];
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.searchBar.showsCancelButton = YES;
    
    [self.searchTagsList removeAllObjects];
    [self.searchResultsTableView reloadData];
    [self.searchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchResultsTableView.hidden = NO;
    
    NSString *term = searchBar.text;
    if (term.length <= 2) {
        return;
    }

    if ([self.searchBar isFirstResponder] && term.length > 2) {
        
        [self resetSearchTimer];
        
        _searchTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(searchTag:) userInfo:@{@"term": term} repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_searchTimer forMode:NSDefaultRunLoopMode];
        
    } else {
        [self.searchTagsList removeAllObjects];
        [self.searchResultsTableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self startSearch:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hideSearchControls];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self.dataSource switchSearhcScope:selectedScope];
    [self startSearch:searchBar.text];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchTagsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultsCell"];
    NSString *text = @"";
    
    if (indexPath.row < self.searchTagsList.count) {
        
        DZNPhotoTag *tag = [self.searchTagsList objectAtIndex:indexPath.row];
        
        if (self.searchTagsList.count == 1) text = [NSString stringWithFormat:NSLocalizedString(@"Search for \"%@\"", nil), tag.term];
        else text = tag.term;
    }
    
    cell.textLabel.text = text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoTag *tag = self.searchTagsList[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self startSearch: tag.term];
}


/*
 Invalidates and nullifys the search timer.
 */
- (void)resetSearchTimer
{
    if (_searchTimer) {
        [_searchTimer invalidate];
        _searchTimer = nil;
    }
}

/*
 Triggers a tag search when typing more than 2 characters in the search bar.
 This allows auto-completion and related tags to what the user wants to search.
 */
- (void)searchTag:(NSTimer *)timer
{
    NSString *term = [timer.userInfo objectForKey:@"term"];
    [self resetSearchTimer];
    
    id <DZNPhotoServiceClientProtocol> client = [[DZNPhotoServiceFactory defaultFactory] clientForService:DZNPhotoPickerControllerServiceFlickr];
    
    if (!client) {
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [client searchTagsWithKeyword:term completion:^(NSArray *list, NSError *error) {
        if (error) {
            [self setLoadingError:error];
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            [self.searchTagsList removeAllObjects];
            
            [self.searchTagsList addObjectsFromArray:list];
            
            if (self.searchTagsList.count == 1) {
                [self.searchTagsList removeAllObjects];
                
                DZNPhotoTag *tag = [DZNPhotoTag newTagWithTerm:self.searchBar.text service:DZNPhotoPickerControllerService500px];
                [self.searchTagsList addObject:tag];
            }
            
            [self.searchResultsTableView reloadData];
        }

    }];
}

/*
 Sets the request errors with an alert view.
 */
- (void)setLoadingError:(NSError *)error
{
    switch (error.code) {
        case NSURLErrorTimedOut:
        case NSURLErrorUnknown:
        case NSURLErrorCancelled:
            return;
    }
    
    [self setActivityIndicatorsVisible:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}

/*
 Toggles the activity indicators on the status bar & footer view.
 */
- (void)setActivityIndicatorsVisible:(BOOL)visible
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
    
    if (visible) {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        //self.loadButton.hidden = YES;
    }
    else {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        //self.loadButton.hidden = NO;
        //self.loadButton.enabled = YES;
    }
    
    //_loading = visible;
}



@end
