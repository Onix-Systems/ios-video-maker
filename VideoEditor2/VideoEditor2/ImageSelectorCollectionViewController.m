//
//  ImageSelectCollectionViewController.m
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorCollectionViewController.h"
#import "ImageSelectorSplitController.h"

#import "ImageSelectorCollectionViewCell.h"
#import "ImageSelectorCollectionViewHeader.h"
#import "ImageSelectorCollectionViewFooter.h"

#import "DZNPhotoServiceFactory.h"
#import "DZNPhotoTag.h"

@interface ImageSelectorCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *noSearchResultsView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchTagsList;
@property (strong, nonatomic) NSTimer *searchTimer;

@property (nonatomic) BOOL firstAssetDisplayed;

@property (strong, nonatomic) BaseImageSelectDataSource *dataSource;

@property (strong,readwrite) VAsset* lastActiveAsset;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchResultsTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noSearchResultsTopConstraint;

@end

@implementation ImageSelectorCollectionViewController

-(void)subscribeToDataSourceNotifictions
{
    if (self.dataSource != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batchUpdateFromDataSource:) name:kImageSelectDataSourceHasBatchChanges object:self.dataSource];
    }
}

-(void)unsubscribeToDataSourceNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageSelectDataSourceHasBatchChanges object:self.dataSource];
}

- (void)dealloc
{
    [self unsubscribeToDataSourceNotifications];
}

-(ImageSelectorSplitController*) getSplitController
{
    if (self.parentViewController != nil && [self.parentViewController isKindOfClass:[ImageSelectorSplitController class]]) {
        return (ImageSelectorSplitController*)self.parentViewController;
    }
    return nil;
}

-(void) displayAsset: (VAsset*) asset autoPlay: (BOOL) autoPlay
{
    ImageSelectorSplitController* splitController = [self getSplitController];
    if (splitController != nil) {
        [splitController displayAssetPreview: asset autoPlay:autoPlay];
    }
}


-(void) batchUpdateFromDataSource:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView performBatchUpdates:^{
            
            NSArray<NSIndexPath *>* removedIndexes = [self.dataSource getBatchUpdateRemovedIndexes];
            if ((removedIndexes != nil) && ([removedIndexes count] > 0)) {
                [self.collectionView deleteItemsAtIndexPaths:removedIndexes];
            }
            
            NSIndexSet* removedSections = [self.dataSource getBatchUpdateRemovedSections];
            if ((removedSections != nil) && (removedSections.count > 0)) {
                [self.collectionView deleteSections:removedSections];
            }
            
            NSIndexSet* insertedSections = [self.dataSource getBatchUpdateInsertedSections];
            if ((insertedSections != nil) && (insertedSections.count > 0)) {
                [self.collectionView insertSections:insertedSections];
            }
            
            NSArray<NSIndexPath *>* insertedIndexes = [self.dataSource getBatchUpdateInsertedIndexes];
            if ((insertedIndexes != nil) && ([insertedIndexes count] > 0)) {
                [self.collectionView insertItemsAtIndexPaths:insertedIndexes];
            }
            
            NSArray<NSIndexPath *>* changedIndexes = [self.dataSource getBatchUpdateChangedIndexes];
            if ((changedIndexes != nil) && ([changedIndexes count] > 0)) {
                [self.collectionView reloadItemsAtIndexPaths:changedIndexes];
            }
            
            NSIndexSet* changedSections = [self.dataSource getBatchUpdateInsertedSections];
            if ((changedSections != nil) && (changedSections.count > 0)) {
                [self.collectionView reloadSections:changedSections];
            }
            
        } completion:^(BOOL finished) {
            
        }];
    });
}

-(void) loadDataFromDataSource: (BaseImageSelectDataSource*) dataSource {
    self.lastActiveAsset = nil;
    NSLog(@"Set lastActiveAsset=nil");
    
    [self unsubscribeToDataSourceNotifications];
    self.dataSource = dataSource;
    [self subscribeToDataSourceNotifictions];
    
    self.firstAssetDisplayed = NO;
    
    __weak ImageSelectorCollectionViewController *weakSelf = self;
    
    self.dataSource.didFinishLoading = ^(NSError* error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadData];
        });
    };
    
    [self.dataSource loadAssets];
}

