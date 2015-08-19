//
//  Albums.m
//  VideoEditor2
//
//  Created by Alexander on 8/17/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "Albums.h"
#import "TWPhotoLoader.h"
#import "TWPhotoPickerController.h"
#import "ImageSelectController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface Albums () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSMutableArray *albums;

@end

@implementation Albums

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.albums = [NSMutableArray new];
    __weak Albums *weakSelf = self;
    
    //self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.assetsLibrary = [TWPhotoLoader sharedLoader].assetsLibrary;
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            [weakSelf.albums addObject: group];
        } else {
            [weakSelf.tableView reloadData];
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
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumsTableViewCell" forIndexPath:indexPath];
    
    ALAssetsGroup *album = self.albums[indexPath.row];
    
    cell.textLabel.text = [album valueForProperty:ALAssetsGroupPropertyName];
    cell.imageView.image = [UIImage imageWithCGImage:[album posterImage]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
//    
//    photoPicker.albumToShow = self.albums[indexPath.row];
//    
//    photoPicker.cropBlock = ^(UIImage *image) {
//        //do something
//        //self.imageView.image = image;
//    };
//    
//    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:photoPicker];
//    [navCon setNavigationBarHidden:YES];
//    
//    [self presentViewController:navCon animated:YES completion:NULL];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"displayImageSelectFromAlbum"]) {
        ImageSelectController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        [controller loadDataFromALAssetsGroup:self.albums[indexPath.row]];
    }
}

@end
