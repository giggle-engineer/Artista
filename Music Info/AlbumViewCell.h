//
//  AlbumViewCell.h
//  Artista
//
//  Created by Chloe Stars on 8/27/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "AQGridView.h"

@interface AlbumViewCell : AQGridViewCell

+ (id)cellFromNib;

@property (nonatomic, readonly, retain) IBOutlet UIView * contentView;
@property (nonatomic, retain) IBOutlet UIView * backgroundView;
@property (nonatomic, retain) IBOutlet UIView * selectedBackgroundView;
@property (nonatomic, copy) NSString *reuseIdentifier;

@end
