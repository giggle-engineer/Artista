//
//  AlbumViewCellFlowLayout.m
//  Artista
//
//  Created by Chloe Stars on 1/21/13.
//  Copyright (c) 2013 Chloe Stars. All rights reserved.
//

#import "AlbumViewCellFlowLayout.h"

@implementation AlbumViewCellFlowLayout

-(id)init
{
	self = [super init];
	if (self) {
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
		self.itemSize = CGSizeMake(90, 111);
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
		self.itemSize = CGSizeMake(90, 111);
	}
	return self;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}

@end
