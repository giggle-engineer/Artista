//
//  AlbumViewCell.h
//  Artista
//
//  Created by Chloe Stars on 8/27/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKGridView/KKGridView.h>

@interface AlbumViewCell : KKGridViewCell {
	IBOutlet UIImageView *artworkView;
	IBOutlet UILabel *nameLabel;
}

@property IBOutlet UIImageView *artworkView;
@property IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIView *backgroundView; // Underneath contentView, use this to customize backgrounds
@property (nonatomic, strong) IBOutlet UIView *contentView; // Where all subviews should be.
@property (nonatomic, strong) IBOutlet UIView *selectedBackgroundView;
@property (nonatomic, copy) NSString *reuseIdentifier;

+ (id) cellFromNib;

@end
