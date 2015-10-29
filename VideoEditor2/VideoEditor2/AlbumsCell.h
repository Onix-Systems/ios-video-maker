//
//  AlbumsCell.h
//  VideoEditor2
//
//  Created by Alexander on 10/29/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface AlbumsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *albumThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *albumTitle;

@end
