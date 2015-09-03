//
//  Albums.m
//  VideoEditor2
//
//  Created by Alexander on 8/17/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "Albums.h"
#import "ImageSelectController.h"
#import "ImageSelectDataSource.h"
#import "ImageSelectVideoDataSource.h"

@interface Albums () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *albums;

@end

@implementation Albums

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.albums = [NSMutableArray new];
    
    [BaseImageSelectDataSource.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            [self.albums addObject: group];
        } else {
            [self.tableView reloadData];
        }
        
    } failureBlock:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }];
   
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count > 0 ? self.albums.count + 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumsTableViewCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = @"Video";

    } else {
        ALAssetsGroup *album = self.albums[indexPath.row - 1];
        
        cell.textLabel.text = [album valueForProperty:ALAssetsGroupPropertyName];
        cell.imageView.image = [UIImage imageWithCGImage:[album posterImage]];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"displayImageSelectFromAlbum"]) {
        ImageSelectController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if (indexPath.row == 0) {
            [controller loadDataFromDataSource:[ImageSelectVideoDataSource new]];
        } else {
            [controller loadDataFromDataSource:[[ImageSelectDataSource alloc] initWithAssetsGroup:self.albums[indexPath.row - 1]]];
        }
    }
}

@end