-(void) reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dataSource != nil && self.collectionView != nil) {
            [self.collectionView reloadData];
            
            NSArray* assets = [self.dataSource getAssets];
            
            if (!self.firstAssetDisplayed) {
                VAsset* firstAsset = nil;
                if (assets.count > 0) {
                    firstAsset = assets[0];
                } else if ([self.dataSource getNumberofSectionsInData] > 0) {
                    NSArray *sectionData = [self.dataSource getAssetsBySections][0];
                    if (sectionData.count > 0) {
                        firstAsset = sectionData[0];
                    }
                }
                if (firstAsset != nil) {
                    self.firstAssetDisplayed = YES;
                    self.lastActiveAsset = firstAsset;
                    NSLog(@"Set lastActiveAsset=firstAsset(%@)", [firstAsset getIdentifier]);
                    [self displayAsset:firstAsset autoPlay:NO];
                }
            }
            
            if (assets.count > 0 || [self.dataSource getNumberofSectionsInData] > 0) {
                self.noSearchResultsView.hidden = YES;
                [self setActivityIndicatorsVisible:NO];
                
            } else {
                if (self.dataSource.isLoading) {
                    self.noSearchResultsView.hidden = YES;
                    [self setActivityIndicatorsVisible:YES];
                } else {
                    self.noSearchResultsView.hidden = NO;
                    [self setActivityIndicatorsVisible:NO];
                }
            }
        }
    });
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    if (self.dataSource.supportSearch) {
        self.searchBar = [UISearchBar new];
        self.searchBar.delegate = self;
        self.searchBar.text = self.dataSource.getCurrentSearchTerm;
        self.searchBar.barTintColor = [UIColor colorWithRed:0x2d/255.0 green:0x2c/255.0 blue:0x2a/255.0  alpha:0xff/255.0];
        
        if (self.searhBarFieldBackgroundImage == nil) {
            CIImage* image = [CIImage imageWithColor:[CIColor colorWithRed:0x6f/255.0 green:0x6f/255.0 blue:0x6d/255.0]];
            CIContext* context = [CIContext contextWithOptions:nil];
            
            self.searhBarFieldBackgroundImage = [UIImage imageWithCGImage:[context createCGImage:image fromRect:CGRectMake(0, 0, 100, 100)]];
        }
        //[self.searchBar setSearchFieldBackgroundImage:self.searhBarFieldBackgroundImage forState:UIControlStateNormal];
        
        NSArray* searchScopes = [self.dataSource getSeachScopes];
        if (searchScopes.count > 1) {
            self.searchBar.scopeButtonTitles = searchScopes;
            
            self.searchResultsTopConstraint.constant = 88;
            self.noSearchResultsTopConstraint.constant = 88;
        } else {
            self.searchResultsTopConstraint.constant = 44;
            self.noSearchResultsTopConstraint.constant = 44;
        }
        
        self.searchBar.showsScopeBar = NO;
        [self.searchBar sizeToFit];
        [self.collectionView.collectionViewLayout invalidateLayout];
        
        self.searchTagsList = [NSMutableArray new];
        
        [self.view setNeedsLayout];
    }
    
    self.noSearchResultsView.hidden = YES;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self reloadData];
    
    self.definesPresentationContext = YES;
    
    self.searchResultsTableView.dataSource = self;
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.hidden = YES;
}

-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (self.searchBar != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchBar sizeToFit];
        });
    }
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

- (VAsset*) getAssetForIndexPath: (NSIndexPath*)indexPath {
    VAsset *asset = nil;
    
    if ([self hasSections]) {
        NSArray *sectionData = [self.dataSource getAssetsBySections][indexPath.section];
        asset = sectionData[indexPath.row];
    } else {
        NSArray* assets = [self.dataSource getAssets];
        
        if (indexPath.row < assets.count) {
            asset = assets[indexPath.row];
        }
    }
    
    return asset;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self hasSections]) {
        NSArray *sectionData = [self.dataSource getAssetsBySections][section];
        return sectionData.count;
    }
    NSInteger count = [self.dataSource getAssets].count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageSelectorCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageSelectorCollectionViewCell" forIndexPath:indexPath];
    VAsset *asset = [self getAssetForIndexPath:indexPath];
    
    [cell setAsset:asset withSelectionStorage: self.selectionStorage];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        ImageSelectorCollectionViewHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ImageSelectorCollectionViewHeader" forIndexPath:indexPath];

        if ([self hasSections]) {
            header.label.text = [self.dataSource getSectionTitle:indexPath.section];
        } else if (self.dataSource.supportSearch) {
            header.label.text = @"";
            
            [header addSubview:self.searchBar];
            
            [self.searchBar sizeToFit];
            
        }
        return header;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        ImageSelectorCollectionViewFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ImageSelectorCollectionViewFooter" forIndexPath:indexPath];
        
        [footer hideButton];
        
        if (self.dataSource.supportSearch) {
            if ([self.dataSource getAssets].count > 0) {
                [footer showLoadMore];
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
    VAsset *asset = [self getAssetForIndexPath:indexPath];
    
    if (asset.isVideo && !self.selectionStorage.isNumerable) {
        //return;
    }
    
    if ([asset isDownloading]) {
        [asset cancelDownloading];
        
    } else if ([self.selectionStorage hasAsset:asset]) {
        [self.selectionStorage removeAsset:asset];
        
    } else {
        self.lastActiveAsset = asset;
        
        [asset downloadWithCompletion:^(UIImage *resultImage, BOOL requestFinished, BOOL requestError) {
//            NSLog(@"selectionActionForIndexPath.downloadWithCompletion requestFinished=%@ requestError=%@" ,requestFinished ? @"Y" : @"N", requestError ? @"Y" : @"N");
            if (requestError) {
                return;
            }
            if (requestFinished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.selectionStorage addAsset:asset];
                    [self displayAsset:asset autoPlay:YES];
                });
            } else if (![asset isVideo]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self displayAsset:asset autoPlay:NO];
                });
            }
            
        }];
    }
    
}


-(void) setSelectionStorage:(AssetsCollection *)selectionStorage
{
    _selectionStorage = selectionStorage;
    [self reloadData];
}

- (void) hideSearchControls {
    self.searchResultsTableView.hidden = YES;
    self.noSearchResultsView.hidden = YES;
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
        [self reloadData];
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
            [self reloadData];
            if (error != nil) {
                [self setLoadingError:error];
            }
        }];
    }
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setActivityIndicatorsVisible: NO];
    
    ImageSelectorSplitController* splitController = [self getSplitController];
    if (splitController != nil) {
        [splitController scrollTopViewToTop:YES];
    }
    
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
    }
    else {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    }
}


@end
