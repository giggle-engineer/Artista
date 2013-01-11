//
//  VanishingCellFixLayout.m
//  Artista
//
//  Created by Chloe Stars on 1/10/13.
//  Copyright (c) 2013 Chloe Stars. All rights reserved.
//

#import "VanishingCellFixLayout.h"

@implementation VanishingCellFixLayout

/*
 For a reminder of the issue that necessitated the creation of this subclass see here http://stackoverflow.com/questions/13360975/uicollectionviews-cell-disappearing-ios
 */

-(id)init
{
	self = [super init];
	if (self) {
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
		self.itemSize = CGSizeMake(145, 105);
		// min spacing for cells 10, 10
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
		self.itemSize = CGSizeMake(145, 105);
		// min spacing for cells 10, 10
	}
	return self;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}

@end
