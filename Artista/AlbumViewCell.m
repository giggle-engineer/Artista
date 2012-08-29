//
//  AlbumViewCell.m
//  Artista
//
//  Created by Chloe Stars on 8/27/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "AlbumViewCell.h"

@implementation AlbumViewCell
@dynamic contentView;
@dynamic backgroundView;
@dynamic reuseIdentifier;

+ (id) cellFromNib {
	
	static UINib *nib = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		nib = [UINib nibWithNibName:NSStringFromClass([self class])  bundle:nil];
	});
	
	NSArray *objects = [nib instantiateWithOwner:nil options:nil];
	
	for (AlbumViewCell *cell in objects)
		if ([cell isKindOfClass:[AlbumViewCell class]])
			return cell;
	
	return nil;
	
}

@end
