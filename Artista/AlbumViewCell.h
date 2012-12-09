//
//  AlbumViewCell.h
//  Artista
//
//  Created by Chloe Stars on 8/27/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumViewCell : UICollectionViewCell {
	IBOutlet UIImageView *artworkView;
	IBOutlet UILabel *nameLabel;
}

@property IBOutlet UIImageView *artworkView;
@property IBOutlet UILabel *nameLabel;

@end
