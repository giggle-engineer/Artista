
//
//  TrackViewCell.m
//  Artista
//
//  Created by Chloe Stars on 9/10/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "TrackViewCell.h"

@implementation TrackViewCell
@dynamic reuseIdentifier;

+ (id) cellFromNib {
	
	static UINib *nib = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		nib = [UINib nibWithNibName:NSStringFromClass([self class])  bundle:nil];
	});
	
	NSArray *objects = [nib instantiateWithOwner:nil options:nil];
	
	for (TrackViewCell *cell in objects)
		if ([cell isKindOfClass:[TrackViewCell class]])
			return cell;
	
	return nil;
	
}

@end
